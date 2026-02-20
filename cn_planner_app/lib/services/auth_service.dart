import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide User;

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final SupabaseClient _supabase = Supabase.instance.client;

  // --- สมัครสมาชิก + บันทึกข้อมูล 2 ฐานข้อมูล (Firestore & Supabase) ---
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
        email: email,
        password: password,
      );

      User? user = result.user;

      if (user != null) {
        // บันทึกลง Firestore
        await _firestore.collection('users').doc(user.uid).set({
          'uid': user.uid,
          'username': username.toLowerCase().trim(),
          'firstName': firstName,
          'lastName': lastName,
          'email': email,
          'year': year,
          'createdAt': FieldValue.serverTimestamp(),
        });

        // บันทึกลง Supabase ตาราง enrolled
        await _supabase.from('Enrolled').insert({'uid': user.uid});

        print(
          "Success: Firebase UID ${user.uid} saved to Supabase table Enrolled",
        );
      }
      return user;
    } catch (e) {
      debugPrint("Registration Error: $e");
      rethrow;
    }
  }

  // --- เข้าสู่ระบบ (รองรับทั้ง Email และ Username) ---
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
      rethrow;
    }
  }

  // --- รีเซ็ตรหัสผ่าน (รองรับทั้ง Email และ Username) ---
  Future<void> sendPasswordReset(String identifier) async {
    try {
      String email = identifier.trim();

      // ถ้าไม่มี @ แสดงว่าเป็น Username ต้องไปหา Email ใน Firestore ก่อน
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

  // --- ออกจากระบบ ---
  Future<void> logout() async {
    await _auth.signOut();
  }

  Future<Map<String, dynamic>?> getUserProfile() async {
    final user = _auth.currentUser;

    if (user == null) return null;

    final doc = await _firestore.collection('users').doc(user.uid).get();

    if (!doc.exists) return null;

    return doc.data();
  }
}
