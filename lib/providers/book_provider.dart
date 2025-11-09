import 'package:bookswap/models/book.dart';
import 'package:bookswap/models/swap_offer.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/firestore_service.dart';

final firestoreServiceProvider = Provider<FirestoreService>((ref) => FirestoreService());

final booksProvider = StreamProvider((ref) {
  final service = ref.read(firestoreServiceProvider);
  return service.getBooks();
});

final userBooksProvider = StreamProvider.family<List<Book>, String>((ref, userId) {
  final service = ref.read(firestoreServiceProvider);
  return service.getUserBooks(userId);
});

final swapOffersProvider = StreamProvider.family<List<SwapOffer>, String>((ref, userId) {
  final service = ref.read(firestoreServiceProvider);
  return service.getSwapOffersForUser(userId);
});

final mySwapOffersProvider = StreamProvider.family<List<SwapOffer>, String>((ref, userId) {
  final service = ref.read(firestoreServiceProvider);
  return service.getMySwapOffers(userId);
});

final pendingOffersCountProvider = StreamProvider.family<int, String>((ref, userId) {
  final service = ref.read(firestoreServiceProvider);
  return service.getSwapOffersForUser(userId).map((offers) {
    return offers.where((offer) => offer.status == 'pending').length;
  });
});