import 'package:absen/widget/classs.dart';
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

  Future<void> login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    // contoh proses login
    await Future.delayed(const Duration(seconds: 2));

    setState(() => isLoading = false);

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Login sukses")));

    // pindah page
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const Placeholder()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Login")),
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

              const SizedBox(height: 15),

              const SizedBox(height: 25),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: isLoading ? null : login,
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("Login"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
