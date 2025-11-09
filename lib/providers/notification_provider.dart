import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/notification_service.dart';

final notificationServiceProvider = Provider<NotificationService>((ref) => NotificationService());

final fcmTokenProvider = FutureProvider<String?>((ref) async {
  return await NotificationService.getFCMToken();
});