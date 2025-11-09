// ignore: depend_on_referenced_packages
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
// ignore: depend_on_referenced_packages
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  static bool _isInitialized = false;

  // Callback for notification tap handling
  static Function(Map<String, dynamic>)? onNotificationTap;

  static Future<void> initialize({Function(Map<String, dynamic>)? onNotificationTapped}) async {
    if (_isInitialized) return;
    
    onNotificationTap = onNotificationTapped;
    
    try {
      // Request permission
      await _requestPermission();
      
      // Initialize local notifications
      await _initializeLocalNotifications();
      
      // Set up message handlers
      await _setupMessageHandlers();
      
      // Get and print token
      await _printFCMToken();
      
      _isInitialized = true;
      
      if (kDebugMode) {
        print('NotificationService initialized successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error initializing NotificationService: $e');
      }
    }
  }

  static Future<void> _requestPermission() async {
    try {
      NotificationSettings settings = await _firebaseMessaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: kDebugMode, // Allow provisional in debug mode
      );

      if (kDebugMode) {
        switch (settings.authorizationStatus) {
          case AuthorizationStatus.authorized:
            print('User granted full notification permission');
            break;
          case AuthorizationStatus.provisional:
            print('User granted provisional notification permission');
            break;
          case AuthorizationStatus.denied:
            print('User denied notification permission');
            break;
          case AuthorizationStatus.notDetermined:
            print('User hasn\'t decided on notification permission');
            break;
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error requesting notification permission: $e');
      }
    }
  }

  static Future<void> _initializeLocalNotifications() async {
    try {
      const AndroidInitializationSettings androidSettings = 
          AndroidInitializationSettings('@mipmap/ic_launcher');
      
      const DarwinInitializationSettings iosSettings = 
          DarwinInitializationSettings(
            requestAlertPermission: false, // Already requested above
            requestBadgePermission: true,
            requestSoundPermission: true,
          );
      
      const InitializationSettings settings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );
      
      await _localNotifications.initialize(
        settings,
        onDidReceiveNotificationResponse: (NotificationResponse response) {
          // Handle notification tap
          if (response.payload != null && onNotificationTap != null) {
            try {
              // Parse payload as JSON or use as string
              final payload = {'type': response.payload};
              onNotificationTap!(payload);
            } catch (e) {
              if (kDebugMode) {
                print('Error handling notification tap: $e');
              }
            }
          }
        },
      );

      // Create notification channel for Android
      await _createNotificationChannel();
    } catch (e) {
      if (kDebugMode) {
        print('Error initializing local notifications: $e');
      }
    }
  }

  static Future<void> _createNotificationChannel() async {
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'bookswap_channel',
      'BookSwap Notifications',
      description: 'Notifications for new messages and swap offers',
      importance: Importance.high,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  static Future<void> _setupMessageHandlers() async {
    // Handle background messages
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    
    // Handle foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    
    // Handle when app is in background but opened from notification
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);
    
    // Get initial message when app is launched from terminated state
    RemoteMessage? initialMessage = await _firebaseMessaging.getInitialMessage();
    if (initialMessage != null) {
      _handleMessageOpenedApp(initialMessage);
    }
  }

  static Future<void> _printFCMToken() async {
    try {
      String? token = await _firebaseMessaging.getToken();
      if (kDebugMode) {
        print('FCM Token: $token');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error getting FCM token: $e');
      }
    }
  }

  static Future<void> _handleForegroundMessage(RemoteMessage message) async {
    if (kDebugMode) {
      print('Received foreground message: ${message.messageId}');
      print('Message data: ${message.data}');
      print('Message notification: ${message.notification}');
    }
    
    await _showLocalNotification(message);
  }

  static Future<void> _showLocalNotification(RemoteMessage message) async {
    try {
      const AndroidNotificationDetails androidPlatformChannelSpecifics = 
          AndroidNotificationDetails(
        'bookswap_channel',
        'BookSwap Notifications',
        channelDescription: 'Notifications for new messages and swap offers',
        importance: Importance.high,
        priority: Priority.high,
        showWhen: true,
      );
      
      const DarwinNotificationDetails iosPlatformChannelSpecifics = 
          DarwinNotificationDetails();
      
      const NotificationDetails platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: iosPlatformChannelSpecifics,
      );
      
      // Extract title and body
      final title = message.notification?.title ?? 'BookSwap';
      final body = message.notification?.body ?? 
          message.data['body'] ?? 'New notification';
      
      // Use message type or generate unique ID
      final notificationId = message.messageId?.hashCode ?? DateTime.now().millisecondsSinceEpoch;
      
      await _localNotifications.show(
        notificationId,
        title,
        body,
        platformChannelSpecifics,
        payload: message.data['type'] ?? message.data['screen'] ?? 'general',
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error showing local notification: $e');
      }
    }
  }

  static Future<String?> getFCMToken() async {
    try {
      return await _firebaseMessaging.getToken();
    } catch (e) {
      if (kDebugMode) {
        print('Error getting FCM token: $e');
      }
      return null;
    }
  }

  static Future<void> subscribeToTopic(String topic) async {
    try {
      await _firebaseMessaging.subscribeToTopic(topic);
      if (kDebugMode) {
        print('Subscribed to topic: $topic');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error subscribing to topic $topic: $e');
      }
    }
  }

  static Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _firebaseMessaging.unsubscribeFromTopic(topic);
      if (kDebugMode) {
        print('Unsubscribed from topic: $topic');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error unsubscribing from topic $topic: $e');
      }
    }
  }

  static Future<void> requestPermission() async {
    await _requestPermission();
  }

  // For testing notifications locally
  static Future<void> showTestNotification({
    String title = 'Test Notification',
    String body = 'This is a test notification',
    String payload = 'test',
  }) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics = 
        AndroidNotificationDetails(
      'bookswap_channel',
      'BookSwap Notifications',
      channelDescription: 'Notifications for new messages and swap offers',
      importance: Importance.high,
      priority: Priority.high,
    );
    
    const DarwinNotificationDetails iosPlatformChannelSpecifics = 
        DarwinNotificationDetails();
    
    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iosPlatformChannelSpecifics,
    );
    
    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch,
      title,
      body,
      platformChannelSpecifics,
      payload: payload,
    );
  }
}

