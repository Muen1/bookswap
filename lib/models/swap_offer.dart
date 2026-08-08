class SwapOffer {
  final String? id;
  final String bookId;
  final String bookTitle;
  final String fromUserId;
  final String fromUserEmail;
  final String toUserId;
  final String toUserEmail;
  final String status; // 'pending', 'accepted', 'rejected'
  final String message;
  final DateTime createdAt;

  SwapOffer({
    this.id,
    required this.bookId,
    required this.bookTitle,
    required this.fromUserId,
    required this.fromUserEmail,
    required this.toUserId,
    required this.toUserEmail,
    required this.status,
    required this.message,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'bookId': bookId,
      'bookTitle': bookTitle,
      'fromUserId': fromUserId,
      'fromUserEmail': fromUserEmail,
      'toUserId': toUserId,
      'toUserEmail': toUserEmail,
      'status': status,
      'message': message,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }

  static SwapOffer fromMap(Map<String, dynamic> map, String id) {
    return SwapOffer(
      id: id,
      bookId: map['bookId'] ?? '',
      bookTitle: map['bookTitle'] ?? 'Untitled',
      fromUserId: map['fromUserId'] ?? '',
      fromUserEmail: map['fromUserEmail'] ?? '',
      toUserId: map['toUserId'] ?? '',
      toUserEmail: map['toUserEmail'] ?? '',
      status: map['status'] ?? 'pending',
      message: map['message'] ?? '',
      createdAt: map['createdAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['createdAt'])
          : DateTime.now(),
    );
  }
}
