class ChatRoom {
  final String? id;
  final List<String> participantIds;
  final List<String> participantEmails;
  final String lastMessage;
  final DateTime lastMessageTime;
  final String? swapOfferId; 
  final String? bookId; 

  ChatRoom({
    this.id,
    required this.participantIds,
    required this.participantEmails,
    required this.lastMessage,
    required this.lastMessageTime,
    this.swapOfferId,
    this.bookId,
  });

  Map<String, dynamic> toMap() {
    return {
      'participantIds': participantIds,
      'participantEmails': participantEmails,
      'lastMessage': lastMessage,
      'lastMessageTime': lastMessageTime.millisecondsSinceEpoch,
      'swapOfferId': swapOfferId,
      'bookId': bookId,
    };
  }

  static ChatRoom fromMap(Map<String, dynamic> map, String id) {
    return ChatRoom(
      id: id,
      participantIds: List<String>.from(map['participantIds']),
      participantEmails: List<String>.from(map['participantEmails']),
      lastMessage: map['lastMessage'],
      lastMessageTime: DateTime.fromMillisecondsSinceEpoch(map['lastMessageTime']),
      swapOfferId: map['swapOfferId'],
      bookId: map['bookId'],
    );
  }

  String getOtherParticipantId(String currentUserId) {
    return participantIds.firstWhere((id) => id != currentUserId);
  }

  String getOtherParticipantEmail(String currentUserEmail) {
    return participantEmails.firstWhere((email) => email != currentUserEmail);
  }
}

class ChatMessage {
  final String? id;
  final String chatRoomId;
  final String senderId;
  final String senderEmail;
  final String message;
  final DateTime timestamp;
  final MessageType type;
  final MessageStatus status; // Add this field
  final List<String> readBy; // Add this field - list of user IDs who read the message

  ChatMessage({
    this.id,
    required this.chatRoomId,
    required this.senderId,
    required this.senderEmail,
    required this.message,
    required this.timestamp,
    this.type = MessageType.text,
    this.status = MessageStatus.sent, // Default status
    this.readBy = const [], // Initialize as empty list
  });

  Map<String, dynamic> toMap() {
    return {
      'chatRoomId': chatRoomId,
      'senderId': senderId,
      'senderEmail': senderEmail,
      'message': message,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'type': type.toString().split('.').last,
      'status': status.toString().split('.').last, // Add status
      'readBy': readBy, // Add readBy
    };
  }

  static ChatMessage fromMap(Map<String, dynamic> map, String id) {
    return ChatMessage(
      id: id,
      chatRoomId: map['chatRoomId'],
      senderId: map['senderId'],
      senderEmail: map['senderEmail'],
      message: map['message'],
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp']),
      type: MessageType.values.firstWhere(
        (e) => e.toString().split('.').last == map['type'],
        orElse: () => MessageType.text,
      ),
      status: MessageStatus.values.firstWhere(
        (e) => e.toString().split('.').last == map['status'],
        orElse: () => MessageStatus.sent,
      ),
      readBy: map['readBy'] != null ? List<String>.from(map['readBy']) : [],
    );
  }

  bool isSentBy(String userId) => senderId == userId;
  
  // Helper methods for status
  bool isDelivered() => status == MessageStatus.delivered;
  bool isRead() => status == MessageStatus.read;
  
  // Copy with method for updating status
  ChatMessage copyWith({
    String? id,
    String? chatRoomId,
    String? senderId,
    String? senderEmail,
    String? message,
    DateTime? timestamp,
    MessageType? type,
    MessageStatus? status,
    List<String>? readBy,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      chatRoomId: chatRoomId ?? this.chatRoomId,
      senderId: senderId ?? this.senderId,
      senderEmail: senderEmail ?? this.senderEmail,
      message: message ?? this.message,
      timestamp: timestamp ?? this.timestamp,
      type: type ?? this.type,
      status: status ?? this.status,
      readBy: readBy ?? this.readBy,
    );
  }
}

enum MessageType {
  text,
  system,
}

// Add this new enum for message status
enum MessageStatus {
  sent,      // Message sent but not delivered to recipient's device
  delivered, // Message delivered to recipient's device
  read,      // Message read by recipient
}