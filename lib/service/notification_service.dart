import 'package:cart_veg/config/constant/constant.dart';
import 'package:cart_veg/service/local_storage.dart';
import 'package:dio/dio.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:permission_handler/permission_handler.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  /// **Initialize Notification Service**
  Future<void> init() async {
    await _requestNotificationPermission();
    await _initLocalNotifications();
    await _setupFirebaseListeners();
  }

  /// **1️⃣ Request Notification Permission**
  Future<void> _requestNotificationPermission() async {
    PermissionStatus status = await Permission.notification.request();

    if (status.isGranted) {
      print("✅ Notification permission granted.");
      String? token = await _getFCMToken();
      print("🔑 FCM Token: $token");
      if (token != null) {
        await saveFCMToken(token);
      } else {
        print("⚠️ Failed to get FCM Token.");
      }
    } else if (status.isDenied) {
      print("🚫 Notification permission denied.");
    } else if (status.isPermanentlyDenied) {
      print(
          "⚠️ Notification permission permanently denied. Redirecting to settings...");
      openAppSettings();
    }
  }

  /// **2️⃣ Get FCM Token**
  Future<String?> _getFCMToken() async {
    return await _firebaseMessaging.getToken();
  }

  /// **3️⃣ Initialize Local Notifications**
  Future<void> _initLocalNotifications() async {
    const AndroidInitializationSettings androidInit =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosInit = DarwinInitializationSettings();

    const InitializationSettings settings =
        InitializationSettings(android: androidInit, iOS: iosInit);

    await _localNotifications.initialize(settings);
  }

  /// **4️⃣ Setup Firebase Listeners**
  Future<void> _setupFirebaseListeners() async {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print(
          "📲 Foreground Notification Received: ${message.notification?.title}");
      _showNotification(message);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print("📩 Notification Clicked (Background)");
    });

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }

  /// **5️⃣ Handle Background Notifications**
  Future<void> _firebaseMessagingBackgroundHandler(
      RemoteMessage message) async {
    print("⏳ Background Notification Received: ${message.notification?.title}");
    _showNotification(message);
  }

  /// **6️⃣ Show Notification**
  Future<void> _showNotification(RemoteMessage message) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails("channel_id", "channel_name",
            importance: Importance.high, priority: Priority.high);

    const NotificationDetails details =
        NotificationDetails(android: androidDetails);

    await _localNotifications.show(
      0,
      message.notification?.title ?? "No Title",
      message.notification?.body ?? "No Body",
      details,
    );
  }

  final Dio _dio = Dio(BaseOptions(
    baseUrl: BASE_URL,
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 15),
  ));
  Future<void> saveFCMToken(String fcm) async {
    final token = await LocalStorageService().getToken();
    _dio.options.headers["Authorization"] = "Bearer $token";

    try {
      final response = await _dio.post("user/save-fcm-token", data: {
        "fcm": fcm,
      });
      if (response.statusCode == 200) {
        print(response.data); 
      } else {
        print("🚫 Token not Saved");
      }
    } on DioException catch (e) {
      print(e.response); 
      print("⚠️ Error saving FCM Token: $e");
    }
  }
}
