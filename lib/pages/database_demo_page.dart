import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/diary_service.dart';
import '../models/diary_entry.dart';

class DatabaseDemoPage extends StatefulWidget {
  const DatabaseDemoPage({super.key});

  @override
  State<DatabaseDemoPage> createState() => _DatabaseDemoPageState();
}

class _DatabaseDemoPageState extends State<DatabaseDemoPage> {
  final AuthService _authService = AuthService();
  final DiaryService _diaryService = DiaryService();

  @override
  Widget build(BuildContext context) {
    final user = _authService.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Database Structure Demo'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Card(
              color: Theme.of(context).colorScheme.primaryContainer,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Diary App Database Structure',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'This app stores all required diary entry elements in Cloud Firestore:',
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Required Fields
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Required Database Fields ✅',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(height: 16),

                    _buildRequiredField(
                      icon: Icons.email,
                      title: '1. User\'s Email Address',
                      description: 'Stored in userEmail field',
                      value: user?.email ?? 'Not logged in',
                      color: Colors.blue,
                    ),

                    _buildRequiredField(
                      icon: Icons.calendar_today,
                      title: '2. Date of Each Entry',
                      description: 'Stored as createdAt timestamp',
                      value: 'Format: ${DateTime.now().toString()}',
                      color: Colors.green,
                    ),

                    _buildRequiredField(
                      icon: Icons.title,
                      title: '3. Title of Each Entry',
                      description: 'Stored in title field',
                      value: 'String field for entry titles',
                      color: Colors.orange,
                    ),

                    _buildRequiredField(
                      icon: Icons.sentiment_satisfied,
                      title: '4. User\'s Feeling of the Day',
                      description: 'Stored in feeling field',
                      value:
                          'Options: happy, sad, angry, excited, calm, stressed, neutral',
                      color: Colors.purple,
                    ),

                    _buildRequiredField(
                      icon: Icons.description,
                      title: '5. Content of the Entry',
                      description: 'Stored in content field',
                      value: 'Text field for diary entry content',
                      color: Colors.teal,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Database Operations
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Implemented Database Operations',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    _buildOperation(
                      icon: Icons.add_circle,
                      title: 'CREATE',
                      description:
                          'Create new diary entries with all required fields',
                      color: Colors.green,
                    ),

                    _buildOperation(
                      icon: Icons.visibility,
                      title: 'READ',
                      description:
                          'View all diary entries with real-time updates',
                      color: Colors.blue,
                    ),

                    _buildOperation(
                      icon: Icons.edit,
                      title: 'UPDATE',
                      description:
                          'Edit existing entries and update timestamps',
                      color: Colors.orange,
                    ),

                    _buildOperation(
                      icon: Icons.delete,
                      title: 'DELETE',
                      description: 'Remove diary entries with confirmation',
                      color: Colors.red,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Current Entries Count
            StreamBuilder<List<DiaryEntry>>(
              stream: _diaryService.getDiaryEntries(),
              builder: (context, snapshot) {
                final entries = snapshot.data ?? [];
                return Card(
                  color: Theme.of(context).colorScheme.secondaryContainer,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Current Database Status',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Icon(Icons.storage, color: Colors.blue),
                            const SizedBox(width: 8),
                            Text(
                              'Total Entries: ${entries.length}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.person, color: Colors.green),
                            const SizedBox(width: 8),
                            Text(
                              'User: ${user?.email ?? "Not logged in"}',
                              style: const TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                        if (entries.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(Icons.schedule, color: Colors.orange),
                              const SizedBox(width: 8),
                              Text(
                                'Latest Entry: ${_formatDate(entries.first.createdAt)}',
                                style: const TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 32),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Back to Profile'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRequiredField({
    required IconData icon,
    required String title,
    required String description,
    required String value,
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOperation({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
