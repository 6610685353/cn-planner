import 'package:cn_planner_app/features/profile/widgets/edit_profile_text_field.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../widgets/edit_profile_image.dart';
import '../widgets/disable_display_field.dart';
import '../controllers/edit_profile_controller.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => EditProfileState();
}

class EditProfileState extends State<EditProfilePage> {
  final _edit = EditProfileController();

  @override
  void initState() {
    super.initState();
    _edit.loadInitialData(_updateUI);
  }

  @override
  void dispose() {
    _edit.dispose();
    super.dispose();
  }

  void _updateUI() {
    setState(() {});
  }

  Future<void> _handleBackNavigation() async {
    if (!_edit.hasChanges) {
      Navigator.of(context).pop();
      return;
    }

    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          "Unsaved Changes",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text(
          "Are you sure you want to exit? You have unsaved changes.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, 'discard'),
            child: const Text(
              "Discard",
              style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accentYellow,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () => Navigator.pop(context, 'save'),
            child: const Text(
              "Save Change",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );

    if (result == 'discard') {
      if (context.mounted) Navigator.of(context).pop();
    } else if (result == 'save') {
      if (context.mounted) _edit.handleEditProfile(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) return;
        await _handleBackNavigation();
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text(
            "Edit Profile",
            style: TextStyle(
              color: Colors.black,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: AppColors.background,
          elevation: 0,
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: _handleBackNavigation,
          ),
        ),
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
                    child: GestureDetector(
                      onTap: () => _edit.pickAndCropImage(_updateUI),
                      child: Column(
                        children: [
                          EditProfileImage(
                            imageFile: _edit.selectedImageFile,
                            imageUrl: _edit.profileImageUrl,
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            "Change Photo",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.accentYellow,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  buildTextAtStart("Username"),
                  const DisabledDisplayField(value: "@somchaitu"),
                  buildTextAtEnd("Username cannot be changed"),

                  const SizedBox(height: 8),

                  buildTextAtStart("First Name"),
                  const SizedBox(height: 8),
                  EditProfileTextField(
                    controller: _edit.firstnameController,
                    hint: "Enter your First Name",
                  ),

                  const SizedBox(height: 20),

                  buildTextAtStart("Last Name"),
                  const SizedBox(height: 8),
                  EditProfileTextField(
                    controller: _edit.lastnameController,
                    hint: "Enter your Last Name",
                  ),

                  const SizedBox(height: 100),

                  buildSaveChangeButton(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildTextAtStart(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        text,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget buildTextAtEnd(String text) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            text,
            style: const TextStyle(fontSize: 12, color: AppColors.errorRed),
          ),
        ],
      ),
    );
  }

  Widget buildSaveChangeButton() {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton.icon(
        onPressed: () => _edit.handleEditProfile(context),
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
