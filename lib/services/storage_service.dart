import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io';

import 'package:flutter/foundation.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String> uploadBookImage(File imageFile) async {
    try {
      // Create unique filename
      String fileName = 'book_${DateTime.now().millisecondsSinceEpoch}.jpg';
      
      // Upload to Firebase Storage
      TaskSnapshot snapshot = await _storage
          .ref('book_images/$fileName')
          .putFile(imageFile);

      // Get download URL
      String downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      if (kDebugMode) {
        print('Error uploading image: $e');
      }
      rethrow;
    }
  }

  Future<void> deleteImage(String imageUrl) async {
    try {
      // Extract file path from URL
      Uri uri = Uri.parse(imageUrl);
      String path = uri.path;
      
      // Firebase Storage paths start after the bucket name
      List<String> pathSegments = path.split('/');
      int startIndex = pathSegments.indexWhere((segment) => segment == 'o') + 1;
      String filePath = pathSegments.sublist(startIndex).join('/');
      
      // URL decode the path
      filePath = Uri.decodeFull(filePath);
      
      await _storage.ref(filePath).delete();
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting image: $e');
      }
      // Don't throw error as the book deletion should continue
    }
  }
}

final storageServiceProvider = Provider<StorageService>((ref) => StorageService());
