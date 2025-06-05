import 'package:flutter/material.dart';
import '../models/diary_entry.dart';

class DiaryEntryDetails extends StatelessWidget {
  final DiaryEntry entry;

  const DiaryEntryDetails({super.key, required this.entry});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Database Fields Summary',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 16),

            // User's email address
            _buildDetailRow(
              icon: Icons.email,
              label: 'User\'s Email Address',
              value:
                  entry.userEmail.isNotEmpty
                      ? entry.userEmail
                      : 'Not available',
              color: Colors.blue,
            ),

            // Date of entry
            _buildDetailRow(
              icon: Icons.calendar_today,
              label: 'Date of Entry',
              value: _formatFullDate(entry.createdAt),
              color: Colors.green,
            ),

            // Title of entry
            _buildDetailRow(
              icon: Icons.title,
              label: 'Title of Entry',
              value: entry.title,
              color: Colors.orange,
            ),

            // User's feeling of the day
            _buildDetailRow(
              icon: _getFeelingIcon(entry.feeling),
              label: 'User\'s Feeling of the Day',
              value: _capitalizeFirst(entry.feeling),
              color: _getFeelingColor(entry.feeling),
            ),

            // Content of entry
            _buildDetailRow(
              icon: Icons.description,
              label: 'Content of Entry',
              value:
                  entry.content.length > 100
                      ? '${entry.content.substring(0, 100)}...'
                      : entry.content,
              color: Colors.purple,
            ),

            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Additional Metadata:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Entry ID: ${entry.id}',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                  Text(
                    'User ID: ${entry.userId}',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                  Text(
                    'Created: ${_formatFullDate(entry.createdAt)}',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                  Text(
                    'Last Updated: ${_formatFullDate(entry.updatedAt)}',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
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
                  label,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(color: Colors.grey[700], fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getFeelingIcon(String feeling) {
    switch (feeling.toLowerCase()) {
      case 'happy':
        return Icons.sentiment_very_satisfied;
      case 'sad':
        return Icons.sentiment_very_dissatisfied;
      case 'angry':
        return Icons.sentiment_dissatisfied;
      case 'excited':
        return Icons.celebration;
      case 'calm':
        return Icons.self_improvement;
      case 'stressed':
        return Icons.psychology_alt;
      case 'neutral':
      default:
        return Icons.sentiment_neutral;
    }
  }

  Color _getFeelingColor(String feeling) {
    switch (feeling.toLowerCase()) {
      case 'happy':
        return Colors.green;
      case 'sad':
        return Colors.blue;
      case 'angry':
        return Colors.red;
      case 'excited':
        return Colors.orange;
      case 'calm':
        return Colors.teal;
      case 'stressed':
        return Colors.purple;
      case 'neutral':
      default:
        return Colors.grey;
    }
  }

  String _formatFullDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} at ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  String _capitalizeFirst(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }
}
