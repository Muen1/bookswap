import 'package:bookswap/models/chat.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/chat_service.dart';

final chatServiceProvider = Provider<ChatService>((ref) => ChatService());

final userChatRoomsProvider = StreamProvider.family<List<ChatRoom>, String>((ref, userId) {
  final service = ref.read(chatServiceProvider);
  return service.getUserChatRooms(userId);
});

final chatMessagesProvider = StreamProvider.family<List<ChatMessage>, String>((ref, chatRoomId) {
  final service = ref.read(chatServiceProvider);
  return service.getChatMessages(chatRoomId);
});