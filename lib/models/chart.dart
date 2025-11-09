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

  ChatMessage({
    this.id,
    required this.chatRoomId,
    required this.senderId,
    required this.senderEmail,
    required this.message,
    required this.timestamp,
    this.type = MessageType.text,
  });

  Map<String, dynamic> toMap() {
    return {
      'chatRoomId': chatRoomId,
      'senderId': senderId,
      'senderEmail': senderEmail,
      'message': message,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'type': type.toString().split('.').last,
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
    );
  }

  bool isSentBy(String userId) => senderId == userId;
}

enum MessageType {
  text,
  system, 
}