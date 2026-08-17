import 'package:bookswap/models/chat.dart';
import 'package:bookswap/screens/chat_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/swap_offer.dart';
import '../providers/auth_provider.dart';
import '../providers/book_provider.dart';
import '../providers/chat_provider.dart';

class SwapOffersScreen extends ConsumerWidget {
  const SwapOffersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(authStateProvider).value;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Swap Offers'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Received Offers'),
              Tab(text: 'Sent Offers'),
            ],
          ),
        ),
        body: currentUser == null
            ? const Center(child: Text('Please sign in to view swap offers'))
            : TabBarView(
                children: [
                  // Received Offers Tab
                  _ReceivedOffersTab(userId: currentUser.uid),
                  
                  // Sent Offers Tab
                  _SentOffersTab(userId: currentUser.uid),
                ],
              ),
      ),
    );
  }
}

class _ReceivedOffersTab extends ConsumerWidget {
  final String userId;

  const _ReceivedOffersTab({required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final offersAsync = ref.watch(swapOffersProvider(userId));

    return offersAsync.when(
      data: (offers) {
        if (offers.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.inbox, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'No offers received yet',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: offers.length,
          itemBuilder: (context, index) {
            final offer = offers[index];
            return _ReceivedOfferCard(offer: offer);
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text('Error: $error'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => ref.invalidate(swapOffersProvider(userId)),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

class _SentOffersTab extends ConsumerWidget {
  final String userId;

  const _SentOffersTab({required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final offersAsync = ref.watch(mySwapOffersProvider(userId));

    return offersAsync.when(
      data: (offers) {
        if (offers.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.send, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'No offers sent yet',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                SizedBox(height: 8),
                Text(
                  'Browse books and make your first offer!',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: offers.length,
          itemBuilder: (context, index) {
            final offer = offers[index];
            return _SentOfferCard(offer: offer);
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text('Error: $error'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => ref.invalidate(mySwapOffersProvider(userId)),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReceivedOfferCard extends ConsumerWidget {
  final SwapOffer offer;

  const _ReceivedOfferCard({required this.offer});

  Future<void> _startChat(BuildContext context, WidgetRef ref) async {
    final chatService = ref.read(chatServiceProvider);
    final currentUser = ref.read(authStateProvider).value;

    if (currentUser == null) return;

    try {
      final chatRoomId = await chatService.getOrCreateChatRoom(
        user1Id: currentUser.uid,
        user1Email: currentUser.email!,
        user2Id: offer.fromUserId,
        user2Email: offer.fromUserEmail,
        swapOfferId: offer.id,
        bookId: offer.bookId,
      );

      if (!context.mounted) return;

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => ChatScreen(
            chatRoom: ChatRoom(
              id: chatRoomId,
              participantIds: [currentUser.uid, offer.fromUserId],
              participantEmails: [currentUser.email!, offer.fromUserEmail],
              lastMessage: 'Chat started',
              lastMessageTime: DateTime.now(),
              swapOfferId: offer.id,
              bookId: offer.bookId, typingUsers: {},
            ),
            currentUserId: currentUser.uid,
            currentUserEmail: currentUser.email!,
          ),
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to start chat: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.read(firestoreServiceProvider);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Book Title
            Text(
              offer.bookTitle,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),

            // Offer From
            Text(
              'From: ${offer.fromUserEmail}',
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 8),

            // Message (if any)
            if (offer.message.isNotEmpty) ...[
              Text(
                'Message: ${offer.message}',
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 8),
            ],

            // Status and Actions
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(offer.status),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    offer.status.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Spacer(),

                if (offer.status == 'pending') ...[
                  IconButton(
                    icon: const Icon(Icons.chat),
                    onPressed: () => _startChat(context, ref),
                    tooltip: 'Start Chat',
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () => _handleOfferResponse(
                      context,
                      ref,
                      offer.id!,
                      'accepted',
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                    child: const Text('Accept'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () => _handleOfferResponse(
                      context,
                      ref,
                      offer.id!,
                      'rejected',
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    child: const Text('Reject'),
                  ),
                ] else if (offer.status == 'accepted') ...[
                  IconButton(
                    icon: const Icon(Icons.chat),
                    onPressed: () => _startChat(context, ref),
                    tooltip: 'Continue Chat',
                  ),
                ],
              ],
            ),

            // Date
            const SizedBox(height: 8),
            Text(
              'Received on ${_formatDate(offer.createdAt)}',
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleOfferResponse(
    BuildContext context,
    WidgetRef ref,
    String offerId,
    String status,
  ) async {
    final firestoreService = ref.read(firestoreServiceProvider);

    try {
      await firestoreService.updateSwapStatus(offerId, status);
      
      if (!context.mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Offer $status successfully!'),
          backgroundColor: status == 'accepted' ? Colors.green : Colors.orange,
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'accepted':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

class _SentOfferCard extends ConsumerWidget {
  final SwapOffer offer;

  const _SentOfferCard({required this.offer});

  Future<void> _startChat(BuildContext context, WidgetRef ref) async {
    final chatService = ref.read(chatServiceProvider);
    final currentUser = ref.read(authStateProvider).value;

    if (currentUser == null) return;

    try {
      final chatRoomId = await chatService.getOrCreateChatRoom(
        user1Id: currentUser.uid,
        user1Email: currentUser.email!,
        user2Id: offer.toUserId,
        user2Email: offer.toUserEmail,
        swapOfferId: offer.id,
        bookId: offer.bookId,
      );

      if (!context.mounted) return;

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => ChatScreen(
            chatRoom: ChatRoom(
              id: chatRoomId,
              participantIds: [currentUser.uid, offer.toUserId],
              participantEmails: [currentUser.email!, offer.toUserEmail],
              lastMessage: 'Chat started',
              lastMessageTime: DateTime.now(),
              swapOfferId: offer.id,
              bookId: offer.bookId, typingUsers: {},
            ),
            currentUserId: currentUser.uid,
            currentUserEmail: currentUser.email!,
          ),
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to start chat: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Book Title
            Text(
              offer.bookTitle,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),

            // Sent To
            Text(
              'To: ${offer.toUserEmail}',
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 8),

            // Message (if any)
            if (offer.message.isNotEmpty) ...[
              Text(
                'Your message: ${offer.message}',
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 8),
            ],

            // Status and Chat Button
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(offer.status),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    offer.status.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Spacer(),

                // Chat Button for pending and accepted offers
                if (offer.status == 'pending') ...[
                  IconButton(
                    icon: const Icon(Icons.chat),
                    onPressed: () => _startChat(context, ref),
                    tooltip: 'Start Chat',
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Waiting for response',
                    style: TextStyle(
                      color: Colors.orange,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ] else if (offer.status == 'accepted') ...[
                  IconButton(
                    icon: const Icon(Icons.chat),
                    onPressed: () => _startChat(context, ref),
                    tooltip: 'Continue Chat',
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Offer accepted!',
                    style: TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ] else if (offer.status == 'rejected')
                  const Text(
                    'Offer declined',
                    style: TextStyle(
                      color: Colors.red,
                    ),
                  ),
              ],
            ),

            // Date
            const SizedBox(height: 8),
            Text(
              'Sent on ${_formatDate(offer.createdAt)}',
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'accepted':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}