import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/book.dart';
import '../models/swap_offer.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Book CRUD operations
  Stream<List<Book>> getBooks() {
    return _firestore
        .collection('books')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Book.fromMap(doc.data(), doc.id))
            .toList());
  }

  Stream<List<Book>> getUserBooks(String userId) {
    return _firestore
        .collection('books')
        .where('ownerId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Book.fromMap(doc.data(), doc.id))
            .toList());
  }

  Future<void> addBook(Book book) async {
    await _firestore.collection('books').add(book.toMap());
  }

  Future<void> updateBook(Book book) async {
    await _firestore.collection('books').doc(book.id).update(book.toMap());
  }

  Future<void> deleteBook(String bookId) async {
    await _firestore.collection('books').doc(bookId).delete();
  }

  // Swap operations
  Future<void> createSwapOffer(SwapOffer offer) async {
    await _firestore.collection('swapOffers').add(offer.toMap());
  }

  Stream<List<SwapOffer>> getSwapOffersForUser(String userId) {
    return _firestore
        .collection('swapOffers')
        .where('toUserId', isEqualTo: userId)
        .where('status', isEqualTo: 'pending')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => SwapOffer.fromMap(doc.data(), doc.id))
            .toList());
  }

  Stream<List<SwapOffer>> getMySwapOffers(String userId) {
    return _firestore
        .collection('swapOffers')
        .where('fromUserId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => SwapOffer.fromMap(doc.data(), doc.id))
            .toList());
  }

  Future<void> updateSwapStatus(String offerId, String status) async {
    await _firestore.collection('swapOffers').doc(offerId).update({
      'status': status,
    });
  }
}