import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // --- 1. สมัครสมาชิก (ตัด Supabase ออกแล้ว) ---
  Future<User?> register({
    required String email,
    required String password,
    required String username,
    required String firstName,
    required String lastName,
    required int year,
  }) async {
    try {
      final usernameCheck = await _firestore
          .collection('users')
          .where('username', isEqualTo: username.toLowerCase().trim())
          .get();

      if (usernameCheck.docs.isNotEmpty) {
        throw FirebaseAuthException(code: 'username-already-in-use');
      }

      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      User? user = result.user;

      if (user != null) {
        await _firestore.collection('users').doc(user.uid).set({
          'uid': user.uid,
          'username': username.toLowerCase().trim(),
          'firstName': firstName,
          'lastName': lastName,
          'email': email.trim(),
          'year': year,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
      return user;
    } catch (e) {
      debugPrint("Registration Error: $e");
      rethrow;
    }
  }

  // --- 2. เข้าสู่ระบบ (รองรับ Email/Username) ---
  Future<User?> login(String identifier, String password) async {
    try {
      String email = identifier.trim();
      if (!email.contains('@')) {
        final querySnapshot = await _firestore
            .collection('users')
            .where('username', isEqualTo: email.toLowerCase())
            .limit(1)
            .get();

        if (querySnapshot.docs.isEmpty) {
          throw FirebaseAuthException(code: 'user-not-found');
        }
        email = querySnapshot.docs.first.get('email');
      }
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } catch (e) {
      debugPrint("Login Error: $e");
      rethrow;
    }
  }

  // --- 3. รีเซ็ตรหัสผ่าน (ที่หน้า Forgot Password เรียกใช้) ---
  Future<void> sendPasswordReset(String identifier) async {
    try {
      String email = identifier.trim();

      if (!email.contains('@')) {
        final querySnapshot = await _firestore
            .collection('users')
            .where('username', isEqualTo: email.toLowerCase())
            .limit(1)
            .get();

        if (querySnapshot.docs.isEmpty) {
          throw FirebaseAuthException(code: 'user-not-found');
        }
        email = querySnapshot.docs.first.get('email');
      }

      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      debugPrint("Reset Password Error: $e");
      rethrow;
    }
  }

  // --- 4. ดึงข้อมูลโปรไฟล์ (ที่หน้า Home/Profile เรียกใช้) ---
  Future<Map<String, dynamic>?> getUserProfile() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;

      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (!doc.exists) return null;

      return doc.data();
    } catch (e) {
      debugPrint("Get Profile Error: $e");
      return null;
    }
  }

  // --- 5. ออกจากระบบ ---
  Future<void> logout() async {
    await _auth.signOut();
  }

  // Stream สำหรับเช็คสถานะการล็อกอิน
  Stream<User?> get authStateChanges => _auth.authStateChanges();
}
