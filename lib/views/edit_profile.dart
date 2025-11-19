import 'package:absen/service/api.dart';
import 'package:flutter/material.dart';
import 'package:absen/models/profile_model.dart';

class EditProfile extends StatefulWidget {
  final ProfileModel profile;

  const EditProfile({super.key, required this.profile});

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  Future<void> saveProfile() async {
    if (nameController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Nama tidak boleh kosong")));
      return;
    }

    try {
      bool success = await ProfileService.updateProfile(nameController.text);
      print(success);

      if (success) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Profil berhasil disimpan")));

        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Gagal menyimpan profil")));
      }
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Terjadi kesalahan")));
    }
  }

  late TextEditingController nameController;

  @override
  void initState() {
    super.initState();

    // Hanya nama yang bisa diedit
    nameController = TextEditingController(
      text: widget.profile.data?.name ?? "",
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: Text("Edit Profile", style: TextStyle(color: Colors.white)),
        iconTheme: IconThemeData(color: Colors.white),
      ),

      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            // FOTO PROFIL
            Center(
              child: CircleAvatar(
                radius: 50,
                backgroundColor: Colors.black,
                child: Icon(Icons.person, size: 60, color: Colors.white),
              ),
            ),

            SizedBox(height: 30),

            // =====================
            // NAMA - Editable
            // =====================
            buildTitle("Nama Lengkap"),
            SizedBox(height: 6),
            buildTextField(
              controller: nameController,
              hint: "Masukkan nama lengkap",
              enabled: true,
            ),

            SizedBox(height: 20),

            // =====================
            // EMAIL - NON EDITABLE
            // =====================
            buildTitle("Email"),
            SizedBox(height: 6),
            buildTextField(
              controller: TextEditingController(
                text: widget.profile.data?.email ?? "-",
              ),
              hint: "Email",
              enabled: false,
            ),

            SizedBox(height: 20),

            // =====================
            // JENIS KELAMIN - NON EDITABLE
            // =====================
            buildTitle("Jenis Kelamin"),
            SizedBox(height: 6),
            buildTextField(
              controller: TextEditingController(
                text: widget.profile.data?.jenisKelamin == "L"
                    ? "Laki-laki"
                    : "Perempuan",
              ),
              hint: "Jenis Kelamin",
              enabled: false,
            ),

            SizedBox(height: 20),

            // =====================
            // BATCH - NON EDITABLE
            // =====================
            buildTitle("Batch"),
            SizedBox(height: 6),
            buildTextField(
              controller: TextEditingController(
                text: widget.profile.data?.batchKe ?? "-",
              ),
              hint: "Batch",
              enabled: false,
            ),

            SizedBox(height: 30),

            // BUTTON SAVE
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 14, horizontal: 30),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                saveProfile();
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.save),
                  SizedBox(width: 8),
                  Text("Simpan Perubahan"),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildTitle(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
    );
  }

  Widget buildTextField({
    required TextEditingController controller,
    required String hint,
    bool enabled = true,
  }) {
    return TextField(
      controller: controller,
      enabled: enabled,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: enabled ? Colors.white : Colors.grey.shade200,
        contentPadding: EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.black),
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.black, width: 2),
          borderRadius: BorderRadius.circular(12),
        ),
        disabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.black26),
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      style: TextStyle(color: Colors.black),
    );
  }
}
