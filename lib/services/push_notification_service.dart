import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:vayujal/services/local_notification_service.dart';

class PushNotificationService {
  static Future<void> initialize() async {
    await _requestPermission();
    await saveTokenToFirestore();
    
    // Listen for token refresh
    FirebaseMessaging.instance.onTokenRefresh.listen((token) async {
      await saveTokenToFirestore(tokenOverride: token);
    });
    
    // Handle background messages
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    
    // Handle foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    
    // Handle notification tap when app is in background
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);
    
    print('✅ Push notification service initialized');
  }

  static Future<void> _requestPermission() async {
    final settings = await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );
    
    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('✅ Notification permission granted');
    } else if (settings.authorizationStatus == AuthorizationStatus.denied) {
      print('❌ Notification permission denied');
    } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
      print('⚠️ Provisional notification permission granted');
    }
  }

  static Future<void> saveTokenToFirestore({String? tokenOverride}) async {
    final user = FirebaseAuth.instance.currentUser;
    final token = tokenOverride ?? await FirebaseMessaging.instance.getToken();
    
    if (user != null && token != null) {
      try {
        // Save token to admin collection with array of tokens for multiple devices
        await FirebaseFirestore.instance.collection('admins').doc(user.uid).set({
          'fcmTokens': FieldValue.arrayUnion([token]),
          'lastTokenUpdate': FieldValue.serverTimestamp(),
          'userType': 'admin',
        }, SetOptions(merge: true));
        
        print('✅ FCM token saved for admin: ${user.uid}');
      } catch (e) {
        print('❌ Error saving FCM token: $e');
      }
    }
  }

  // Handle foreground messages
  static void _handleForegroundMessage(RemoteMessage message) {
    print('📱 Received foreground message: ${message.notification?.title}');
    
    // Show local notification for foreground messages
    if (message.notification != null) {
      LocalNotificationService.showNotification(
        id: message.hashCode,
        title: message.notification!.title ?? 'New Notification',
        body: message.notification!.body ?? '',
        payload: message.data.toString(),
      );
    }
  }

  // Handle notification tap
  static void _handleNotificationTap(RemoteMessage message) {
    print('👆 Notification tapped: ${message.notification?.title}');
    
    // Navigate to appropriate screen based on notification type
    final data = message.data;
    if (data['type'] == 'service_accepted' || 
        data['type'] == 'service_rejected' || 
        data['type'] == 'service_completed') {
      // Navigate to notification page
      // This will be handled by the app's navigation system
    }
  }

  // Save FCM token when user logs in
  static Future<void> saveTokenOnLogin() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final token = await FirebaseMessaging.instance.getToken();
      if (token != null) {
        try {
          await FirebaseFirestore.instance.collection('admins').doc(user.uid).update({
            'fcmTokens': FieldValue.arrayUnion([token]),
            'lastTokenUpdate': FieldValue.serverTimestamp(),
          });
          print('✅ FCM token saved for user: ${user.uid}');
        } catch (e) {
          print('❌ Error saving FCM token: $e');
        }
      }
    }
  }
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Note: Firebase.initializeApp() should be called in main() before this
  print('Handling a background message: ${message.messageId}');
} 