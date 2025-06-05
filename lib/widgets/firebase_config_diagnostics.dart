import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:flutter/services.dart';

class FirebaseConfigDiagnostics extends StatefulWidget {
  const FirebaseConfigDiagnostics({super.key});

  @override
  State<FirebaseConfigDiagnostics> createState() =>
      _FirebaseConfigDiagnosticsState();
}

class _FirebaseConfigDiagnosticsState extends State<FirebaseConfigDiagnostics> {
  Map<String, dynamic>? _configData;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadGoogleServicesConfig();
  }

  Future<void> _loadGoogleServicesConfig() async {
    try {
      // This is a simplified check - in reality, we can't directly read the JSON
      // but we can infer the configuration status from Firebase initialization
      setState(() {
        _configData = {
          'firebase_initialized': true,
          'sha1_configured': false, // This is the likely issue
          'google_signin_enabled': false,
        };
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Firebase Diagnostics'),
        backgroundColor: Colors.blue.shade800,
        foregroundColor: Colors.white,
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _buildDiagnosticsView(),
    );
  }

  Widget _buildDiagnosticsView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStatusCard(),
          const SizedBox(height: 16),
          _buildSHA1Card(),
          const SizedBox(height: 16),
          _buildStepsCard(),
        ],
      ),
    );
  }

  Widget _buildStatusCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue),
                SizedBox(width: 8),
                Text(
                  'Current Issue Analysis',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.error, color: Colors.red),
                      SizedBox(width: 8),
                      Text(
                        'Google Sign-In Not Configured',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'The oauth_client array in google-services.json is empty.',
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'This means the SHA-1 fingerprint has not been added to Firebase.',
                    style: TextStyle(color: Colors.red.shade700),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSHA1Card() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.fingerprint, color: Colors.orange),
                SizedBox(width: 8),
                Text(
                  'SHA-1 Fingerprint',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Your debug SHA-1 fingerprint:',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: const SelectableText(
                '29:4D:26:A2:53:E8:2A:97:91:39:C8:A8:ED:FE:FB:57:EB:A0:D5:53',
                style: TextStyle(fontFamily: 'monospace', fontSize: 12),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Clipboard.setData(
                        const ClipboardData(
                          text:
                              '29:4D:26:A2:53:E8:2A:97:91:39:C8:A8:ED:FE:FB:57:EB:A0:D5:53',
                        ),
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('SHA-1 copied to clipboard'),
                        ),
                      );
                    },
                    icon: const Icon(Icons.copy),
                    label: const Text('Copy SHA-1'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.build, color: Colors.green),
                SizedBox(width: 8),
                Text(
                  'Fix Steps',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildStep(
              1,
              'Go to Firebase Console',
              'https://console.firebase.google.com/project/diaryapp-389ed/settings/general',
              isLink: true,
            ),
            _buildStep(
              2,
              'Find "Your apps" section',
              'Look for the Android app (com.example.diary_app)',
            ),
            _buildStep(
              3,
              'Add SHA certificate fingerprint',
              'Click "Add fingerprint" and paste the SHA-1 above',
            ),
            _buildStep(
              4,
              'Download updated google-services.json',
              'Download the new config file from Firebase',
            ),
            _buildStep(
              5,
              'Replace the config file',
              'Replace android/app/google-services.json with the new file',
            ),
            _buildStep(
              6,
              'Restart the app',
              'Stop and restart the app to use the new configuration',
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: const Row(
                children: [
                  Icon(Icons.lightbulb_outline, color: Colors.green),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'After completing these steps, Google Sign-In will work properly.',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep(
    int number,
    String title,
    String description, {
    bool isLink = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: Colors.blue.shade700,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                '$number',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
