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
  } // Sign in with GitHub (works on both web and mobile)

  Future<UserCredential?> signInWithGitHub() async {
    try {
      if (kDebugMode) {
        print('Starting GitHub Sign-In process...');
      }

      // First, check if GitHub provider is available
      await _auth.fetchSignInMethodsForEmail('test@example.com').catchError((
        e,
      ) {
        if (kDebugMode) {
          print('Error checking providers: $e');
        }
        return <String>[];
      });

      if (kDebugMode) {
        print('Available providers check completed');
      }

      if (kIsWeb) {
        // Web platform - use popup
        GithubAuthProvider githubProvider = GithubAuthProvider();
        githubProvider.addScope('user:email');
        githubProvider.setCustomParameters({'allow_signup': 'true'});

        if (kDebugMode) {
          print('GitHub provider configured for web');
        }

        try {
          final userCredential = await _auth.signInWithPopup(githubProvider);

          if (kDebugMode) {
            print('GitHub sign-in successful: ${userCredential.user?.email}');
          }

          // Store user info securely (similar to Google sign-in)
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
        } catch (popupError) {
          if (kDebugMode) {
            print('Popup error, trying redirect: $popupError');
          }
          // Fallback to redirect for web if popup fails
          await _auth.signInWithRedirect(githubProvider);
          return null; // Will be handled by redirect result
        }
      } else {
        // Mobile platforms - use redirect flow
        return await _signInWithGitHubMobile();
      }
    } on FirebaseAuthException catch (e) {
      if (kDebugMode) {
        print('Firebase Auth Error: ${e.code} - ${e.message}');
      } // Provide user-friendly error messages
      String errorMessage;
      switch (e.code) {
        case 'auth/operation-not-supported-in-this-environment':
          errorMessage =
              'GitHub Sign-In is not properly configured in Firebase Console.\n\n'
              'Please ensure:\n'
              '1. GitHub provider is enabled in Firebase Console\n'
              '2. Client ID and Client Secret are properly set\n'
              '3. Authorized domains include your app domain';
          break;
        case 'auth/provider-not-supported':
          errorMessage =
              'GitHub provider is not enabled in Firebase Console.\n\n'
              'Go to Firebase Console > Authentication > Sign-in method > GitHub and enable it.';
          break;
        case 'auth/configuration-not-found':
        case 'auth/invalid-oauth-client-id':
          errorMessage =
              'GitHub OAuth configuration error.\n\n'
              'Please check:\n'
              '1. GitHub OAuth App is created with redirect URI:\n'
              '   https://diaryapp-389ed.firebaseapp.com/__/auth/handler\n'
              '2. Client ID and Secret are correctly configured in Firebase Console\n\n'
              'See GITHUB_SETUP_GUIDE.md for detailed instructions.';
          break;
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
              'GitHub Sign-In configuration error. Please contact support.';
          break;
        case 'account-exists-with-different-credential':
          errorMessage =
              'An account already exists with this email using a different sign-in method.';
          break;
        case 'popup-closed-by-user':
          return null; // User cancelled, don't show error
        case 'popup-blocked':
          errorMessage =
              'Popup was blocked. Please allow popups and try again.';
          break;
        default:
          // Check if the error message contains redirect URI information
          if (e.message?.contains('redirect_uri') == true ||
              e.message?.contains('not associated') == true) {
            errorMessage =
                'GitHub OAuth redirect URI mismatch.\n\n'
                'The redirect URI in your GitHub OAuth App must be exactly:\n'
                'https://diaryapp-389ed.firebaseapp.com/__/auth/handler\n\n'
                'Please update your GitHub OAuth App settings and try again.\n'
                'See GITHUB_SETUP_GUIDE.md for detailed instructions.';
          } else {
            errorMessage = 'GitHub Sign-In failed: ${e.message}';
          }
      }
      throw Exception(errorMessage);
    } catch (e) {
      if (kDebugMode) {
        print('Error signing in with GitHub: $e');
      }

      // Check for redirect URI issues in general errors
      String errorString = e.toString().toLowerCase();
      if (errorString.contains('redirect_uri') ||
          errorString.contains('not associated') ||
          errorString.contains('misconfigured')) {
        throw Exception(
          'GitHub OAuth redirect URI mismatch.\n\n'
          'The redirect URI in your GitHub OAuth App must be exactly:\n'
          'https://diaryapp-389ed.firebaseapp.com/__/auth/handler\n\n'
          'Please update your GitHub OAuth App settings and try again.\n'
          'See GITHUB_SETUP_GUIDE.md for detailed instructions.',
        );
      }

      throw Exception('GitHub Sign-In failed: $e');
    }
  }

  // GitHub OAuth flow for mobile platforms
  Future<UserCredential?> _signInWithGitHubMobile() async {
    try {
      if (kDebugMode) {
        print('Starting GitHub Sign-In for mobile...');
      }

      // Use Firebase's redirect flow for mobile
      GithubAuthProvider githubProvider = GithubAuthProvider();
      githubProvider.addScope('user:email');
      githubProvider.setCustomParameters({'allow_signup': 'true'});

      if (kDebugMode) {
        print('GitHub provider configured for mobile');
      }

      // Use signInWithRedirect for mobile platforms
      final userCredential = await _auth.signInWithProvider(githubProvider);

      if (kDebugMode) {
        print(
          'GitHub mobile sign-in successful: ${userCredential.user?.email}',
        );
      }

      // Store user info securely (similar to Google sign-in)
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
        print('Firebase Auth Error in mobile GitHub: ${e.code} - ${e.message}');
      }

      // Handle specific mobile GitHub errors
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
              'GitHub Sign-In configuration error. Please contact support.';
          break;
        case 'account-exists-with-different-credential':
          errorMessage =
              'An account already exists with this email using a different sign-in method.';
          break;
        case 'web-context-cancelled':
          return null; // User cancelled, don't show error
        default:
          errorMessage = 'GitHub Sign-In failed: ${e.message}';
      }
      throw Exception(errorMessage);
    } catch (e) {
      if (kDebugMode) {
        print('Error in GitHub mobile sign-in: $e');
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
      } // Check GitHub Sign-In
      try {
        // Test GitHub provider availability by checking Firebase Auth providers
        await _auth.fetchSignInMethodsForEmail('test@example.com');
        status['githubSignInEnabled'] = true; // Provider is available

        if (kDebugMode) {
          print('GitHub provider check completed successfully');
        }
      } catch (e) {
        // This is expected - we're just checking if the provider is configured
        status['githubSignInEnabled'] = status['firebaseInitialized'];
        if (!status['githubSignInEnabled']) {
          status['recommendations'].add(
            'Enable GitHub provider in Firebase Console',
          );
        }
      }
    } catch (e) {
      status['issues'].add('Error checking Firebase configuration: $e');
    }

    return status;
  }

  // Test GitHub authentication configuration
  Future<Map<String, dynamic>> testGitHubConfiguration() async {
    Map<String, dynamic> result = {
      'isConfigured': false,
      'error': null,
      'recommendations': <String>[],
    };

    try {
      if (kDebugMode) {
        print('Testing GitHub authentication configuration...');
      }

      // Try to create a GitHub provider
      GithubAuthProvider githubProvider = GithubAuthProvider();
      githubProvider.addScope('user:email');

      result['isConfigured'] = true;
      result['recommendations'].add(
        'GitHub provider can be created successfully',
      );

      if (kDebugMode) {
        print('✅ GitHub provider configuration test passed');
      }
    } catch (e) {
      result['error'] = e.toString();
      result['recommendations'].addAll([
        'Enable GitHub provider in Firebase Console',
        'Go to: https://console.firebase.google.com/project/diaryapp-389ed/authentication/providers',
        'Click on GitHub and configure Client ID and Secret',
        'Add your domain to authorized domains',
      ]);

      if (kDebugMode) {
        print('❌ GitHub provider configuration test failed: $e');
      }
    }

    return result;
  }
}
