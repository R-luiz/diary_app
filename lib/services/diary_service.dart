import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../models/diary_entry.dart';

class DiaryService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  static const String _collection = 'diary_entries';

  // Get all diary entries for current user
  Stream<List<DiaryEntry>> getDiaryEntries() {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      return Stream.value([]);
    }

    return _firestore
        .collection(_collection)
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map((doc) => DiaryEntry.fromMap(doc.id, doc.data()))
                  .toList(),
        );
  }

  // Get all diary entries for a specific user
  Stream<List<DiaryEntry>> getUserDiaryEntries(String userId) {
    return _firestore
        .collection(_collection)
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map((doc) => DiaryEntry.fromMap(doc.id, doc.data()))
                  .toList(),
        );
  }

  // Create a new diary entry
  Future<String?> createDiaryEntry(DiaryEntry entry) async {
    try {
      final docRef = await _firestore
          .collection(_collection)
          .add(entry.toMap());

      return docRef.id;
    } catch (e) {
      if (kDebugMode) {
        print('Error creating diary entry: $e');
      }
      throw Exception('Failed to create diary entry: $e');
    }
  }

  // Update a diary entry
  Future<void> updateDiaryEntry(DiaryEntry entry) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(entry.id)
          .update(entry.toMap());
    } catch (e) {
      if (kDebugMode) {
        print('Error updating diary entry: $e');
      }
      throw Exception('Failed to update diary entry: $e');
    }
  }

  // Delete a diary entry
  Future<void> deleteDiaryEntry(String entryId) async {
    try {
      await _firestore.collection(_collection).doc(entryId).delete();
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting diary entry: $e');
      }
      throw Exception('Failed to delete diary entry: $e');
    }
  }

  // Get a single diary entry
  Future<DiaryEntry?> getDiaryEntry(String entryId) async {
    try {
      final doc = await _firestore.collection(_collection).doc(entryId).get();

      if (doc.exists) {
        return DiaryEntry.fromMap(doc.id, doc.data()!);
      }
      return null;
    } catch (e) {
      print('Error getting diary entry: $e');
      return null;
    }
  }
}
