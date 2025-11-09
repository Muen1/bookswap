import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<User?> get user => _auth.authStateChanges();

  Future<User?> signUp(String email, String password) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Send email verification
      await result.user!.sendEmailVerification();
      
      // Create user profile in Firestore
      await _firestore.collection('users').doc(result.user!.uid).set({
        'email': email,
        'createdAt': DateTime.now().millisecondsSinceEpoch,
      });
      
      return result.user;
    } catch (e) {
      if (kDebugMode) {
        print('Sign up error: $e');
      }
      rethrow;
    }
  }

  Future<User?> signIn(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Check if email is verified
      if (!result.user!.emailVerified) {
        await signOut();
        throw FirebaseAuthException(
          code: 'email-not-verified',
          message: 'Please verify your email before signing in.',
        );
      }
      
      return result.user;
    } catch (e) {
      if (kDebugMode) {
        print('Sign in error: $e');
      }
      rethrow;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<void> resendVerificationEmail() async {
    await _auth.currentUser!.sendEmailVerification();
  }
}