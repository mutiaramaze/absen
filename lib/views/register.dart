// lib/view/register.dart
import 'dart:convert';
import 'dart:io';

import 'package:absen/constant/preference_handler.dart';
import 'package:absen/models/batch_model.dart';
import 'package:absen/models/register_model.dart';
import 'package:absen/models/training_model.dart';
import 'package:absen/service/api.dart';
import 'package:absen/views/login.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';

class Register extends StatefulWidget {
  const Register({super.key});
  static const id = "/register";

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController nameController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  bool isLoading = false;
  bool isLoadingDropdown = false;
  bool _showPassword = false;

  RegisterModel user = RegisterModel();

  // dropdown state
  String? selectedGender; // 'L' / 'P'
  int? selectedTrainingId;
  int? selectedBatchId;

  List<TrainingModelData> trainings = [];
  List<BatchModelData> batches = [];

  // image
  File? _pickedImageFile;
  String? _profilePhotoBase64;

  final List<Map<String, String>> genderOptions = const [
    {"label": "Laki-laki", "value": "L"},
    {"label": "Perempuan", "value": "P"},
  ];

  @override
  void initState() {
    super.initState();
    _loadDropdownData();
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    nameController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    try {
      final XFile? picked = await picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 70,
      );
      if (picked == null) return;
      final bytes = await picked.readAsBytes();
      final ext = picked.path.split('.').last.toLowerCase();
      final String mime = (ext == 'png') ? 'png' : 'jpeg';
      final base64Str = base64Encode(bytes);
      final dataUri = 'data:image/$mime;base64,$base64Str';

      if (!mounted) return;
      setState(() {
        _pickedImageFile = File(picked.path);
        _profilePhotoBase64 = dataUri;
      });
    } catch (e) {
      Fluttertoast.showToast(msg: 'Gagal memilih gambar: $e');
    }
  }

  Future<void> _loadDropdownData() async {
    if (!mounted) return;
    setState(() => isLoadingDropdown = true);
    try {
      final trainingList = await TrainingAPI.getTrainings();
      final batchList = await TrainingAPI.getTrainingBatches();
      if (!mounted) return;
      setState(() {
        trainings = trainingList;
        batches = batchList;
      });
    } catch (e) {
      Fluttertoast.showToast(msg: 'Gagal mengambil data: $e');
    } finally {
      if (!mounted) return;
      setState(() => isLoadingDropdown = false);
    }
  }

  InputDecoration _inputDecoration({required String hint, IconData? icon}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey.shade500),
      prefixIcon: icon != null
          ? Icon(icon, color: Colors.grey.shade600, size: 20)
          : null,
      filled: true,
      fillColor: Colors.white,
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.black87, width: 1.2),
      ),
    );
  }

  InputDecoration _dropdownDecoration({String? hint}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey.shade600, fontSize: 13),
      filled: true,
      isDense: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.black87),
      ),
    );
  }

  Future<void> _submitRegister() async {
    if (!_formKey.currentState!.validate()) return;

    if (selectedGender == null ||
        selectedTrainingId == null ||
        selectedBatchId == null) {
      Fluttertoast.showToast(
        msg: "Jenis kelamin, pelatihan, dan batch harus dipilih",
      );
      return;
    }

    if (!mounted) return;
    setState(() => isLoading = true);
    try {
      final result = await AuthAPI.registerUser(
        email: emailController.text.trim(),
        name: nameController.text.trim(),
        password: passwordController.text,
        jenisKelamin: selectedGender!,
        batchId: selectedBatchId!,
        trainingId: selectedTrainingId!,
        profilePhoto: _profilePhotoBase64 ?? "",
      );

      if (!mounted) return;
      setState(() {
        isLoading = false;
        user = result;
      });

      if (user.data?.token != null) {
        await PreferenceHandler.saveToken(user.data!.token!);
      }

      Fluttertoast.showToast(msg: "Registrasi berhasil");
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const Login()),
      );
    } catch (e) {
      Fluttertoast.showToast(msg: "Register gagal: $e");
      if (!mounted) return;
      setState(() => isLoading = false);
    }
  }

  Widget _buildDropdownsResponsive() {
    // build two dropdowns side-by-side when there's space, otherwise stacked
    return LayoutBuilder(
      builder: (context, constraints) {
        final double gap = 10;
        // compute half width available (minus gap)
        final double half = (constraints.maxWidth - gap) / 2;
        final bool sideBySide =
            constraints.maxWidth >= 420; // threshold, tweak if needed

        if (isLoadingDropdown) {
          return const Center(child: CircularProgressIndicator());
        }

        if (sideBySide) {
          return Row(
            children: [
              SizedBox(
                width: half,
                child: DropdownButtonFormField<String>(
                  value: selectedGender,
                  isDense: true,
                  isExpanded: true,
                  decoration: _dropdownDecoration(hint: "Jenis Kelamin"),
                  items: genderOptions
                      .map(
                        (g) => DropdownMenuItem<String>(
                          value: g['value'],
                          child: Text(
                            g['label'] ?? "",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (v) => setState(() => selectedGender = v),
                  validator: (v) =>
                      (v == null || v.isEmpty) ? "Pilih jenis kelamin" : null,
                ),
              ),
              SizedBox(width: gap),
              SizedBox(
                width: half,
                child: DropdownButtonFormField<int>(
                  value: selectedTrainingId,
                  isDense: true,
                  isExpanded: true,
                  decoration: _dropdownDecoration(hint: "Pelatihan"),
                  items: trainings
                      .map(
                        (t) => DropdownMenuItem<int>(
                          value: t.id,
                          child: Text(
                            t.title ?? "",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (v) => setState(() => selectedTrainingId = v),
                  validator: (v) => (v == null) ? "Pilih pelatihan" : null,
                ),
              ),
            ],
          );
        } else {
          // stacked layout for narrow screens
          return Column(
            children: [
              DropdownButtonFormField<String>(
                value: selectedGender,
                isDense: true,
                isExpanded: true,
                decoration: _dropdownDecoration(hint: "Jenis Kelamin"),
                items: genderOptions
                    .map(
                      (g) => DropdownMenuItem<String>(
                        value: g['value'],
                        child: Text(
                          g['label'] ?? "",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (v) => setState(() => selectedGender = v),
                validator: (v) =>
                    (v == null || v.isEmpty) ? "Pilih jenis kelamin" : null,
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<int>(
                value: selectedTrainingId,
                isDense: true,
                isExpanded: true,
                decoration: _dropdownDecoration(hint: "Pelatihan"),
                items: trainings
                    .map(
                      (t) => DropdownMenuItem<int>(
                        value: t.id,
                        child: Text(
                          t.title ?? "",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (v) => setState(() => selectedTrainingId = v),
                validator: (v) => (v == null) ? "Pilih pelatihan" : null,
              ),
            ],
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: SingleChildScrollView(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 28,
              bottom: bottomInset + 28,
            ),
            child: Column(
              children: [
                // header
                Row(
                  children: [
                    const SizedBox(width: 6),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Welcome",
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Buat akun baru untuk melanjutkan",
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(Icons.close, color: Colors.grey.shade700),
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                // card
                Material(
                  elevation: 6,
                  shadowColor: Colors.black.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 18,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          // avatar
                          GestureDetector(
                            onTap: _pickImage,
                            child: Column(
                              children: [
                                Container(
                                  width: 86,
                                  height: 86,
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade100,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.grey.shade200,
                                    ),
                                    image: _pickedImageFile != null
                                        ? DecorationImage(
                                            image: FileImage(_pickedImageFile!),
                                            fit: BoxFit.cover,
                                          )
                                        : null,
                                  ),
                                  child: _pickedImageFile == null
                                      ? Icon(
                                          Icons.camera_alt_outlined,
                                          color: Colors.grey.shade700,
                                          size: 32,
                                        )
                                      : null,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  _pickedImageFile == null
                                      ? "Tambah Foto"
                                      : "Ganti Foto",
                                  style: TextStyle(color: Colors.grey.shade700),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 14),

                          // name
                          TextFormField(
                            controller: nameController,
                            decoration: _inputDecoration(
                              hint: "Nama lengkap",
                              icon: Icons.person_outline,
                            ),
                            validator: (v) => (v == null || v.isEmpty)
                                ? "Nama tidak boleh kosong"
                                : null,
                          ),
                          const SizedBox(height: 12),

                          // email
                          TextFormField(
                            controller: emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: _inputDecoration(
                              hint: "Email",
                              icon: Icons.email_outlined,
                            ),
                            validator: (v) {
                              if (v == null || v.isEmpty)
                                return "Email tidak boleh kosong";
                              if (!RegExp(r"^[^@]+@[^@]+\.[^@]+").hasMatch(v))
                                return "Format email tidak valid";
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),

                          // password
                          TextFormField(
                            controller: passwordController,
                            obscureText: !_showPassword,
                            decoration:
                                _inputDecoration(
                                  hint: "Password (min. 6 karakter)",
                                  icon: Icons.lock_outline,
                                ).copyWith(
                                  suffixIcon: IconButton(
                                    onPressed: () => setState(
                                      () => _showPassword = !_showPassword,
                                    ),
                                    icon: Icon(
                                      _showPassword
                                          ? Icons.visibility_off
                                          : Icons.visibility,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ),
                            validator: (v) {
                              if (v == null || v.isEmpty)
                                return "Password tidak boleh kosong";
                              if (v.length < 6)
                                return "Password minimal 6 karakter";
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),

                          // RESPONSIVE DROPDOWNS (fix overflow)
                          _buildDropdownsResponsive(),
                          const SizedBox(height: 12),

                          // batch
                          isLoadingDropdown
                              ? const Center(child: CircularProgressIndicator())
                              : DropdownButtonFormField<int>(
                                  value: selectedBatchId,
                                  isDense: true,
                                  isExpanded: true,
                                  decoration: _dropdownDecoration(
                                    hint: "Batch",
                                  ),
                                  items: batches
                                      .map(
                                        (b) => DropdownMenuItem<int>(
                                          value: b.id,
                                          child: Text(
                                            b.batchKe ?? "",
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      )
                                      .toList(),
                                  onChanged: (v) =>
                                      setState(() => selectedBatchId = v),
                                  validator: (v) =>
                                      (v == null) ? "Pilih batch" : null,
                                ),

                          const SizedBox(height: 18),

                          // register button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: isLoading ? null : _submitRegister,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.black,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: isLoading
                                  ? Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: const [
                                        SizedBox(
                                          width: 18,
                                          height: 18,
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2,
                                          ),
                                        ),
                                        SizedBox(width: 12),
                                        Text("Mendaftarkan..."),
                                      ],
                                    )
                                  : const Text(
                                      "Daftar",
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                            ),
                          ),

                          const SizedBox(height: 12),

                          // have account
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Sudah punya akun?",
                                style: TextStyle(color: Colors.grey.shade700),
                              ),
                              TextButton(
                                onPressed: () {
                                  if (!mounted) return;
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const Login(),
                                    ),
                                  );
                                },
                                child: const Text(
                                  "Masuk",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 18),

                // footer small note
                Text(
                  "Dengan mendaftar, kamu menyetujui syarat & ketentuan.",
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
