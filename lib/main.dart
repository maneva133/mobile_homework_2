import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart';
import 'screens/categories_screen.dart';
import 'screens/meal_detail_screen.dart';
import 'services/notification_service.dart';
import 'services/meal_service.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  print('Background message received: ${message.messageId}');
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  await NotificationService.instance.init();
  
  NotificationService.instance.onNotificationTapped = (String payload) {
    _handleNotificationTap();
  };
  
  await NotificationService.instance.scheduleDailyRandomReminder();
  
  await NotificationService.instance.showTestNotification();
  
  final token = await NotificationService.instance.getFCMToken();
  print('FCM Token: $token');
  
  runApp(const MealApp());
}

Future<void> _handleNotificationTap() async {
  final mealService = MealService();
  final randomMeal = await mealService.getRandomMeal();
  
  if (randomMeal != null && navigatorKey.currentState != null) {
    navigatorKey.currentState!.push(
      MaterialPageRoute(
        builder: (context) => MealDetailScreen(mealId: randomMeal.idMeal),
      ),
    );
  }
}

class MealApp extends StatelessWidget {
  const MealApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'Рецепти',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.orange,
        scaffoldBackgroundColor: Colors.orange.shade50,
      ),
      home: const CategoriesScreen(),
    );
  }
}