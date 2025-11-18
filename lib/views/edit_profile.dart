import 'package:flutter/material.dart';
import 'package:absen/models/profile_model.dart';

class EditProfile extends StatefulWidget {
  final ProfileModel profile;

  const EditProfile({super.key, required this.profile});

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  late TextEditingController nameController;
  late TextEditingController emailController;
  String gender = "L"; // default value

  @override
  void initState() {
    super.initState();

    nameController = TextEditingController(text: widget.profile.name ?? "");
    emailController = TextEditingController(text: widget.profile.email ?? "");
    // gender = widget.profile.jenisKelamin ?? "L";
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
            // ----------------- FOTO PROFIL -----------------
            Center(
              child: CircleAvatar(
                radius: 50,
                backgroundColor: Colors.black,
                child: Icon(Icons.person, size: 60, color: Colors.white),
              ),
            ),

            SizedBox(height: 30),

            // ----------------- NAME FIELD -----------------
            buildTitle("Nama Lengkap"),
            SizedBox(height: 6),
            buildTextField(
              controller: nameController,
              hint: "Masukkan nama Anda",
            ),

            SizedBox(height: 20),

            // ----------------- SAVE BUTTON -----------------
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
                print("Profile disimpan...");
                print("Name: ${nameController.text}");
                print("Gender: $gender");

                // TODO: tambahkan API update profile
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
        fillColor: Colors.white,
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
