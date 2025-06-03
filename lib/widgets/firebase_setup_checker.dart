import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

class FirebaseSetupChecker extends StatelessWidget {
  final Widget child;

  const FirebaseSetupChecker({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _checkFirebaseSetup(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Initializing Firebase...'),
                ],
              ),
            ),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Firebase Setup Required',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Error: ${snapshot.error}',
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'To fix this:\n'
                      '1. Create a Firebase project\n'
                      '2. Add google-services.json file\n'
                      '3. Update firebase_options.dart\n'
                      '4. Add SHA-1 fingerprint for Google Sign-In',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () {
                        // You could open the setup guide here
                      },
                      child: const Text('View Setup Guide'),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        return child;
      },
    );
  }

  Future<bool> _checkFirebaseSetup() async {
    // Check if Firebase is properly initialized
    if (Firebase.apps.isEmpty) {
      throw Exception('Firebase not initialized');
    }

    final app = Firebase.app();
    final options = app.options;

    // Check for placeholder values
    if (options.projectId.contains('your-project') ||
        options.apiKey.contains('your-') ||
        options.appId.contains('your-')) {
      throw Exception(
        'Firebase configuration contains placeholder values. Please update firebase_options.dart with your real Firebase project configuration.',
      );
    }

    return true;
  }
}
