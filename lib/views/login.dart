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
              SizedBox(height: 8),
              buildTextFieldnoButton(
                controller: passwordController,
                hintText: "Enter your password",
                isPassword: true,
                validator: (v) =>
                    v == null || v.length < 6 ? "Minimal 6 karakter" : null,
              ),

              SizedBox(height: 25),

              LoginButton(
                text: "Login",
                isLoading: isLoading,
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    setState(() => isLoading = true);

                    Future.delayed(Duration(seconds: 2), () {
                      setState(() => isLoading = false);

                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => BottomNav()),
                      );
                    });
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
