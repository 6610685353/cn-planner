import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cn_planner_app/services/profile_service.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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
          'profileImageUrl': "",
          'createdAt': FieldValue.serverTimestamp(),
        });

        await ProfileService().checkOrCreateProfile(user.uid, year);
      }
      return user;
    } catch (e) {
      debugPrint("Registration Error: $e");
      rethrow;
    }
  }

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

  Future<void> logout() async {
    await _auth.signOut();
  }

  Future<String?> uploadProfileImage(File imageFile, String uid) async {
    try {
      final storageRef = FirebaseStorage.instance.ref().child(
        'profile_images/$uid.jpg',
      );
      await storageRef.putFile(imageFile);
      final downloadUrl = await storageRef.getDownloadURL();

      await _firestore.collection('users').doc(uid).update({
        'profileImageUrl': downloadUrl,
      });

      return downloadUrl;
    } catch (e) {
      debugPrint("Upload Image Error: $e");
      return null;
    }
  }

  Stream<User?> get authStateChanges => _auth.authStateChanges();
}
