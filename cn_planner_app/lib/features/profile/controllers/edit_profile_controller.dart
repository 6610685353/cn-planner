import 'package:flutter/material.dart';

class EditProfileController {
  final firstnameController = TextEditingController();
  final lastnameController = TextEditingController();

  void dispose() {
    firstnameController.dispose();
    lastnameController.dispose();
  }

  void handleEditProfile() {
    debugPrint("First Name: ${firstnameController.text}");
    debugPrint("Last Name: ${lastnameController.text}");
  }
}