// Background message handler (must be top-level function)
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (kDebugMode) {
    print("Handling a background message: ${message.messageId}");
  }
  
  // Initialize local notifications in background
  final FlutterLocalNotificationsPlugin localNotifications = FlutterLocalNotificationsPlugin();
  
  const AndroidInitializationSettings androidSettings = 
      AndroidInitializationSettings('@mipmap/ic_launcher');
  
  const DarwinInitializationSettings iosSettings = 
      DarwinInitializationSettings();
  
  const InitializationSettings settings = InitializationSettings(
    android: androidSettings,
    iOS: iosSettings,
  );
  
  await localNotifications.initialize(settings);
  
  // Show notification
  const AndroidNotificationDetails androidPlatformChannelSpecifics = 
      AndroidNotificationDetails(
    'bookswap_channel',
    'BookSwap Notifications',
    channelDescription: 'Notifications for new messages and swap offers',
    importance: Importance.high,
    priority: Priority.high,
  );
  
  const DarwinNotificationDetails iosPlatformChannelSpecifics = 
      DarwinNotificationDetails();
  
  const NotificationDetails platformChannelSpecifics = NotificationDetails(
    android: androidPlatformChannelSpecifics,
    iOS: iosPlatformChannelSpecifics,
  );
  
  await localNotifications.show(
    message.hashCode,
    message.notification?.title ?? 'BookSwap',
    message.notification?.body ?? 'New notification',
    platformChannelSpecifics,
  );
}

void _handleMessageOpenedApp(RemoteMessage message) {
  if (kDebugMode) {
    print('Notification tapped with data: ${message.data}');
  }
  
  // Trigger the callback if set
  if (NotificationService.onNotificationTap != null) {
    NotificationService.onNotificationTap!(message.data);
  }
}