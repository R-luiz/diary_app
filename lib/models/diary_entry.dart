import 'package:cloud_firestore/cloud_firestore.dart';

class DiaryEntry {
  final String id;
  final String title;
  final String content;
  final String feeling; // User's feeling of the day
  final DateTime createdAt; // Date of each entry
  final DateTime updatedAt;
  final String userId;
  final String userEmail; // The user's email address

  DiaryEntry({
    required this.id,
    required this.title,
    required this.content,
    required this.feeling,
    required this.createdAt,
    required this.updatedAt,
    required this.userId,
    required this.userEmail,
  }); // Convert DiaryEntry to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'content': content,
      'feeling': feeling,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'userId': userId,
      'userEmail': userEmail,
    };
  }

  // Create DiaryEntry from Firestore document
  factory DiaryEntry.fromMap(String id, Map<String, dynamic> map) {
    return DiaryEntry(
      id: id,
      title: map['title'] ?? '',
      content: map['content'] ?? '',
      feeling: map['feeling'] ?? 'neutral', // Default feeling
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: (map['updatedAt'] as Timestamp).toDate(),
      userId: map['userId'] ?? '',
      userEmail: map['userEmail'] ?? '',
    );
  } // Create a copy with updated fields
  DiaryEntry copyWith({
    String? title,
    String? content,
    String? feeling,
    DateTime? updatedAt,
  }) {
    return DiaryEntry(
      id: id,
      title: title ?? this.title,
      content: content ?? this.content,
      feeling: feeling ?? this.feeling,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      userId: userId,
      userEmail: userEmail,
    );
  }
}
