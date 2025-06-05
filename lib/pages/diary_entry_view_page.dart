import 'package:flutter/material.dart';
import '../models/diary_entry.dart';
import '../widgets/diary_entry_details.dart';
import 'diary_entry_page.dart';

class DiaryEntryViewPage extends StatelessWidget {
  final DiaryEntry entry;

  const DiaryEntryViewPage({super.key, required this.entry});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Diary Entry'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => DiaryEntryPage(entry: entry),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Entry Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    Theme.of(context).colorScheme.secondary.withOpacity(0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          entry.title,
                          style: Theme.of(context).textTheme.headlineMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                      _getFeelingIcon(entry.feeling),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Created: ${_formatDate(entry.createdAt)}',
                        style: TextStyle(color: Colors.grey[600], fontSize: 14),
                      ),
                    ],
                  ),
                  if (entry.createdAt != entry.updatedAt) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.edit, size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          'Updated: ${_formatDate(entry.updatedAt)}',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.email, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        'Author: ${entry.userEmail.isNotEmpty ? entry.userEmail : 'Unknown'}',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.sentiment_satisfied,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Feeling: ${_capitalizeFirst(entry.feeling)}',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Content Section
            Text(
              'Content',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                ),
              ),
              child: Text(
                entry.content,
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(height: 1.6),
              ),
            ),
            const SizedBox(height: 32),

            // Database Fields Summary
            DiaryEntryDetails(entry: entry),

            const SizedBox(height: 16),

            // Action Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DiaryEntryPage(entry: entry),
                    ),
                  );
                },
                icon: const Icon(Icons.edit),
                label: const Text('Edit Entry'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _getFeelingIcon(String feeling) {
    IconData iconData;
    Color color;

    switch (feeling.toLowerCase()) {
      case 'happy':
        iconData = Icons.sentiment_very_satisfied;
        color = Colors.green;
        break;
      case 'sad':
        iconData = Icons.sentiment_very_dissatisfied;
        color = Colors.blue;
        break;
      case 'angry':
        iconData = Icons.sentiment_dissatisfied;
        color = Colors.red;
        break;
      case 'excited':
        iconData = Icons.celebration;
        color = Colors.orange;
        break;
      case 'calm':
        iconData = Icons.self_improvement;
        color = Colors.teal;
        break;
      case 'stressed':
        iconData = Icons.psychology_alt;
        color = Colors.purple;
        break;
      case 'neutral':
      default:
        iconData = Icons.sentiment_neutral;
        color = Colors.grey;
        break;
    }

    return CircleAvatar(
      radius: 25,
      backgroundColor: color.withOpacity(0.2),
      child: Icon(iconData, color: color, size: 25),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} at ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  String _capitalizeFirst(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }
}
