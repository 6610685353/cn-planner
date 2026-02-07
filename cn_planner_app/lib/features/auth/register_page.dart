import 'package:cn_planner_app/route.dart';
import 'package:flutter/material.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

const Color cnYellow = Color(0xFFE5AD00);
const Color cnLightYellow = Color(0xFFFFC207);
const Color cnGrey = Color(0xFFE2E2E2);
const Color cnTextGrey = Color.fromARGB(255, 160, 160, 160);
const Color cn_bg = Color(0xFFF8F9FA);

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _fullnameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmpasswordController =
      TextEditingController();

  int? selectedYear;

  @override
  void dispose() {
    _fullnameController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmpasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: cn_bg,
      appBar: AppBar(
        backgroundColor: cn_bg,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pushNamed(context, AppRoutes.login),
          icon: const Icon(Icons.arrow_back, size: 30, color: Colors.black),
        ),
        title: const Text(
          "Create Account",
          style: TextStyle(
            fontFamily: 'OpenSans',
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),

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
              style: TextStyle(fontSize: 14, color: cnTextGrey),
            ),
            const SizedBox(height: 10),

            _buildLabel("Full Name"),
            _buildCustomTextField(
              controller: _fullnameController,
              hintText: "Enter your full name",
            ),

            _buildLabel("Username"),
            _buildCustomTextField(
              controller: _usernameController,
              hintText: "Enter your username",
            ),

            _buildLabel("Password"),
            _buildCustomTextField(
              controller: _passwordController,
              obscureText: true,
              hintText: "Enter your password",
            ),

            _buildLabel("Confirm password"),
            _buildCustomTextField(
              controller: _confirmpasswordController,
              obscureText: true,
              hintText: "Confirm your password",
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
                  onTap: () {
                    Navigator.pushNamed(context, AppRoutes.login);
                  },
                  child: Text(
                    "Log in",
                    style: TextStyle(
                      fontSize: 12,
                      color: cnYellow,
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
          color: cnYellow,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildCustomTextField({
    required TextEditingController controller,
    bool obscureText = false,
    String? hintText,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 15,
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
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: const BorderSide(color: cnGrey, width: 1.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: const BorderSide(color: cnLightYellow, width: 2),
          ),
        ),
      ),
    );
  }

  Widget _buildYearSelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _yearSelectButton(1, 'Y1', 'FRESHMAN'),
        _yearSelectButton(2, 'Y2', 'SOPHOMORE'),
        _yearSelectButton(3, 'Y3', 'JUNIOR'),
        _yearSelectButton(4, 'Y4', 'SENIOR'),
      ],
    );
  }

  Widget _yearSelectButton(int year, String code, String label) {
    final bool isSelected = selectedYear == year;

    return InkWell(
      onTap: () => setState(() => selectedYear = year),
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: isSelected ? cnLightYellow : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(
            color: isSelected ? cnLightYellow : cnGrey,
            width: 1.5,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              code,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                // color: isSelected ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 9,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                // color: isSelected ? Colors.white : Colors.black54,
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
            color: cnLightYellow.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: () {
          // TODO: Implement Registration Logic
          print("Fullname: ${_fullnameController.text}");
          print("Year: $selectedYear");
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: cnLightYellow,
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
