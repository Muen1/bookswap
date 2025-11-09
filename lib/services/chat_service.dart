import 'package:bookswap/models/chart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Create or get existing chat room
  Future<String> getOrCreateChatRoom({
    required String user1Id,
    required String user1Email,
    required String user2Id,
    required String user2Email,
    String? swapOfferId,
    String? bookId,
  }) async {
    // Generate consistent room ID (always sorted to avoid duplicates)
    final participants = [user1Id, user2Id]..sort();
    final roomId = participants.join('_');

    try {
      // Check if room already exists
      final existingRoom = await _firestore
          .collection('chatRooms')
          .doc(roomId)
          .get();

      if (!existingRoom.exists) {
        // Create new chat room
        final newRoom = ChatRoom(
          participantIds: [user1Id, user2Id],
          participantEmails: [user1Email, user2Email],
          lastMessage: 'Chat started',
          lastMessageTime: DateTime.now(),
          swapOfferId: swapOfferId,
          bookId: bookId,
          typingUsers: {}, // Initialize typing users map
        );

        await _firestore
            .collection('chatRooms')
            .doc(roomId)
            .set(newRoom.toMap());

        // Add a system message
        await addSystemMessage(
          roomId: roomId,
          message: 'Chat started for book exchange',
        );
      }

      return roomId;
    } catch (e) {
      if (kDebugMode) {
        print('Error creating chat room: $e');
      }
      rethrow;
    }
  }

  // Send a message with status tracking
  Future<void> sendMessage({
    required String chatRoomId,
    required String senderId,
    required String senderEmail,
    required String message,
  }) async {
    try {
      final chatMessage = ChatMessage(
        chatRoomId: chatRoomId,
        senderId: senderId,
        senderEmail: senderEmail,
        message: message,
        timestamp: DateTime.now(),
        status: MessageStatus.sent, // Initial status
      );

      // Add message to subcollection
      final messageRef = await _firestore
          .collection('chatRooms')
          .doc(chatRoomId)
          .collection('messages')
          .add(chatMessage.toMap());

      // Update last message in chat room
      await _firestore
          .collection('chatRooms')
          .doc(chatRoomId)
          .update({
        'lastMessage': message,
        'lastMessageTime': DateTime.now().millisecondsSinceEpoch,
      });

      // Simulate delivery after a short delay (in real app, this would be triggered by recipient's device)
      Future.delayed(const Duration(seconds: 2), () async {
        try {
          await updateMessageStatus(
            messageId: messageRef.id,
            chatRoomId: chatRoomId,
            status: MessageStatus.delivered,
          );
        } catch (e) {
          if (kDebugMode) {
            print('Error simulating delivery: $e');
          }
        }
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error sending message: $e');
      }
      rethrow;
    }
  }

  // Add system message
  Future<void> addSystemMessage({
    required String roomId,
    required String message,
  }) async {
    try {
      final systemMessage = ChatMessage(
        chatRoomId: roomId,
        senderId: 'system',
        senderEmail: 'system',
        message: message,
        timestamp: DateTime.now(),
        type: MessageType.system,
        status: MessageStatus.delivered, // System messages are always delivered
      );

      await _firestore
          .collection('chatRooms')
          .doc(roomId)
          .collection('messages')
          .add(systemMessage.toMap());
    } catch (e) {
      if (kDebugMode) {
        print('Error adding system message: $e');
      }
    }
  }

  // Get chat rooms for a user
  Stream<List<ChatRoom>> getUserChatRooms(String userId) {
    return _firestore
        .collection('chatRooms')
        .where('participantIds', arrayContains: userId)
        .orderBy('lastMessageTime', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ChatRoom.fromMap(doc.data(), doc.id))
            .toList());
  }

  // Get messages for a chat room
  Stream<List<ChatMessage>> getChatMessages(String chatRoomId) {
    return _firestore
        .collection('chatRooms')
        .doc(chatRoomId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ChatMessage.fromMap(doc.data(), doc.id))
            .toList());
  }

  // Mark offer as accepted and notify in chat
  Future<void> notifyOfferAccepted({
    required String chatRoomId,
    required String bookTitle,
  }) async {
    await addSystemMessage(
      roomId: chatRoomId,
      message: '🎉 Swap offer for "$bookTitle" has been accepted! Arrange the book exchange.',
    );
  }

  // Mark offer as rejected and notify in chat
  Future<void> notifyOfferRejected({
    required String chatRoomId,
    required String bookTitle,
  }) async {
    await addSystemMessage(
      roomId: chatRoomId,
      message: '❌ Swap offer for "$bookTitle" has been declined.',
    );
  }

  // Update message status
  Future<void> updateMessageStatus({
    required String messageId,
    required String chatRoomId,
    required MessageStatus status,
    String? readerId, // For read status
  }) async {
    try {
      final updateData = {
        'status': status.toString().split('.').last,
      };

      // If marking as read, add to readBy array
      if (status == MessageStatus.read && readerId != null) {
        updateData['readBy'] = FieldValue.arrayUnion([readerId]) as String;
      }

      await _firestore
          .collection('chatRooms')
          .doc(chatRoomId)
          .collection('messages')
          .doc(messageId)
          .update(updateData);
    } catch (e) {
      if (kDebugMode) {
        print('Error updating message status: $e');
      }
      rethrow;
    }
  }

  // Mark all messages in a chat as read by a user
  Future<void> markAllMessagesAsRead({
    required String chatRoomId,
    required String readerId,
  }) async {
    try {
      // Get all unread messages for this user in the chat room
      final messagesSnapshot = await _firestore
          .collection('chatRooms')
          .doc(chatRoomId)
          .collection('messages')
          .where('status', whereIn: ['sent', 'delivered'])
          .where('senderId', isNotEqualTo: readerId) // Only mark others' messages as read
          .get();

      // Batch update all messages
      final batch = _firestore.batch();
      
      for (final doc in messagesSnapshot.docs) {
        final messageRef = _firestore
            .collection('chatRooms')
            .doc(chatRoomId)
            .collection('messages')
            .doc(doc.id);
        
        batch.update(messageRef, {
          'status': MessageStatus.read.toString().split('.').last,
          'readBy': FieldValue.arrayUnion([readerId]),
        });
      }

      if (messagesSnapshot.docs.isNotEmpty) {
        await batch.commit();
        if (kDebugMode) {
          print('Marked ${messagesSnapshot.docs.length} messages as read');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error marking messages as read: $e');
      }
      rethrow;
    }
  }

  // Set typing status for a user in a chat room
  Future<void> setTypingStatus({
    required String chatRoomId,
    required String userId,
    required bool isTyping,
  }) async {
    try {
      await _firestore
          .collection('chatRooms')
          .doc(chatRoomId)
          .update({
        'typingUsers.$userId': isTyping,
        'lastActivity': DateTime.now().millisecondsSinceEpoch,
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error setting typing status: $e');
      }
      rethrow;
    }
  }

  // Get typing status stream for a chat room
  Stream<Map<String, bool>> getTypingStatus(String chatRoomId) {
    return _firestore
        .collection('chatRooms')
        .doc(chatRoomId)
        .snapshots()
        .map((snapshot) {
      final data = snapshot.data();
      final typingUsers = data?['typingUsers'] as Map<String, dynamic>? ?? {};
      return typingUsers.map((key, value) => MapEntry(key, value as bool));
    });
  }

  // Helper method to automatically stop typing after a delay
  Future<void> setTypingWithAutoStop({
    required String chatRoomId,
    required String userId,
    required bool isTyping,
    Duration autoStopDelay = const Duration(seconds: 3),
  }) async {
    await setTypingStatus(
      chatRoomId: chatRoomId,
      userId: userId,
      isTyping: isTyping,
    );

    // If user started typing, automatically stop after delay
    if (isTyping) {
      Future.delayed(autoStopDelay, () async {
        try {
          // Check if user is still typing before stopping
          final roomDoc = await _firestore
              .collection('chatRooms')
              .doc(chatRoomId)
              .get();
          
          final currentTypingStatus = roomDoc.data()?['typingUsers']?[userId] as bool?;
          
          // Only stop if the user is still marked as typing
          if (currentTypingStatus == true) {
            await setTypingStatus(
              chatRoomId: chatRoomId,
              userId: userId,
              isTyping: false,
            );
          }
        } catch (e) {
          if (kDebugMode) {
            print('Error in auto-stop typing: $e');
          }
        }
      });
    }
  }
}