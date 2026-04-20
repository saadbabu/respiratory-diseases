import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/phone_auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passController = TextEditingController();
  bool isLogin = true;

  final Color accentBerry = const Color(0xFFAD445A);
  final Color bgCanvas = const Color(0xFFF9F5F6);

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthSessionProvider>();

    return Scaffold(
      backgroundColor: bgCanvas,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              Icon(Icons.local_hospital_outlined, size: 64, color: accentBerry),
              const SizedBox(height: 16),
              Text(isLogin ? "Welcome Back" : "Create Account",
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
              const SizedBox(height: 40),

              _buildField(_emailController, "Email Address", Icons.email_outlined),
              const SizedBox(height: 16),
              _buildField(_passController, "Password", Icons.lock_outline, isPass: true),
              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2D2727),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: auth.isLoading ? null : () => _handleAuth(auth),
                  child: auth.isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(isLogin ? "SIGN IN" : "REGISTER", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),

              TextButton(
                onPressed: () => setState(() => isLogin = !isLogin),
                child: Text(isLogin ? "Don't have an account? Sign Up" : "Already have an account? Login",
                    style: TextStyle(color: accentBerry, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(TextEditingController ctr, String hint, IconData icon, {bool isPass = false}) {
    return TextField(
      controller: ctr,
      obscureText: isPass,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: accentBerry, size: 20),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      ),
    );
  }

  void _handleAuth(AuthSessionProvider auth) async {
    String? error = isLogin
        ? await auth.signIn(_emailController.text, _passController.text)
        : await auth.signUp(_emailController.text, _passController.text);

    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
    }
  }
}