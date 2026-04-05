import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:cn_planner_app/services/auth_service.dart';

class ProfileData {
  final String name;
  final String username;
  final int year;
  final double gpa;
  final double gpax;
  final int earned_credits;
  final int remaining_credits;
  final int total_credits;

  ProfileData({
    required this.name,
    required this.username,
    required this.year,
    required this.gpa,
    required this.gpax,
    required this.earned_credits,
    required this.remaining_credits,
    required this.total_credits,
  });

  String get academicStanding {
    if (gpax == 0.0) return "N/A";
    if (gpax >= 3.50) return "Excellent";
    if (gpax >= 2.00) return "Normal";
    if (gpax >= 1.50) return "Warning";
    return "Critical";
  }
}

class ProfileController {
  final AuthService _authService = AuthService();

  Future<ProfileData?> fetchUserData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return null;

      String name = "Student";
      String username = "Unknown";
      int year = 0;
      double gpa = 0.00;
      double gpax = 0.00;
      int earned_credits = 0;
      int remaining_credits = 0;

      int total_credits = 146; // total credits required to graduate

      // 1. ดึงข้อมูลส่วนตัวจาก Firebase (Firestore)
      final data = await _authService.getUserProfile();
      if (data != null) {
        final firstName = data['firstName'] ?? "";
        final lastName = data['lastName'] ?? "";
        name = "$firstName $lastName".trim();
        username = data['username'] ?? username;
      }

      // 2. ดึงข้อมูลผลการเรียนจาก Supabase
      try {
        final supabase = Supabase.instance.client;
        final supabaseData = await supabase
            .from('profiles')
            .select('current_year, gpa, gpax, earned_credits')
            .eq('user_id', user.uid)
            .single();

        year = supabaseData['current_year'] ?? 0;
        gpa = (supabaseData['gpa'] ?? 0.0).toDouble();
        gpax = (supabaseData['gpax'] ?? 0.0).toDouble();
        earned_credits = supabaseData['earned_credits'] ?? 0;
      } catch (e) {
        debugPrint('Error fetching GPA from Supabase: $e');
      }

      return ProfileData(
        name: name,
        username: username,
        year: year,
        gpa: gpa,
        gpax: gpax,
        earned_credits: earned_credits,
        remaining_credits:
            total_credits - earned_credits, // สมมติว่าต้องจบ 146 หน่วยกิต
        total_credits: total_credits,
      );
    } catch (e) {
      debugPrint('Error in fetchUserData: $e');
      return null;
    }
  }
}
