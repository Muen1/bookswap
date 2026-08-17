import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class StorageService {
  static const String _cloudName = 'x9kfzxge';
  static const String _uploadPreset = 'ml_default';

  Future<String> uploadBookImage(Uint8List imageBytes) async {
    try {
      final url = Uri.parse(
        'https://api.cloudinary.com/v1_1/$_cloudName/image/upload',
      );

      final request = http.MultipartRequest('POST', url)
        ..fields['upload_preset'] = _uploadPreset
        ..files.add(
          http.MultipartFile.fromBytes(
            'file',
            imageBytes,
            filename: 'book_${DateTime.now().millisecondsSinceEpoch}.jpg',
          ),
        );

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(responseBody);
        return data['secure_url'] as String;
      } else {
        throw Exception('Cloudinary upload failed: $responseBody');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error uploading image: $e');
      }
      rethrow;
    }
  }

  Future<void> deleteImage(String imageUrl) async {
    // Deleting from Cloudinary requires a signed request (API secret),
    // which we're intentionally not embedding client-side for security.
    // Old images remain in Cloudinary storage (free tier has generous limits).
    if (kDebugMode) {
      print('Skipping remote delete for: $imageUrl (requires signed request)');
    }
  }
}

final storageServiceProvider = Provider<StorageService>((ref) => StorageService());
