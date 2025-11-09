import 'package:bookswap/providers/book_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/book.dart';
import '../models/swap_offer.dart';
import '../providers/auth_provider.dart';

class MakeOfferScreen extends ConsumerStatefulWidget {
  final Book book;

  const MakeOfferScreen({super.key, required this.book});

  @override
  ConsumerState<MakeOfferScreen> createState() => _MakeOfferScreenState();
}

class _MakeOfferScreenState extends ConsumerState<MakeOfferScreen> {
  final _messageController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  // Check if user has already made an offer for this book
  Future<bool> _checkExistingOffer() async {
    final firestoreService = ref.read(firestoreServiceProvider);
    final currentUser = ref.read(authStateProvider).value;
    
    if (currentUser == null) return false;
    
    return await firestoreService.hasUserMadeOffer(
      widget.book.id!,
      currentUser.uid,
    );
  }

  // Update the _submitOffer method to check for existing offers
  Future<void> _submitOffer() async {
    if (_messageController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a message for the owner')),
      );
      return;
    }

    // Check for existing offer
    final hasExistingOffer = await _checkExistingOffer();
    if (hasExistingOffer) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You have already made an offer for this book'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final currentUser = ref.read(authStateProvider).value;
      final firestoreService = ref.read(firestoreServiceProvider);

      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      final offer = SwapOffer(
        bookId: widget.book.id!,
        bookTitle: widget.book.title,
        fromUserId: currentUser.uid,
        fromUserEmail: currentUser.email!,
        toUserId: widget.book.ownerId,
        toUserEmail: widget.book.ownerEmail,
        status: 'pending',
        createdAt: DateTime.now(),
        message: _messageController.text.trim(), // Include the message
      );

      await firestoreService.createSwapOffer(offer);

      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Swap offer sent successfully!')),
      );
      
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Make Swap Offer'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Book Info Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.book.title,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text('by ${widget.book.author}'),
                    Text('Condition: ${widget.book.condition}'),
                    Text('Owner: ${widget.book.ownerEmail}'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // Message Input
            Text(
              'Message to Owner:',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _messageController,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: 'Tell the owner why you want to swap for this book...',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            
            // Submit Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submitOffer,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text(
                        'Send Swap Offer',
                        style: TextStyle(fontSize: 16),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}