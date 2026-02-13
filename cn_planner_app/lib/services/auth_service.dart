import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import ตัวใหม่ที่เพิ่งลง

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance; // สร้างตัวแปรติดต่อฐานข้อมูล

  // ฟังก์ชันสมัครสมาชิก + บันทึกข้อมูลลงฐานข้อมูล
  Future<User?> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required int year,
  }) async {
    try {
      // 1. สร้างบัญชีใน Firebase Auth (เก็บแค่ Email/Password)
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = result.user;

      if (user != null) {
        // 2. ถ้าสร้างบัญชีสำเร็จ ให้สร้าง "เอกสาร" ใหม่ในตาราง 'users'
        // โดยใช้ ID เดียวกับ UID ของ User เพื่อให้ง่ายต่อการค้นหาในอนาคต
        await _firestore.collection('users').doc(user.uid).set({
          'uid': user.uid,
          'firstName': firstName,
          'lastName': lastName,
          'email': email,
          'year': year,
          'createdAt': FieldValue.serverTimestamp(), // เก็บเวลาที่สมัครจริง
        });
      }
      return user;
    } catch (e) {
      print("Error during registration: $e");
      rethrow; // ส่ง Error กลับไปให้ Controller จัดการ
    }
  }

  // เข้าสู่ระบบ (เหมือนเดิม)
  Future<User?> login(String email, String password) async {
    UserCredential result = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return result.user;
  }

  // เพิ่มเข้าไปในคลาส AuthService
  Future<void> sendPasswordReset(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      rethrow;
    }
  }
}
