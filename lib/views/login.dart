import 'package:absen/service/api.dart';
import 'package:absen/views/homepage.dart';
import 'package:absen/widget/bottom_nav.dart';
import 'package:absen/widget/classs.dart';
import 'package:absen/widget/login_button.dart';
import 'package:flutter/material.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _formKey = GlobalKey<FormState>();

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text("Login"), backgroundColor: Colors.white),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // --- Email ---
              buildTitle("Email"),
              SizedBox(height: 8),
              buildTextFieldnoButton(
                hintText: "Enter your email",
                controller: emailController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Email tidak boleh kosong";
                  }
                  return null;
                },
              ),

              // --- Password ---
              SizedBox(height: 16),
              buildTitle("Password"),
              SizedBox(height: 12),
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

              SizedBox(height: 25),

              LoginButton(
                text: "Login",
                isLoading: isLoading,
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    setState(() => isLoading = true);

                    try {
                      final result = await AuthAPI.loginUser(
                        email: emailController.text.trim(),
                        password: passwordController.text.trim(),
                      );

                      setState(() => isLoading = false);

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(result.message ?? "Login berhasil"),
                        ),
                      );

                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => BottomNav()),
                      );
                    } catch (e) {
                      setState(() => isLoading = false);

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Login gagal: $e")),
                      );
                    }
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
