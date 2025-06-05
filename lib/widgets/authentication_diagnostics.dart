import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../services/auth_service.dart';

class AuthenticationDiagnostics extends StatefulWidget {
  const AuthenticationDiagnostics({super.key});

  @override
  State<AuthenticationDiagnostics> createState() => _AuthenticationDiagnosticsState();
}

class _AuthenticationDiagnosticsState extends State<AuthenticationDiagnostics> {
  final AuthService _authService = AuthService();
  Map<String, dynamic>? _diagnostics;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _runDiagnostics();
  }

  Future<void> _runDiagnostics() async {
    try {
      final diagnostics = await _authService.checkFirebaseConfiguration();
      if (mounted) {
        setState(() {
          _diagnostics = diagnostics;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _diagnostics = {
            'error': 'Failed to run diagnostics: $e',
            'issues': ['Diagnostics failed'],
            'recommendations': ['Check your Firebase configuration'],
          };
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Authentication Diagnostics'),
        backgroundColor: Colors.blue.shade800,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildDiagnosticsView(),
    );
  }

  Widget _buildDiagnosticsView() {
    if (_diagnostics == null) {
      return const Center(
        child: Text('Failed to load diagnostics'),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status Overview
          _buildStatusCard(),
          const SizedBox(height: 16),
          
          // Issues
          if (_diagnostics!['issues'].isNotEmpty) ...[
            _buildIssuesCard(),
            const SizedBox(height: 16),
          ],
          
          // Recommendations
          if (_diagnostics!['recommendations'].isNotEmpty) ...[
            _buildRecommendationsCard(),
            const SizedBox(height: 16),
          ],
          
          // Actions
          _buildActionsCard(),
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
            Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue.shade700),
                const SizedBox(width: 8),
                Text(
                  'Configuration Status',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildStatusItem('Firebase Initialized', _diagnostics!['firebaseInitialized']),
            _buildStatusItem('Google Sign-In', _diagnostics!['googleSignInEnabled']),
            _buildStatusItem('GitHub Sign-In', _diagnostics!['githubSignInEnabled']),
            const SizedBox(height: 8),
            Text(
              'Platform: ${kIsWeb ? 'Web' : 'Mobile'}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusItem(String label, bool status) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(
            status ? Icons.check_circle : Icons.error,
            color: status ? Colors.green : Colors.red,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(label),
          const Spacer(),
          Text(
            status ? 'OK' : 'ISSUE',
            style: TextStyle(
              color: status ? Colors.green : Colors.red,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIssuesCard() {
    return Card(
      color: Colors.red.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.warning, color: Colors.red.shade700),
                const SizedBox(width: 8),
                Text(
                  'Issues Found',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.red.shade700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...(_diagnostics!['issues'] as List<String>).map(
              (issue) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 2.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.circle, size: 6, color: Colors.red.shade700),
                    const SizedBox(width: 8),
                    Expanded(child: Text(issue)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendationsCard() {
    return Card(
      color: Colors.orange.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.lightbulb_outline, color: Colors.orange.shade700),
                const SizedBox(width: 8),
                Text(
                  'Recommendations',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.orange.shade700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...(_diagnostics!['recommendations'] as List<String>).map(
              (recommendation) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 2.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.circle, size: 6, color: Colors.orange.shade700),
                    const SizedBox(width: 8),
                    Expanded(child: Text(recommendation)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.build, color: Colors.blue.shade700),
                const SizedBox(width: 8),
                Text(
                  'Quick Actions',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _runDiagnostics,
                icon: const Icon(Icons.refresh),
                label: const Text('Run Diagnostics Again'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade700,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                icon: const Icon(Icons.arrow_back),
                label: const Text('Back to Login'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
