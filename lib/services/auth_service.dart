import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:bookswap/services/notification_service.dart';
import 'package:bookswap/models/user_profile.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<User?> get user => _auth.authStateChanges();

// Enhanced sign-up with better error handling and display name
  Future<User?> signUp(String email, String password, String displayName) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Update user profile with display name
      await result.user!.updateDisplayName(displayName);
      
      // Create user profile in Firestore
      await _firestore.collection('users').doc(result.user!.uid).set({
        'email': email,
        'displayName': displayName,
        'createdAt': DateTime.now().millisecondsSinceEpoch,
        'emailVerified': false,
      });

      // Send email verification
      await result.user!.sendEmailVerification();

      return result.user;
    } catch (e) {
      if (kDebugMode) {
        print('Sign up error: $e');
      }
      rethrow;
    }
  }

  // Enhanced sign-in with auto-reload and better verification handling
  Future<User?> signIn(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Reload user to get latest email verification status
      await result.user!.reload();
      final currentUser = _auth.currentUser;
      
      if (currentUser != null && !currentUser.emailVerified) {
        // If not verified, send new verification email
        await sendVerificationEmail();
        await signOut();
        throw FirebaseAuthException(
          code: 'email-not-verified',
          message: 'Please verify your email. A new verification link has been sent.',
        );
      }
      
      return currentUser;
    } catch (e) {
      if (kDebugMode) {
        print('Sign in error: $e');
      }
      rethrow;
    }
  }

  // Improved verification email sender
  Future<void> sendVerificationEmail() async {
    final user = _auth.currentUser;
    if (user != null && !user.emailVerified) {
      await user.sendEmailVerification();
    }
  }

  // Check email verification status with auto-reload
  Future<bool> checkEmailVerified() async {
    await _auth.currentUser?.reload();
    return _auth.currentUser?.emailVerified ?? false;
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<void> resendVerificationEmail() async {
    await _auth.currentUser!.sendEmailVerification();
  }


  // Existing methods for FCM token and user profile
  Future<void> updateUserFCMToken(String userId) async {
    try {
      final fcmToken = await NotificationService.getFCMToken();
      if (fcmToken != null) {
        await _firestore.collection('users').doc(userId).update({
          'fcmToken': fcmToken,
          'lastSeen': DateTime.now().millisecondsSinceEpoch,
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error updating FCM token: $e');
      }
    }
  }

  Future<UserProfile?> getUserProfile(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        return UserProfile.fromMap(doc.data()!);
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting user profile: $e');
      }
      return null;
    }
  }

  Future<void> updateUserProfile(UserProfile profile) async {
    try {
      await _firestore.collection('users').doc(profile.uid).update(profile.toMap());
    } catch (e) {
      if (kDebugMode) {
        print('Error updating user profile: $e');
      }
      rethrow;
    }
  }

  // Helper method to get current user ID
  String? getCurrentUserId() {
    return _auth.currentUser?.uid;
  }

  // Helper method to get current user email
  String? getCurrentUserEmail() {
    return _auth.currentUser?.email;
  }

  // Helper method to get current user display name
  String? getCurrentUserDisplayName() {
    return _auth.currentUser?.displayName;
  }

  // Method to check if user is logged in and verified
  Future<bool> isUserVerified() async {
    final user = _auth.currentUser;
    if (user != null) {
      await user.reload();
      return user.emailVerified;
    }
    return false;
  }

  // Method to delete user account
  Future<void> deleteUserAccount() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        // Delete user data from Firestore first
        await _firestore.collection('users').doc(user.uid).delete();
        
        // Then delete the auth account
        await user.delete();
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting user account: $e');
      }
      rethrow;
    }
  }

  // Method to update user password
  Future<void> updatePassword(String newPassword) async {
    try {
      await _auth.currentUser!.updatePassword(newPassword);
    } catch (e) {
      if (kDebugMode) {
        print('Error updating password: $e');
      }
      rethrow;
    }
  }

  // Method to send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      if (kDebugMode) {
        print('Error sending password reset email: $e');
      }
      rethrow;
    }
  }
}