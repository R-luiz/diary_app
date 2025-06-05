import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import '../services/auth_service.dart';

class DebugPage extends StatefulWidget {
  const DebugPage({super.key});

  @override
  State<DebugPage> createState() => _DebugPageState();
}

class _DebugPageState extends State<DebugPage> {
  final AuthService _authService = AuthService();
  Map<String, dynamic>? _configStatus;
  bool _isLoading = false;
  String _configInfo = 'Loading configuration...';
  String _redirectUri = '';

  @override
  void initState() {
    super.initState();
    _checkConfiguration();
    _loadConfigInfo();
  }

  Future<void> _checkConfiguration() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final status = await _authService.checkFirebaseConfiguration();
      setState(() {
        _configStatus = status;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _configStatus = {'error': e.toString()};
        _isLoading = false;
      });
    }
  }

  void _loadConfigInfo() {
    try {
      final auth = FirebaseAuth.instance;
      final app = auth.app;

      // Get the expected redirect URI
      _redirectUri = 'https://${app.options.authDomain}/__/auth/handler';

      setState(() {
        _configInfo = '''
Firebase Configuration:
• Project ID: ${app.options.projectId}
• Auth Domain: ${app.options.authDomain}
• API Key: ${app.options.apiKey.substring(0, 8)}...

Required GitHub OAuth Settings:
• Redirect URI: $_redirectUri

Current Auth State:
• User: ${auth.currentUser?.email ?? 'Not signed in'}
• Providers: ${auth.currentUser?.providerData.map((p) => p.providerId).join(', ') ?? 'None'}
''';
      });
    } catch (e) {
      setState(() {
        _configInfo = 'Error loading config: $e';
      });
    }
  }

  void _copyRedirectUri() {
    Clipboard.setData(ClipboardData(text: _redirectUri));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Redirect URI copied to clipboard!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Debug Configuration'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Firebase Project Info
            _buildInfoCard('Firebase Project Information', [
              'Project ID: diaryapp-389ed',
              'Auth Domain: diaryapp-389ed.firebaseapp.com',
              'Required Redirect URI:',
              'https://diaryapp-389ed.firebaseapp.com/__/auth/handler',
            ], Colors.blue),
            const SizedBox(height: 16),

            // Configuration Status
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else if (_configStatus != null)
              _buildConfigurationStatus(),

            const SizedBox(height: 16),

            // Firebase & GitHub OAuth Configuration
            const Text(
              'Firebase & GitHub OAuth Configuration',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: SelectableText(
                _configInfo,
                style: const TextStyle(fontFamily: 'monospace'),
              ),
            ),
            const SizedBox(height: 20),
            if (_redirectUri.isNotEmpty) ...[
              const Text(
                'GitHub OAuth App Setup:',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  border: Border.all(color: Colors.red),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Your GitHub OAuth App must have this EXACT redirect URI:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    SelectableText(
                      _redirectUri,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton.icon(
                      onPressed: _copyRedirectUri,
                      icon: const Icon(Icons.copy),
                      label: const Text('Copy Redirect URI'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Card(
                color: Colors.yellow,
                child: Padding(
                  padding: EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '📋 Setup Checklist:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8),
                      Text('1. Go to GitHub Developer Settings'),
                      Text('2. Create new OAuth App or edit existing'),
                      Text(
                        '3. Set Authorization callback URL to the red URI above',
                      ),
                      Text('4. Copy Client ID & Secret to Firebase Console'),
                      Text('5. Enable GitHub provider in Firebase'),
                      Text('6. Wait 5-10 minutes for changes to take effect'),
                    ],
                  ),
                ),
              ),
            ],

            // Quick Actions
            _buildQuickActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(String title, List<String> items, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 8),
            ...items.map(
              (item) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Text(item, style: const TextStyle(fontSize: 14)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConfigurationStatus() {
    final status = _configStatus!;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Configuration Status',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _buildStatusItem(
              'Firebase Initialized',
              status['firebaseInitialized'] ?? false,
            ),
            _buildStatusItem(
              'Google Sign-In Enabled',
              status['googleSignInEnabled'] ?? false,
            ),
            _buildStatusItem(
              'GitHub Sign-In Enabled',
              status['githubSignInEnabled'] ?? false,
            ),

            // Issues
            if (status['issues']?.isNotEmpty == true) ...[
              const SizedBox(height: 16),
              const Text(
                'Issues Found:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
              ...status['issues'].map<Widget>(
                (issue) => Padding(
                  padding: const EdgeInsets.only(left: 16, top: 4),
                  child: Text(
                    '• $issue',
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              ),
            ],

            // Recommendations
            if (status['recommendations']?.isNotEmpty == true) ...[
              const SizedBox(height: 16),
              const Text(
                'Recommendations:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
              ),
              ...status['recommendations'].map<Widget>(
                (rec) => Padding(
                  padding: const EdgeInsets.only(left: 16, top: 4),
                  child: Text(
                    '• $rec',
                    style: const TextStyle(color: Colors.orange),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusItem(String label, bool isEnabled) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            isEnabled ? Icons.check_circle : Icons.cancel,
            color: isEnabled ? Colors.green : Colors.red,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(label),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Quick Actions',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _checkConfiguration,
                icon: const Icon(Icons.refresh),
                label: const Text('Refresh Configuration'),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  if (kDebugMode) {
                    print('Testing GitHub configuration...');
                  }
                  _testGitHubAuth();
                },
                icon: const Icon(Icons.bug_report),
                label: const Text('Test GitHub Auth'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _testGitHubAuth() async {
    try {
      await _authService.signInWithGitHub();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('GitHub authentication successful!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('GitHub auth failed: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }
}
