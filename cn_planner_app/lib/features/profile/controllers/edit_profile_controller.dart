import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/constants/app_colors.dart';
import '../../../services/auth_service.dart';
import '../../../core/widgets/status_dialog.dart';

class EditProfileController {
  final firstnameController = TextEditingController();
  final lastnameController = TextEditingController();

  File? selectedImageFile;
  String? profileImageUrl;

  String _originalFirstName = '';
  String _originalLastName = '';

  // เช็คว่ามีการแก้ไขข้อมูลหรือยัง
  bool get hasChanges {
    return selectedImageFile != null ||
        firstnameController.text.trim() != _originalFirstName ||
        lastnameController.text.trim() != _originalLastName;
  }

  // โหลดข้อมูลตอนเปิดหน้า
  Future<void> loadInitialData(VoidCallback updateUI) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      if (doc.exists) {
        _originalFirstName = doc.data()?['firstName'] ?? '';
        _originalLastName = doc.data()?['lastName'] ?? '';
        profileImageUrl = doc.data()?['profileImageUrl'];

        firstnameController.text = _originalFirstName;
        lastnameController.text = _originalLastName;

        updateUI();
      }
    } catch (e) {
      debugPrint("Error loading user data: $e");
    }
  }

  // เลือกและครอบรูป
  Future<void> pickAndCropImage(VoidCallback updateUI) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      CroppedFile? croppedFile = await ImageCropper().cropImage(
        sourcePath: pickedFile.path,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Crop Profile Picture',
            toolbarColor: AppColors.accentYellow,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.square,
            lockAspectRatio: true,
            cropStyle: CropStyle.circle,
          ),
          IOSUiSettings(
            title: 'Crop Profile Picture',
            cropStyle: CropStyle.circle,
            aspectRatioLockEnabled: true,
          ),
        ],
      );

      if (croppedFile != null) {
        selectedImageFile = File(croppedFile.path);
        updateUI();
      }
    }
  }

  // บันทึกข้อมูล
  Future<void> handleEditProfile(BuildContext context) async {
    final firstName = firstnameController.text.trim();
    final lastName = lastnameController.text.trim();

    bool imageChanged = selectedImageFile != null;
    bool firstNameChanged = firstName != _originalFirstName;
    bool lastNameChanged = lastName != _originalLastName;

    if (!imageChanged && !firstNameChanged && !lastNameChanged) {
      Navigator.pop(context);
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception("User not found");
      final uid = user.uid;

      if (imageChanged) {
        await AuthService().uploadProfileImage(selectedImageFile!, uid);
      }

      Map<String, dynamic> updates = {};
      if (firstNameChanged) updates['firstName'] = firstName;
      if (lastNameChanged) updates['lastName'] = lastName;

      if (updates.isNotEmpty) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .update(updates);
      }

      if (context.mounted) Navigator.pop(context); // ปิด Loading

      String summaryMsg =
          "Profile Picture:  ${imageChanged ? '✅ Updated' : '-'}\n"
          "First Name:  ${firstNameChanged ? '✅ Updated' : '-'}\n"
          "Last Name:  ${lastNameChanged ? '✅ Updated' : '-'}";

      if (context.mounted) {
        await showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: const Text(
              "Update Summary",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            content: Text(
              summaryMsg,
              style: const TextStyle(fontSize: 16, height: 1.8),
            ),
            actions: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accentYellow,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () => Navigator.pop(ctx),
                child: const Text(
                  "OK",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        );

        if (context.mounted) Navigator.pop(context); // กลับหน้า Profile
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context);
        showDialog(
          context: context,
          builder: (ctx) => StatusDialog(
            title: "Update Failed",
            message: "Error: $e",
            isError: true,
          ),
        );
      }
    }
  }

  void dispose() {
    firstnameController.dispose();
    lastnameController.dispose();
  }
}
