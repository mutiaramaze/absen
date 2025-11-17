import 'dart:convert';
import 'dart:io';

import 'package:absen/constant/preference_handler.dart';
import 'package:absen/models/batch_model.dart';
import 'package:absen/models/register_model.dart';
import 'package:absen/models/training_model.dart';
import 'package:absen/service/api.dart';
import 'package:absen/views/login.dart';
import 'package:absen/widget/login_button.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';

class Register extends StatefulWidget {
  const Register({super.key});
  static const id = "/register_day34";

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController nameController = TextEditingController();

  bool isVisibility = false;
  bool isLoading = false;
  bool isLoadingDropdown = false;

  RegisterModel user = RegisterModel();

  final _formKey = GlobalKey<FormState>();

  // --- state baru ---
  String? selectedGender; // 'L' / 'P'
  int? selectedTrainingId;
  int? selectedBatchId;

  List<TrainingModelData> trainings = [];
  List<BatchModelData> batches = [];
  // --- state foto profile ---
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

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    try {
      final XFile? picked = await picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 70,
      );

      if (picked == null) return;

      final bytes = await picked.readAsBytes();

      // optional: deteksi extension
      final ext = picked.path.split('.').last.toLowerCase();
      String mime = 'jpeg';
      if (ext == 'png') mime = 'png';
      if (ext == 'jpg' || ext == 'jpeg') mime = 'jpeg';

      final base64Str = base64Encode(bytes);
      final dataUri = 'data:image/$mime;base64,$base64Str';

