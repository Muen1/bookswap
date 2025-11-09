class ChatRoom {
  final String? id;
  final List<String> participantIds;
  final List<String> participantEmails;
  final String lastMessage;
  final DateTime lastMessageTime;
  final String? swapOfferId; 
  final String? bookId;
  final String bookTitle;
  final Map<String, bool> typingUsers;
  final DateTime createdAt;

  ChatRoom({
    this.id,
    required this.participantIds,
    required this.participantEmails,
    required this.lastMessage,
    required this.lastMessageTime,
    this.swapOfferId,
    this.bookId,
    required this.bookTitle,
    this.typingUsers = const {},
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'participantIds': participantIds,
      'participantEmails': participantEmails,
      'lastMessage': lastMessage,
      'lastMessageTime': lastMessageTime.millisecondsSinceEpoch,
      'swapOfferId': swapOfferId,
      'bookId': bookId,
      'bookTitle': bookTitle,
      'typingUsers': typingUsers,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }

  static ChatRoom fromMap(Map<String, dynamic> map, String id) {
    return ChatRoom(
      id: id,
      participantIds: List<String>.from(map['participantIds']),
      participantEmails: List<String>.from(map['participantEmails']),
      lastMessage: map['lastMessage'] ?? '',
      lastMessageTime: DateTime.fromMillisecondsSinceEpoch(map['lastMessageTime']),
      swapOfferId: map['swapOfferId'],
      bookId: map['bookId'],
      bookTitle: map['bookTitle'] ?? 'Unknown Book',
      typingUsers: Map<String, bool>.from(map['typingUsers'] ?? {}),
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
    );
  }

  String getOtherParticipantId(String currentUserId) {
    return participantIds.firstWhere((id) => id != currentUserId);
  }

  String getOtherParticipantEmail(String currentUserEmail) {
    return participantEmails.firstWhere((email) => email != currentUserEmail);
  }

  ChatRoom copyWith({
    String? lastMessage,
    DateTime? lastMessageTime,
    Map<String, bool>? typingUsers,
  }) {
    return ChatRoom(
      id: id,
      participantIds: participantIds,
      participantEmails: participantEmails,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageTime: lastMessageTime ?? this.lastMessageTime,
      swapOfferId: swapOfferId,
      bookId: bookId,
      bookTitle: bookTitle,
      typingUsers: typingUsers ?? this.typingUsers,
      createdAt: createdAt,
    );
  }
}