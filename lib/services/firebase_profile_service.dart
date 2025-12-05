import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:developer' as developer;

class FirebaseProfileService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Collection name for user profiles
  static const String _collection = 'user_profiles';

  /// Save or update user's profile photo URL
  Future<void> saveProfilePhoto(int userId, String fotoUrl) async {
    developer.log('FirebaseProfileService: Saving photo for user $userId');
    try {
      await _firestore.collection(_collection).doc(userId.toString()).set({
        'userId': userId,
        'fotoUrl': fotoUrl,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      developer.log('FirebaseProfileService: Photo saved successfully');
    } catch (e) {
      developer.log('FirebaseProfileService: Error saving photo: $e');
      rethrow;
    }
  }

  /// Get user's profile photo URL
  Future<String?> getProfilePhoto(int userId) async {
    try {
      final doc = await _firestore
          .collection(_collection)
          .doc(userId.toString())
          .get();

      if (doc.exists) {
        return doc.data()?['fotoUrl'] as String?;
      }
      return null;
    } catch (e) {
      developer.log('FirebaseProfileService: Error getting photo: $e');
      return null;
    }
  }

  /// Get user's profile photo URL as a stream (real-time updates)
  Stream<String?> getProfilePhotoStream(int userId) {
    return _firestore
        .collection(_collection)
        .doc(userId.toString())
        .snapshots()
        .map((doc) {
          if (doc.exists) {
            return doc.data()?['fotoUrl'] as String?;
          }
          return null;
        });
  }

  /// Get multiple users' profile photos at once
  Future<Map<int, String?>> getMultipleProfilePhotos(List<int> userIds) async {
    final Map<int, String?> results = {};

    try {
      // Firestore limits 'in' queries to 10 items, so we batch
      for (var i = 0; i < userIds.length; i += 10) {
        final batch = userIds.skip(i).take(10).toList();
        final stringIds = batch.map((id) => id.toString()).toList();

        final querySnapshot = await _firestore
            .collection(_collection)
            .where(FieldPath.documentId, whereIn: stringIds)
            .get();

        for (final doc in querySnapshot.docs) {
          final userId = int.tryParse(doc.id);
          if (userId != null) {
            results[userId] = doc.data()['fotoUrl'] as String?;
          }
        }
      }

      // Fill in nulls for users not found
      for (final userId in userIds) {
        if (!results.containsKey(userId)) {
          results[userId] = null;
        }
      }
    } catch (e) {
      developer.log(
        'FirebaseProfileService: Error getting multiple photos: $e',
      );
    }

    return results;
  }
}