      setState(() {
        _pickedImageFile = File(picked.path);
        _profilePhotoBase64 = dataUri;
      });
    } catch (e) {
      Fluttertoast.showToast(msg: 'Gagal memilih gambar: $e');
    }
  }

  Future<void> _loadDropdownData() async {
    setState(() {
      isLoadingDropdown = true;
    });
    try {
      final trainingList = await TrainingAPI.getTrainings();
      final batchList = await TrainingAPI.getTrainingBatches();
      setState(() {
        trainings = trainingList;
        batches = batchList;
      });
    } catch (e) {
      Fluttertoast.showToast(msg: 'Gagal mengambil data: $e');
    } finally {
      setState(() {
        isLoadingDropdown = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(children: [buildBackground(), buildLayer()]),
    );
  }

  SafeArea buildLayer() {
    return SafeArea(
      child: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Hello, Welcome",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  height(12),

                  const Text("Register to access your account"),
                  height(24),
                  // ================= FOTO PROFILE DI PALING ATAS =================
                  GestureDetector(
                    onTap: _pickImage,
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 40,
                          backgroundColor: Colors.grey.shade300,
                          backgroundImage: _pickedImageFile != null
                              ? FileImage(_pickedImageFile!)
                              : null,
                          child: _pickedImageFile == null
                              ? const Icon(
                                  Icons.camera_alt,
                                  size: 32,
                                  color: Colors.black54,
                                )
                              : null,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _pickedImageFile == null
                              ? "Tambah Foto Profil"
                              : "Ganti Foto Profil",
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ================= END FOTO PROFILE ============================
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        children: [
                          // --- Name ---
                          buildTitle("Name"),
                          height(12),
                          buildTextField(
                            hintText: "Enter your name",
                            controller: nameController,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Name tidak boleh kosong";
                              }
                              return null;
                            },
                          ),

                          height(16),

                          // --- Email ---
                          buildTitle("Email Address"),
                          height(12),
                          buildTextField(
                            hintText: "Enter your email",
                            controller: emailController,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Email tidak boleh kosong";
                              } else if (!value.contains('@')) {
                                return "Email tidak valid";
                              } else if (!RegExp(
                                r"^[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+$",
                              ).hasMatch(value)) {
                                return "Format Email tidak valid";
                              }
                              return null;
                            },
                          ),

                          height(16),

                          // --- Password ---
                          buildTitle("Password"),
                          height(12),
                          buildTextField(
                            hintText: "Enter your password",
                            isPassword: true,
                            controller: passwordController,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Password tidak boleh kosong";
                              } else if (value.length < 6) {
                                return "Password minimal 6 karakter";
                              }
                              return null;
                            },
                          ),

                          height(16),

                          // --- Jenis Kelamin ---
                          buildTitle("Jenis Kelamin"),
                          height(12),
                          DropdownButtonFormField<String>(
                            dropdownColor: Colors.white,
                            initialValue: selectedGender,
                            isExpanded: true,
                            decoration: _dropdownDecoration(),
                            items: genderOptions
                                .map(
                                  (g) => DropdownMenuItem<String>(
                                    value: g['value'],
                                    child: Text(g['label'] ?? ''),
                                  ),
                                )
                                .toList(),
                            onChanged: (value) {
                              setState(() {
                                selectedGender = value;
                              });
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Pilih jenis kelamin";
                              }
                              return null;
                            },
                          ),

                          height(16),

                          // --- Training ---
                          buildTitle("Pelatihan"),
                          height(12),
                          isLoadingDropdown
                              ? const Center(child: CircularProgressIndicator())
                              : DropdownButtonFormField<int>(
                                  dropdownColor: Colors.white,
                                  initialValue: selectedTrainingId,
                                  isExpanded: true,
                                  decoration: _dropdownDecoration(),
                                  items: trainings
                                      .map(
                                        (t) => DropdownMenuItem<int>(
                                          value: t.id,
                                          child: Text(t.title ?? ""),
                                        ),
                                      )
                                      .toList(),
                                  onChanged: (value) {
                                    setState(() {
                                      selectedTrainingId = value;
                                    });
                                  },
                                  validator: (value) {
                                    if (value == null) {
                                      return "Pilih pelatihan";
                                    }
                                    return null;
                                  },
                                ),

                          height(16),

                          // --- Batch ---
                          buildTitle("Batch"),
                          height(12),
                          isLoadingDropdown
                              ? const Center(child: CircularProgressIndicator())
                              : DropdownButtonFormField<int>(
                                  dropdownColor: Colors.white,
                                  initialValue: selectedBatchId,
                                  isExpanded: true,
                                  decoration: _dropdownDecoration(),
                                  items: batches
                                      .map(
                                        (b) => DropdownMenuItem<int>(
                                          value: b.id,
                                          child: Text(b.batchKe ?? ""),
                                        ),
                                      )
                                      .toList(),
                                  onChanged: (value) {
                                    setState(() {
                                      selectedBatchId = value;
                                    });
                                  },
                                  validator: (value) {
                                    if (value == null) {
                                      return "Pilih batch pelatihan";
                                    }
                                    return null;
                                  },
                                ),
                        ],
                      ),
                    ),
                  ),

                  height(24),

                  // --- Button Register ---
                  LoginButton(
                    text: "Register",
                    isLoading: isLoading,
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        if (selectedGender == null ||
                            selectedTrainingId == null ||
                            selectedBatchId == null) {
                          Fluttertoast.showToast(
                            msg:
                                "Jenis kelamin, pelatihan, dan batch harus dipilih",
                          );
                          return;
                        }

                        setState(() {
                          isLoading = true;
                        });

                        try {
                          final result = await AuthAPI.registerUser(
                            email: emailController.text.trim(),
                            name: nameController.text.trim(),
                            password: passwordController.text,
                            jenisKelamin: selectedGender!, // 'L' / 'P'
                            batchId: selectedBatchId!,
                            trainingId: selectedTrainingId!,
                            profilePhoto:
                                _profilePhotoBase64 ??
                                "", // nanti bisa diisi base64
                          );

                          setState(() {
                            isLoading = false;
                            user = result;
                          });

                          // contoh: simpan token kalau ada
                          if (user.data?.token != null) {
                            await PreferenceHandler.saveToken(
                              user.data!.token!,
                            );
                          }

                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => Login()),
                          );

                          // context.pushReplacement(DrawerWidgetDay15());
                        } catch (e) {
                          Fluttertoast.showToast(msg: e.toString());
                          setState(() {
                            isLoading = false;
                          });
                        }
                      } else {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: const Text("Validation Error"),
                              content: const Text("Please fill all fields"),
                              actions: [
                                TextButton(
                                  child: const Text("OK"),
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                ),
                                TextButton(
                                  child: const Text("Ga OK"),
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                ),
                              ],
                            );
                          },
                        );
                      }
                    },
                  ),

                  height(16),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Don't have an account?"),
                      TextButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => Login()),
                          );
                        },
                        child: const Text(
                          "Sign Up",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _dropdownDecoration() {
    return InputDecoration(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(32),
        borderSide: BorderSide(
          color: Colors.black.withOpacity(0.2),
          width: 1.0,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(32),
        borderSide: const BorderSide(color: Colors.black, width: 1.0),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(32),
        borderSide: BorderSide(
          color: Colors.black.withOpacity(0.2),
          width: 1.0,
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    );
  }

  Container buildBackground() {
    return Container(
      height: double.infinity,
      width: double.infinity,
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage("assets/images/background.png"),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  TextFormField buildTextField({
    String? hintText,
    bool isPassword = false,
    TextEditingController? controller,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      validator: validator,
      controller: controller,
      obscureText: isPassword ? isVisibility : false,
      decoration: InputDecoration(
        hintText: hintText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(32),
          borderSide: BorderSide(
            color: Colors.black.withOpacity(0.2),
            width: 1.0,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(32),
          borderSide: const BorderSide(color: Colors.black, width: 1.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(32),
          borderSide: BorderSide(
            color: Colors.black.withOpacity(0.2),
            width: 1.0,
          ),
        ),
        suffixIcon: isPassword
            ? IconButton(
                onPressed: () {
                  setState(() {
                    isVisibility = !isVisibility;
                  });
                },
                icon: Icon(
                  isVisibility ? Icons.visibility_off : Icons.visibility,
                ),
              )
            : null,
      ),
    );
  }

  SizedBox height(double height) => SizedBox(height: height);
  SizedBox width(double width) => SizedBox(width: width);

  Widget buildTitle(String text) {
    return Row(
      children: [
        Text(
          text,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            // color: AppColor.gray88,
          ),
        ),
      ],
    );
  }
}
