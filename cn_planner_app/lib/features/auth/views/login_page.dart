import 'package:flutter/material.dart';
import 'package:cn_planner_app/route.dart';
import '../../../core/constants/app_colors.dart';
import '../controllers/login_controller.dart';
import '../widgets/login_text_field.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _controller = LoginController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                // --- ส่วน Icon และ Header ---
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
                  style: TextStyle(
                    color: AppColors.errorRed,
                    fontSize: 15,
                  ), // ใช้สี errorRed
                ),

                const SizedBox(height: 40),

                // --- ส่วนฟอร์มกรอกข้อมูล ---
                _buildInputLabel("Email / Username"),
                LoginTextField(
                  controller: _controller.usernameController,
                  hintText: "Enter your email or username",
                ),

                const SizedBox(height: 20),

                _buildInputLabel("Password"),
                LoginTextField(
                  controller: _controller.passwordController,
                  hintText: "Enter your password",
                  obscureText: true,
                ),

                // Forgot Password
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, AppRoutes.forgotPassword);
                    },
                    child: const Text(
                      'Forgot password?',
                      style: TextStyle(fontSize: 12, color: Colors.black87),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // --- ปุ่ม Sign in ---
                _buildSignInButton(),

                const SizedBox(height: 20),

                // --- ส่วนย้ายไปหน้าสมัครสมาชิก ---
                _buildSignUpRedirect(),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

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

  Widget _buildSignInButton() {
    return Container(
      width: double.infinity,
      height: 54,
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: AppColors.accentYellow.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ElevatedButton(
        // onPressed: _controller.handleLogin,
        onPressed: () => _controller.handleLogin(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accentYellow,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
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
          style: TextStyle(fontSize: 14, color: AppColors.textGrey),
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
