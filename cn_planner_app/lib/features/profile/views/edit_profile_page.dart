import 'package:cn_planner_app/features/profile/widgets/edit_profile_text_field.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import 'package:cn_planner_app/route.dart';
import 'package:cn_planner_app/core/widgets/top_bar.dart';
import '../widgets/edit_profile_image.dart';
import '../widgets/disable_display_field.dart';
import '../controllers/edit_profile_controller.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => EditProfileState();
}

class EditProfileState extends State<EditProfilePage> {
  // สร้าง Controller เตรียมไว้สำหรับ TextField
  final _edit = EditProfileController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: TopBar(header: "Edit Profile", route: AppRoutes.profile),
      body: SingleChildScrollView(
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 30),

                Center(
                  child: Column(
                    children: [
                      EditProfileImage(),
                      const SizedBox(height: 10),
                      BuildText("Change Photo"),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                BuildTextAtStart("Username"),
                DisabledDisplayField(value: "@somchaitu"),
                BuildTextAtEnd("Username cannot be changed"),

                const SizedBox(height: 8),

                BuildTextAtStart("First Name"),
                const SizedBox(height: 8),
                EditProfileTextField(
                  controller: _edit.firstnameController,
                  hint: "Enter your First Name",
                ),

                const SizedBox(height: 20),

                BuildTextAtStart("Last Name"),
                const SizedBox(height: 8),
                EditProfileTextField(
                  controller: _edit.firstnameController,
                  hint: "Enter your Last Name",
                ),

                const SizedBox(height: 100),

                BuildSaveChangeButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget BuildText(String text) {
    return Text(
      text,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
    );
  }

  Widget BuildTextAtStart(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        text,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget BuildTextAtEnd(String text) {
    return Container(
      width: 352,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            child: Text(
              text,
              style: const TextStyle(fontSize: 12, color: AppColors.errorRed),
            ),
          ),
        ],
      ),
    );
  }

  Widget BuildSaveChangeButton() {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton.icon(
        onPressed: _edit.handleEditProfile,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accentYellow,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        icon: const Icon(Icons.check, color: Colors.white),
        label: const Text(
          "Save Change",
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
