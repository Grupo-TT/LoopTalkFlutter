import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:developer' as developer;

class FirebaseStorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String> uploadImage(File file, String path) async {
    developer.log('FirebaseStorageService: Starting upload to $path');
    developer.log('FirebaseStorageService: File exists: ${file.existsSync()}');
    developer.log(
      'FirebaseStorageService: File size: ${file.lengthSync()} bytes',
    );
    developer.log('FirebaseStorageService: Storage bucket: ${_storage.bucket}');

    try {
      final ref = _storage.ref().child(path);
      developer.log(
        'FirebaseStorageService: Created reference: ${ref.fullPath}',
      );

      // Use putFile with metadata
      final metadata = SettableMetadata(
        contentType: 'image/jpeg',
        customMetadata: {'uploaded': DateTime.now().toIso8601String()},
      );

      final uploadTask = ref.putFile(file, metadata);

      // Listen to upload progress
      uploadTask.snapshotEvents.listen(
        (TaskSnapshot snapshot) {
          final progress =
              (snapshot.bytesTransferred / snapshot.totalBytes) * 100;
          developer.log(
            'FirebaseStorageService: Upload progress: ${progress.toStringAsFixed(2)}%',
          );
        },
        onError: (e) {
          developer.log('FirebaseStorageService: Upload error event: $e');
        },
      );

      developer.log(
        'FirebaseStorageService: Waiting for upload to complete...',
      );

      // Wait for completion with timeout
      final snapshot = await uploadTask.whenComplete(() {
        developer.log('FirebaseStorageService: Upload task completed');
      });

      developer.log('FirebaseStorageService: Getting download URL...');
      final downloadUrl = await snapshot.ref.getDownloadURL();
      developer.log(
        'FirebaseStorageService: Download URL obtained: $downloadUrl',
      );

      return downloadUrl;
    } on FirebaseException catch (e) {
      developer.log(
        'FirebaseStorageService: FirebaseException - Code: ${e.code}, Message: ${e.message}',
      );
      throw Exception('Firebase error (${e.code}): ${e.message}');
    } catch (e) {
      developer.log('FirebaseStorageService: General error: $e');
      throw Exception('Error uploading image: $e');
    }
  }
}
