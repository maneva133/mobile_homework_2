import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  final AndroidNotificationChannel _defaultChannel = const AndroidNotificationChannel(
    'reminders_channel',
    'Потсетници',
    description: 'Потсетници за рецепт на денот',
    importance: Importance.high,
  );

  Function(String)? onNotificationTapped;

  Future<void> init() async {
    tz.initializeTimeZones();
    await _initLocalNotifications();
    await _requestNotificationPermission();
    await _registerMessageHandlers();
    await _setupNotificationTapHandling();
  }

  Future<void> _requestNotificationPermission() async {
    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  Future<void> _initLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        if (response.payload == 'random_recipe') {
          onNotificationTapped?.call('random_recipe');
        }
      },
    );
    
    await _localNotifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_defaultChannel);
  }

  Future<void> _setupNotificationTapHandling() async {
    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      _handleNotificationTap(initialMessage);
    }

    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);
  }

  void _handleNotificationTap(RemoteMessage message) {
    if (message.data['type'] == 'random_recipe' || 
        message.notification?.title?.contains('Рецепт') == true) {
      onNotificationTapped?.call('random_recipe');
    }
  }

  Future<void> _registerMessageHandlers() async {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      final notification = message.notification;
      if (notification != null) {
        _localNotifications.show(
          notification.hashCode,
          notification.title,
          notification.body ?? 'Отвори ја апликацијата за да видиш рецепт на денот!',
          NotificationDetails(
            android: AndroidNotificationDetails(
              _defaultChannel.id,
              _defaultChannel.name,
              channelDescription: _defaultChannel.description,
              icon: '@mipmap/ic_launcher',
              importance: Importance.high,
              priority: Priority.high,
              enableVibration: true,
              playSound: true,
            ),
            iOS: const DarwinNotificationDetails(
              presentAlert: true,
              presentBadge: true,
              presentSound: true,
            ),
          ),
          payload: message.data['type'] ?? 'random_recipe',
        );
      }
    });
  }

  Future<void> scheduleDailyRandomReminder({int hour = 23, int minute = 19}) async {
    await _localNotifications.cancel(0);
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    await _localNotifications.zonedSchedule(
      0,
      'Рецепт на денот',
      'Отвори ја апликацијата и разгледај нов рецепт денес!',
      scheduled,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _defaultChannel.id,
          _defaultChannel.name,
          channelDescription: _defaultChannel.description,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
          enableVibration: true,
          playSound: true,
          styleInformation: BigTextStyleInformation(
            'Отвори ја апликацијата и разгледај нов рецепт денес!',
            contentTitle: 'Рецепт на денот',
          ),
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: 'random_recipe',
    );
  }

  Future<void> showTestNotification() async {
    await _localNotifications.show(
      999,
      'Рецепт на денот',
      'Отвори ја апликацијата и разгледај нов рецепт денес!',
      NotificationDetails(
        android: AndroidNotificationDetails(
          _defaultChannel.id,
          _defaultChannel.name,
          channelDescription: _defaultChannel.description,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
          enableVibration: true,
          playSound: true,
          styleInformation: BigTextStyleInformation(
            'Отвори ја апликацијата и разгледај нов рецепт денес!',
            contentTitle: 'Рецепт на денот',
          ),
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: 'random_recipe',
    );
  }

  Future<String?> getFCMToken() async {
    try {
      return await _messaging.getToken();
    } catch (e) {
      print('Error getting FCM token: $e');
      return null;
    }
  }
}

