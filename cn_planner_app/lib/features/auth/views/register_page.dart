import 'package:flutter/material.dart';
import 'package:cn_planner_app/route.dart';
import '../../../core/constants/app_colors.dart';
import '../controllers/register_controller.dart';
import '../widgets/register_text_field.dart';
import 'package:cn_planner_app/core/widgets/top_bar.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _controller = RegisterController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: TopBar(header: "Create your account", route: AppRoutes.login),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Join CN Planner",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const Text(
              "Enter your detail to tailor your study plan.",
              style: TextStyle(fontSize: 14, color: AppColors.textGrey),
            ),
            const SizedBox(height: 10),

            _buildLabel("First Name"),
            RegisterTextField(
              controller: _controller.firstnameController,
              hintText: "Enter your first name",
            ),

            _buildLabel("Last Name"),
            RegisterTextField(
              controller: _controller.lastnameController,
              hintText: "Enter your last name",
            ),

            _buildLabel("Username"),
            RegisterTextField(
              controller: _controller.usernameController,
              hintText: "Enter your username",
            ),

            _buildLabel("Email"),
            RegisterTextField(
              controller: _controller.emailController,
              hintText: "Enter your email",
            ),

            _buildLabel("Password"),
            RegisterTextField(
              controller: _controller.passwordController,
              hintText: "Enter your password",
              obscureText: true,
            ),

            _buildLabel("Confirm password"),
            RegisterTextField(
              controller: _controller.confirmPasswordController,
              hintText: "Confirm your password",
              obscureText: true,
            ),

            _buildLabel("Academic Year"),
            _buildYearSelector(),

            const SizedBox(height: 14),
            _buildSubmitButton(),
            const SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Already have an account? ",
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
                GestureDetector(
                  onTap: () => Navigator.pushNamed(context, AppRoutes.login),
                  child: const Text(
                    "Log in",
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.primaryYellow,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          color: AppColors.primaryYellow,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildYearSelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _yearBtn(1, 'Y1', 'FRESHMAN'),
        _yearBtn(2, 'Y2', 'SOPHOMORE'),
        _yearBtn(3, 'Y3', 'JUNIOR'),
        _yearBtn(4, 'Y4', 'SENIOR'),
      ],
    );
  }

  Widget _yearBtn(int year, String code, String label) {
    final bool isSelected = _controller.selectedYear == year;
    return InkWell(
      onTap: () => setState(() => _controller.selectedYear = year),
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 80,
        height: 80, // ขนาดเดิม
        decoration: BoxDecoration(
          color: isSelected ? AppColors.accentYellow : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(
            color: isSelected ? AppColors.accentYellow : AppColors.borderGrey,
            width: 1.5,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              code,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 9,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return Container(
      width: double.infinity,
      height: 50,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.accentYellow.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ElevatedButton(
        // แก้ไขบรรทัดนี้: ใช้ arrow function เพื่อส่ง context เข้าไปใน Controller
        onPressed: () => _controller.handleRegister(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accentYellow,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 0,
        ),
        child: const Text(
          "Create Account",
          style: TextStyle(
            fontSize: 16,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
