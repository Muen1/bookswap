import 'package:bookswap/models/chat.dart';


class ChatMessage {
  final String? id;
  final String chatRoomId;
  final String senderId;
  final String senderEmail;
  final String message;
  final DateTime timestamp;
  final MessageStatus status;
  final MessageType type;
  final Map<String, String> reactions; // userId -> emoji
  final String? replyToMessageId;
  final bool isEdited;

  ChatMessage({
    this.id,
    required this.chatRoomId,
    required this.senderId,
    required this.senderEmail,
    required this.message,
    required this.timestamp,
    this.status = MessageStatus.sent,
    this.type = MessageType.text,
    this.reactions = const {},
    this.replyToMessageId,
    this.isEdited = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'chatRoomId': chatRoomId,
      'senderId': senderId,
      'senderEmail': senderEmail,
      'message': message,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'status': status.toString().split('.').last,
      'type': type.toString().split('.').last,
      'reactions': reactions,
      'replyToMessageId': replyToMessageId,
      'isEdited': isEdited,
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
      status: _parseMessageStatus(map['status']),
      type: _parseMessageType(map['type']),
      reactions: Map<String, String>.from(map['reactions'] ?? {}),
      replyToMessageId: map['replyToMessageId'],
      isEdited: map['isEdited'] ?? false,
    );
  }

  static MessageStatus _parseMessageStatus(String status) {
    switch (status) {
      case 'sent':
        return MessageStatus.sent;
      case 'delivered':
        return MessageStatus.delivered;
      case 'read':
        return MessageStatus.read;
      default:
        return MessageStatus.sent;
    }
  }

  static MessageType _parseMessageType(String type) {
    switch (type) {
      case 'text':
        return MessageType.text;
      case 'image':
        return MessageType.image;
      case 'system':
        return MessageType.system;
      default:
        return MessageType.text;
    }
  }

  ChatMessage copyWith({
    String? id,
    String? chatRoomId,
    String? senderId,
    String? senderEmail,
    String? message,
    DateTime? timestamp,
    MessageStatus? status,
    MessageType? type,
    Map<String, String>? reactions,
    String? replyToMessageId,
    bool? isEdited,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      chatRoomId: chatRoomId ?? this.chatRoomId,
      senderId: senderId ?? this.senderId,
      senderEmail: senderEmail ?? this.senderEmail,
      message: message ?? this.message,
      timestamp: timestamp ?? this.timestamp,
      status: status ?? this.status,
      type: type ?? this.type,
      reactions: reactions ?? this.reactions,
      replyToMessageId: replyToMessageId ?? this.replyToMessageId,
      isEdited: isEdited ?? this.isEdited,
    );
  }

  @override
  String toString() {
    return 'ChatMessage(id: $id, sender: $senderEmail, message: $message, status: $status)';
  }
}