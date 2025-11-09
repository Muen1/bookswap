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

  // Send a message
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
      );

      // Add message to subcollection
      await _firestore
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
}