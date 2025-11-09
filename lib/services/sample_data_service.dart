import 'package:cloud_firestore/cloud_firestore.dart';

class SampleDataService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addSampleBooks(String userId, String userEmail) async {
    // Check if user already has books to avoid duplicates
    final userBooks = await _firestore
        .collection('books')
        .where('ownerId', isEqualTo: userId)
        .get();

    if (userBooks.docs.isNotEmpty) {
      return; // User already has books
    }

    final sampleBooks = [
      {
        'title': 'Introduction to Algorithms',
        'author': 'Thomas H. Cormen',
        'condition': 'Good',
        'imageUrl': null,
        'ownerId': userId,
        'ownerEmail': userEmail,
        'createdAt': DateTime.now().millisecondsSinceEpoch,
        'swapFor': 'Any programming book',
      },
      {
        'title': 'The Nightingale',
        'author': 'Kristin Hannah',
        'condition': 'Excellent',
        'imageUrl': null,
        'ownerId': userId,
        'ownerEmail': userEmail,
        'createdAt': DateTime.now().millisecondsSinceEpoch,
        'swapFor': 'Historical fiction',
      },
      {
        'title': 'Chemistry: The Central Science',
        'author': 'Theodore Brown',
        'condition': 'Fair',
        'imageUrl': null,
        'ownerId': userId,
        'ownerEmail': userEmail,
        'createdAt': DateTime.now().millisecondsSinceEpoch,
        'swapFor': 'Physics or Biology textbook',
      },
    ];

    // Add sample books to Firestore
    for (final bookData in sampleBooks) {
      await _firestore.collection('books').add(bookData);
    }
  }

  Future<void> ensureSampleData(String userId, String userEmail) async {
    final booksCount = await _firestore
        .collection('books')
        .where('ownerId', isEqualTo: userId)
        .get()
        .then((snapshot) => snapshot.docs.length);

    if (booksCount == 0) {
      await addSampleBooks(userId, userEmail);
    }
  }
}