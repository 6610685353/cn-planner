import 'package:flutter/material.dart';

class EditProfileController {
  final firstnameController = TextEditingController();
  final lastnameController = TextEditingController();

  void dispose() {
    firstnameController.dispose();
    lastnameController.dispose();
  }

  void handleEditProfile() {
    print("First Name: ${firstnameController.text}");
    print("Last Name: ${lastnameController.text}");
  }
}
