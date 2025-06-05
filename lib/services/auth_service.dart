import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

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

      // Check if Google Sign-In is available
      if (!await _googleSignIn.isSignedIn()) {
        // Clear any cached sign-in
        await _googleSignIn.signOut();
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

      // Store user info securely
      if (userCredential.user != null) {
        await _secureStorage.write(
          key: 'user_id',
          value: userCredential.user!.uid,
        );
        await _secureStorage.write(
          key: 'user_email',
          value: userCredential.user!.email ?? '',
        );
        await _secureStorage.write(
          key: 'user_name',
          value: userCredential.user!.displayName ?? '',
        );
      }

      return userCredential;
    } on FirebaseAuthException catch (e) {
      if (kDebugMode) {
        print('Firebase Auth Error: ${e.code} - ${e.message}');
      }

      // Provide user-friendly error messages
      String errorMessage;
      switch (e.code) {
        case 'network-request-failed':
          errorMessage =
              'Network error. Please check your internet connection.';
          break;
        case 'too-many-requests':
          errorMessage = 'Too many sign-in attempts. Please try again later.';
          break;
        case 'user-disabled':
          errorMessage = 'This account has been disabled.';
          break;
        case 'invalid-credential':
          errorMessage =
              'Google Sign-In configuration error. Please contact support.';
          break;
        default:
          errorMessage = 'Google Sign-In failed: ${e.message}';
      }
      throw Exception(errorMessage);
    } on PlatformException catch (e) {
      if (kDebugMode) {
        print('Platform Exception: ${e.code} - ${e.message}');
      }

      if (e.code == 'sign_in_failed') {
        throw Exception(
          'Google Sign-In setup incomplete.\n\n'
          'Please ensure:\n'
          '1. SHA-1 fingerprint is added to Firebase\n'
          '2. Google Sign-In is enabled in Firebase Console\n'
          '3. google-services.json is updated\n\n'
          'See AUTHENTICATION_SETUP_GUIDE.md for detailed instructions.',
        );
      }

      throw Exception('Google Sign-In failed: ${e.message}');
    } catch (e) {
      if (kDebugMode) {
        print('Error signing in with Google: $e');
      }
      throw Exception('Google Sign-In failed: $e');
    }
  }

  // Sign in with GitHub (works on both web and mobile)
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
        // Mobile platforms - use OAuth flow with system browser
        return await _signInWithGitHubMobile();
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

  // GitHub OAuth flow for mobile platforms
  Future<UserCredential?> _signInWithGitHubMobile() async {
    try {
      // GitHub OAuth configuration
      const String clientId =
          'YOUR_GITHUB_CLIENT_ID'; // This needs to be configured
      const String redirectUri = 'com.example.diary_app://oauth';
      const String scope = 'user:email';

      // Check if we have a configured client ID
      if (clientId == 'YOUR_GITHUB_CLIENT_ID') {
        throw Exception(
          'GitHub OAuth not configured. Please set up GitHub OAuth app and update the client ID in auth_service.dart',
        );
      }

      // Generate OAuth URL
      final String oauthUrl =
          'https://github.com/login/oauth/authorize'
          '?client_id=$clientId'
          '&redirect_uri=${Uri.encodeComponent(redirectUri)}'
          '&scope=${Uri.encodeComponent(scope)}'
          '&state=${DateTime.now().millisecondsSinceEpoch}';

      if (kDebugMode) {
        print('GitHub OAuth URL: $oauthUrl');
      }

      // For now, show instructions to user
      throw Exception(
        'GitHub sign-in on mobile requires additional setup.\n\n'
        'Steps to enable:\n'
        '1. Create GitHub OAuth App at https://github.com/settings/developers\n'
        '2. Set Authorization callback URL to: $redirectUri\n'
        '3. Update clientId in auth_service.dart\n'
        '4. Add URL scheme to AndroidManifest.xml\n\n'
        'For now, please use Google Sign-In.',
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error in GitHub mobile OAuth: $e');
      }
      rethrow;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
      await _secureStorage.deleteAll();
    } catch (e) {
      if (kDebugMode) {
        print('Error signing out: $e');
      }
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

  // Check Firebase configuration status
  Future<Map<String, dynamic>> checkFirebaseConfiguration() async {
    Map<String, dynamic> status = {
      'firebaseInitialized': false,
      'googleSignInEnabled': false,
      'githubSignInEnabled': false,
      'issues': <String>[],
      'recommendations': <String>[],
    };

    try {
      // Check if Firebase is initialized
      if (Firebase.apps.isNotEmpty) {
        status['firebaseInitialized'] = true;
      } else {
        status['issues'].add('Firebase not initialized');
        status['recommendations'].add(
          'Check firebase_options.dart configuration',
        );
      }

      // Check Google Sign-In configuration
      try {
        await _googleSignIn.isSignedIn();
        status['googleSignInEnabled'] = true;
      } catch (e) {
        status['issues'].add('Google Sign-In not properly configured');
        status['recommendations'].add(
          'Add SHA-1 fingerprint to Firebase Console',
        );
      } // Check GitHub Sign-In (web only)
      if (kIsWeb) {
        // For web, we assume GitHub is available if Firebase is initialized
        // Actual configuration check would require testing the provider
        status['githubSignInEnabled'] = status['firebaseInitialized'];
        if (!status['githubSignInEnabled']) {
          status['recommendations'].add(
            'Enable GitHub provider in Firebase Console',
          );
        }
      } else {
        status['githubSignInEnabled'] = false;
        status['recommendations'].add(
          'GitHub Sign-In requires additional setup for mobile',
        );
      }
    } catch (e) {
      status['issues'].add('Error checking Firebase configuration: $e');
    }

    return status;
  }
}
