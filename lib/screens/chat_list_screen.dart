import 'package:bookswap/models/chat.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import '../providers/chat_provider.dart';

class ChatListScreen extends ConsumerWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(authStateProvider).value;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages'),
      ),
      body: currentUser == null
          ? const Center(child: Text('Please sign in to view messages'))
          : ref.watch(userChatRoomsProvider(currentUser.uid)).when(
                data: (chatRooms) {
                  if (chatRooms.isEmpty) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.chat, size: 64, color: Colors.grey),
                          SizedBox(height: 16),
                          Text(
                            'No messages yet',
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Start a chat by making or receiving a swap offer',
                            style: TextStyle(color: Colors.grey),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: chatRooms.length,
                    itemBuilder: (context, index) {
                      final chatRoom = chatRooms[index];
                      return _ChatRoomCard(
                        chatRoom: chatRoom,
                        currentUserId: currentUser.uid,
                        currentUserEmail: currentUser.email!,
                      );
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
                        onPressed: () => ref.invalidate(userChatRoomsProvider(currentUser.uid)),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              ),
    );
  }
}

class _ChatRoomCard extends StatelessWidget {
  final ChatRoom chatRoom;
  final String currentUserId;
  final String currentUserEmail;

  const _ChatRoomCard({
    required this.chatRoom,
    required this.currentUserId,
    required this.currentUserEmail,
  });

  @override
  Widget build(BuildContext context) {
    final otherParticipantEmail = chatRoom.getOtherParticipantEmail(currentUserEmail);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue,
          child: Text(
            otherParticipantEmail[0].toUpperCase(),
            style: const TextStyle(color: Colors.white),
          ),
        ),
        title: Text(
          otherParticipantEmail,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          chatRoom.lastMessage,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: Colors.grey[600],
          ),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              _formatTime(chatRoom.lastMessageTime),
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 4),
            if (_isToday(chatRoom.lastMessageTime))
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  'NEW',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => ChatScreen(
                chatRoom: chatRoom,
                currentUserId: currentUserId,
                currentUserEmail: currentUserEmail,
              ),
            ),
          );
        },
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

    if (messageDate == today) {
      return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } else if (messageDate == today.subtract(const Duration(days: 1))) {
      return 'Yesterday';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }

  bool _isToday(DateTime dateTime) {
    final now = DateTime.now();
    return dateTime.year == now.year &&
        dateTime.month == now.month &&
        dateTime.day == now.day;
  }
}

class ChatScreen extends StatelessWidget {
  final ChatRoom chatRoom;
  final String currentUserId;
  final String currentUserEmail;

  const ChatScreen({
    super.key,
    required this.chatRoom,
    required this.currentUserId,
    required this.currentUserEmail,
  });

  @override
  Widget build(BuildContext context) {
    final otherEmail = chatRoom.getOtherParticipantEmail(currentUserEmail);
    return Scaffold(
      appBar: AppBar(
        title: Text(otherEmail),
      ),
      body: Center(
        child: Text('Chat with $otherEmail'),
      ),
    );
  }
}