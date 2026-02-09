import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import 'package:cn_planner_app/route.dart';
import 'package:cn_planner_app/core/widgets/top_bar.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => EditProfileState();
}

class EditProfileState extends State<EditProfilePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TopBar(header: "Edit Profile", route: AppRoutes.profile),
    );
  }
}
