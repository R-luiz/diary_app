import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/foundation.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email', 'profile']);
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Auth state changes stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign in with Google
  Future<UserCredential?> signInWithGoogle() async {
    try {
      if (kDebugMode) {
        print('Starting Google Sign-In process...');
      }

      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        if (kDebugMode) {
          print('User canceled Google Sign-In');
        }
        return null; // User canceled the sign-in
      }

      if (kDebugMode) {
        print('Google user obtained: ${googleUser.email}');
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      if (googleAuth.accessToken == null || googleAuth.idToken == null) {
        throw Exception('Failed to obtain Google authentication tokens');
      }

      if (kDebugMode) {
        print('Google auth tokens obtained');
      }

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credential
      final userCredential = await _auth.signInWithCredential(credential);

      if (kDebugMode) {
        print('Firebase sign-in successful: ${userCredential.user?.email}');
      }

      return userCredential;
    } on FirebaseAuthException catch (e) {
      if (kDebugMode) {
        print('Firebase Auth Error: ${e.code} - ${e.message}');
      }
      throw Exception('Firebase Auth Error: ${e.message}');
    } catch (e) {
      if (kDebugMode) {
        print('Error signing in with Google: $e');
      }
      throw Exception('Google Sign-In failed: $e');
    }
  }

  // Sign in with GitHub (for web platforms)
  Future<UserCredential?> signInWithGitHub() async {
    try {
      if (kDebugMode) {
        print('Starting GitHub Sign-In process...');
      }

      if (kIsWeb) {
        // Web platform - use popup
        GithubAuthProvider githubProvider = GithubAuthProvider();
        githubProvider.addScope('user:email');
        githubProvider.setCustomParameters({'allow_signup': 'true'});

        return await _auth.signInWithPopup(githubProvider);
      } else {
        // Mobile platforms - use redirect (note: requires additional setup)
        throw UnsupportedError(
          'GitHub sign-in on mobile requires additional OAuth setup. '
          'For now, please use Google sign-in or implement a custom OAuth flow.',
        );
      }
    } on FirebaseAuthException catch (e) {
      if (kDebugMode) {
        print('Firebase Auth Error: ${e.code} - ${e.message}');
      }
      throw Exception('Firebase Auth Error: ${e.message}');
    } catch (e) {
      if (kDebugMode) {
        print('Error signing in with GitHub: $e');
      }
      throw Exception('GitHub Sign-In failed: $e');
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
      await _secureStorage.deleteAll();
    } catch (e) {
      print('Error signing out: $e');
    }
  }

  // Check if user is signed in
  bool get isSignedIn => currentUser != null;

  // Get user display name
  String? get userDisplayName => currentUser?.displayName;

  // Get user email
  String? get userEmail => currentUser?.email;

  // Get user photo URL
  String? get userPhotoURL => currentUser?.photoURL;
}
