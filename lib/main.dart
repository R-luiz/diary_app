import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:mcp_toolkit/mcp_toolkit.dart';
import 'dart:async';
import 'firebase_options.dart';
import 'services/auth_service.dart';
import 'pages/login_page.dart';
import 'pages/profile_page.dart';

void main() async {
  runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      // Initialize MCP Toolkit
      if (kDebugMode) {
        try {
          MCPToolkitBinding.instance
            ..initialize() // Initializes the Toolkit
            ..initializeFlutterToolkit(); // Adds Flutter related methods to the MCP server
          print('✅ MCP Toolkit initialized successfully');
        } catch (e) {
          print('❌ MCP Toolkit initialization failed: $e');
        }
      }

      bool firebaseInitialized = false;
      String? initError;

      try {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
        firebaseInitialized = true;
        if (kDebugMode) {
          print('✅ Firebase initialized successfully');
        }
      } catch (e) {
        initError = e.toString();
        if (kDebugMode) {
          print('❌ Firebase initialization failed: $e');
        }
      }

      runApp(
        MyApp(firebaseInitialized: firebaseInitialized, initError: initError),
      );
    },
    (error, stack) {
      // Critical: Handle zone errors for MCP server error reporting
      if (kDebugMode) {
        MCPToolkitBinding.instance.handleZoneError(error, stack);
      }
    },
  );
}

class MyApp extends StatelessWidget {
  final bool firebaseInitialized;
  final String? initError;

  const MyApp({super.key, required this.firebaseInitialized, this.initError});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My Diary',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
        appBarTheme: const AppBarTheme(centerTitle: true, elevation: 0),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ),
      home:
          firebaseInitialized
              ? const AuthWrapper()
              : FirebaseErrorPage(error: initError ?? 'Unknown error'),
      debugShowCheckedModeBanner: false,
    );
  }
}

class FirebaseErrorPage extends StatelessWidget {
  final String error;

  const FirebaseErrorPage({super.key, required this.error});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Setup Required'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.warning, size: 64, color: Colors.orange),
            const SizedBox(height: 16),
            const Text(
              'Firebase Setup Required',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Text(
                'Error: $error',
                style: TextStyle(color: Colors.red.shade700),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Your SHA-1 fingerprint:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(4),
              ),
              child: const SelectableText(
                '29:4D:26:A2:53:E8:2A:97:91:39:C8:A8:ED:FE:FB:57:EB:A0:D5:53',
                style: TextStyle(fontFamily: 'monospace'),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'To fix this:\n'
              '1. Go to Firebase Console\n'
              '2. Add the SHA-1 fingerprint above\n'
              '3. Download updated google-services.json\n'
              '4. Replace android/app/google-services.json\n'
              '5. Restart the app',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                // Restart the app
                main();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: _authService.authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Checking authentication...'),
                ],
              ),
            ),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error, color: Colors.red, size: 64),
                    const SizedBox(height: 16),
                    const Text(
                      'Authentication Error',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red.shade200),
                      ),
                      child: Text(
                        '${snapshot.error}',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.red.shade700),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        // Force rebuild
                        setState(() {});
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
          );
        }
        if (snapshot.hasData && snapshot.data != null) {
          return const ProfilePage();
        } else {
          return const LoginPage();
        }
      },
    );
  }
}
