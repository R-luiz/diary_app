import 'package:flutter/material.dart';
import '../models/diary_entry.dart';
import '../services/diary_service.dart';
import '../services/auth_service.dart';

class DiaryEntryPage extends StatefulWidget {
  final DiaryEntry? entry;

  const DiaryEntryPage({super.key, this.entry});

  @override
  State<DiaryEntryPage> createState() => _DiaryEntryPageState();
}

class _DiaryEntryPageState extends State<DiaryEntryPage> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final DiaryService _diaryService = DiaryService();
  final AuthService _authService = AuthService();
  bool _isLoading = false;
  bool get _isEditing => widget.entry != null;

  String _selectedFeeling = 'neutral';
  final List<Map<String, dynamic>> _feelings = [
    {
      'value': 'happy',
      'label': 'Happy',
      'icon': Icons.sentiment_very_satisfied,
      'color': Colors.green,
    },
    {
      'value': 'sad',
      'label': 'Sad',
      'icon': Icons.sentiment_very_dissatisfied,
      'color': Colors.blue,
    },
    {
      'value': 'angry',
      'label': 'Angry',
      'icon': Icons.sentiment_dissatisfied,
      'color': Colors.red,
    },
    {
      'value': 'excited',
      'label': 'Excited',
      'icon': Icons.celebration,
      'color': Colors.orange,
    },
    {
      'value': 'calm',
      'label': 'Calm',
      'icon': Icons.self_improvement,
      'color': Colors.teal,
    },
    {
      'value': 'stressed',
      'label': 'Stressed',
      'icon': Icons.psychology_alt,
      'color': Colors.purple,
    },
    {
      'value': 'neutral',
      'label': 'Neutral',
      'icon': Icons.sentiment_neutral,
      'color': Colors.grey,
    },
  ];
  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _titleController.text = widget.entry!.title;
      _contentController.text = widget.entry!.content;
      _selectedFeeling = widget.entry!.feeling;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Entry' : 'New Entry'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else
            TextButton(
              onPressed: _saveEntry,
              child: Text(
                _isEditing ? 'Update' : 'Save',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Title field
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  hintText: 'Enter a title for your entry',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.title),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),

              // Feeling dropdown
              DropdownButtonFormField<String>(
                value: _selectedFeeling,
                decoration: const InputDecoration(
                  labelText: 'How are you feeling?',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.sentiment_satisfied),
                ),
                items:
                    _feelings.map((feeling) {
                      return DropdownMenuItem<String>(
                        value: feeling['value'],
                        child: Row(
                          children: [
                            Icon(
                              feeling['icon'],
                              color: feeling['color'],
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(feeling['label']),
                          ],
                        ),
                      );
                    }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedFeeling = value!;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select how you\'re feeling';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Content field
              Expanded(
                child: TextFormField(
                  controller: _contentController,
                  decoration: const InputDecoration(
                    labelText: 'Content',
                    hintText: 'Write your thoughts here...',
                    border: OutlineInputBorder(),
                    alignLabelWithHint: true,
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter some content';
                    }
                    return null;
                  },
                  maxLines: null,
                  expands: true,
                  textAlignVertical: TextAlignVertical.top,
                ),
              ),

              const SizedBox(height: 16),

              // Entry info (for editing)
              if (_isEditing)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Created: ${_formatDate(widget.entry!.createdAt)}\n'
                          'Last updated: ${_formatDate(widget.entry!.updatedAt)}',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} at ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _saveEntry() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final title = _titleController.text.trim();
      final content = _contentController.text.trim();
      final userId = _authService.currentUser?.uid;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      if (_isEditing) {
        // Update existing entry
        final updatedEntry = widget.entry!.copyWith(
          title: title,
          content: content,
          feeling: _selectedFeeling,
          updatedAt: DateTime.now(),
        );
        await _diaryService.updateDiaryEntry(updatedEntry);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Entry updated successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        // Create new entry
        final userEmail = _authService.currentUser?.email ?? '';
        final newEntry = DiaryEntry(
          id: '', // Will be set by Firestore
          title: title,
          content: content,
          feeling: _selectedFeeling,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          userId: userId,
          userEmail: userEmail,
        );
        await _diaryService.createDiaryEntry(newEntry);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Entry created successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving entry: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
