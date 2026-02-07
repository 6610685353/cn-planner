import 'package:cn_planner_app/route.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

const Color cnYellow = Color(0xFFFFC207);
const Color cnBorder = Color(0xFFE2E2E2);
const Color cnTextGrey = Color(0xFF727272);
const Color cnRed = Color(0xFFAE0000);

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          // ทำให้เลื่อนได้เมื่อคีย์บอร์ดเปิด
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                // --- Header Section ---
                const Icon(
                  Icons.account_circle_rounded,
                  size: 130,
                  color: Colors.black87,
                ),
                const SizedBox(height: 20),
                const Text(
                  "Welcome Back",
                  style: TextStyle(fontSize: 33, fontWeight: FontWeight.bold),
                ),
                const Text(
                  "Sign in to your planner account",
                  style: TextStyle(color: cnRed, fontSize: 15),
                ),

                const SizedBox(height: 40),

                // --- Form Section ---
                _buildInputLabel("Email / Username"),
                _buildTextField(
                  controller: _usernameController,
                  hintText: "Enter your email or username",
                ),

                const SizedBox(height: 20),

                _buildInputLabel("Password"),
                _buildTextField(
                  controller: _passwordController,
                  obscureText: true,
                  hintText: "Enter your password",
                ),

                // Forgot Password
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {},
                    child: const Text(
                      'Forgot password?',
                      style: TextStyle(fontSize: 12, color: Colors.black87),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // --- Action Section ---
                _buildSignInButton(),

                const SizedBox(height: 20),

                _buildSignUpRedirect(),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- Reusable Widgets ---

  Widget _buildInputLabel(String label) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8, left: 4),
        child: Text(
          label,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    bool obscureText = false,
    String? hintText,
  }) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: const BorderSide(color: cnBorder, width: 2),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: const BorderSide(color: cnYellow, width: 2),
          ),
        ),
      ),
    );
  }

  Widget _buildSignInButton() {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: () {
          // Logic สำหรับ Login
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: cnYellow,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Text(
              'Sign in',
              style: TextStyle(
                fontSize: 18,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(width: 8),
            Icon(Icons.login, size: 20, color: Colors.white),
          ],
        ),
      ),
    );
  }

  Widget _buildSignUpRedirect() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          "Don't have an account?",
          style: TextStyle(fontSize: 14, color: cnTextGrey),
        ),
        TextButton(
          onPressed: () => Navigator.pushNamed(context, AppRoutes.register),
          child: const Text(
            'Sign up',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ],
    );
  }
}
