import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../../providers/notification_provider.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  static final _firebaseMessaging = FirebaseMessaging.instance;



  final _androidChannel = const AndroidNotificationChannel(
    "ride_updates_channel",
    "Ride Updates",
    description:
        "Receive notifications about the progress of your ride and other important updates.",
    importance: Importance.high,
  );

  static Future<void> initNotifications() async {
    await FirebaseMessaging.instance.setAutoInitEnabled(true);

    final settings = await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    // if (kDebugMode) {
    //   print('Permission granted: ${settings.authorizationStatus}');
    // }
    //
    // final fcmToken = await FirebaseMessaging.instance.getToken();
    // print("FCMToken $fcmToken");

    // Initialize notification plugin
    await _initializeNotifications();

    // Create notification channel
    await _createNotificationChannel();

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    FirebaseMessaging.onMessage.listen(_firebaseMessagingForegroundHandler);
    FirebaseMessaging.onMessageOpenedApp.listen(_firebaseMessagingOpenNotificationHandler);
  }

  static Future<void> saveNotificationToFirestore(String userID, RemoteNotification? notification) async {
    try {
      // Get a reference to the user's collection of notifications
      CollectionReference userNotifications = FirebaseFirestore.instance
          .collection('users')
          .doc(userID)
          .collection('notifications');

      // Add a new document with a generated ID
      await userNotifications.add({
        'title': notification?.title,
        'message': notification?.body,
        'timestamp': FieldValue.serverTimestamp(),
        'read': false,
      });

      print('Notification added to Firestore');
      NotificationProvider().setNewNotification(true);
    } catch (e) {
      print('Error adding notification to Firestore: $e');
    }
  }

  static Future<void> _firebaseMessagingBackgroundHandler(
      RemoteMessage message) async {

    String? userID = FirebaseAuth.instance.currentUser?.uid;

    // Handle the background message here
    print("INSIDEEEE SERVICEEE CLASSSSS");
    print("Handling a background message: ${message.messageId}");
    print("Message data: ${message.data}");
    if (message.notification != null) {
      print("Message also contains notification: ${message.notification}");
      print("Title: ${message.notification?.title}");
      print("Body: ${message.notification?.body}");


      // if (userID != null) {
      //   await saveNotificationToFirestore(userID, message.notification);
      // } else {
      //   print("User is not logged in, notification not saved.");
      // }
    }
  }

  static Future<void> _firebaseMessagingForegroundHandler(
      RemoteMessage message) async {

    String? userID = FirebaseAuth.instance.currentUser?.uid;

    print("FOREGROUND IN SERVICEEEEEEEE CLASSSSS");
    print("Foreground message received: ${message.messageId}");
    print("Message data: ${message.data}");
    // Handle the message as needed, such as updating UI or showing an in-app notification.
    if (message.notification != null) {
      print("Message also contains notification: ${message.notification}");
      print("Title: ${message.notification?.title}");
      print("Body: ${message.notification?.body}");

      // Show notification
      if (message.notification != null) {
        await showNotification(message.notification);

        if (userID != null) {
          await saveNotificationToFirestore(userID, message.notification);
        } else {
          print("User is not logged in, notification not saved.");
        }

      }
    }
  }

  static void _firebaseMessagingOpenNotificationHandler(RemoteMessage message) {
    print("User clicked on notificationSSSSSSSSSSSSSSSSSSSSS: ${message.messageId}");
    // if (message.data.containsKey('notificationType')) {
    //   String notificationType = message.data['notificationType'];
    //   // Handle different notification types
    //   if (notificationType == 'rideUpdate') {
    //     // Navigate to the rides screen
    //     // navigateToRidesScreen();
    //   } else if (notificationType == 'otherNotificationType') {
    //     // Handle other notification types
    //   } else {
    //     // Handle default case
    //   }
    // } else {
    //   // Handle default case
    // }
  }

  static Future<void> showNotification(RemoteNotification? notification) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      "ride_updates_channel",
      "Ride Updates",
      // 'your_channel_description', // Adjust channel description
      importance: Importance.max,
      priority: Priority.high,
      // icon:
    );
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(
      0, // Notification ID
      notification?.title, // Notification title
      notification?.body, // Notification body
      platformChannelSpecifics,
    );
  }

  static Future<void> _initializeNotifications() async {
    const InitializationSettings initializationSettings =
        InitializationSettings(
      android:
          AndroidInitializationSettings('ic_launcher'), // Adjust the icon name
      // iOS: IOSInitializationSettings(),
    );

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  static Future<void> _createNotificationChannel() async {
    final AndroidNotificationChannel androidNotificationChannel =
    AndroidNotificationChannel(
      'ride_updates_channel', // id
      'Ride Updates', // title
      description: 'Receive notifications about the progress of your ride and other important updates.', // description
      importance: Importance.high,
    );

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidNotificationChannel);
  }

// static Future<void> showNotification(RemoteNotification? notification) async {
//   // final AndroidNotificationDetails androidPlatformChannelSpecifics =
//   //     AndroidNotificationDetails(
//   //   'your_channel_id', // Adjust channel ID
//   //   'your_channel_name', // Adjust channel name
//   //   // 'your_channel_description', // Adjust channel description
//   //   importance: Importance.max,
//   //   priority: Priority.high,
//   // );
//   // final NotificationDetails platformChannelSpecifics =
//   //     NotificationDetails(android: androidPlatformChannelSpecifics);
//
//   await flutterLocalNotificationsPlugin.show(
//     0, // Notification ID
//     notification?.title, // Notification title
//     notification?.body, // Notification body
//     // platformChannelSpecifics,
//     NotificationDetails(
//       android: AndroidNotificationDetails(
//         _androidChannel.id,
//         _androidChannel.name,
//         channelDescription: _androidChannel.description,
//         icon: 'ic_launcher',
//       ),
//     ),
//     payload: jsonEncode(notification?.toMap()),
//   );
// }
}

// final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
// FlutterLocalNotificationsPlugin();
//
// Future<void> main() async {
//
//
//
//   WidgetsFlutterBinding.ensureInitialized();
//
//   await Firebase.initializeApp(
//     options: DefaultFirebaseOptions.currentPlatform,
//   );
//   await FirebaseMessaging.instance.setAutoInitEnabled(true);
//
//   final messaging = FirebaseMessaging.instance;
//
//   final settings = await messaging.requestPermission(
//     alert: true,
//     announcement: false,
//     badge: true,
//     carPlay: false,
//     criticalAlert: false,
//     provisional: false,
//     sound: true,
//   );
//
//   FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
//
//   if (kDebugMode) {
//     print('Permission granted: ${settings.authorizationStatus}');
//   }
//
//   final fcmToken = await FirebaseMessaging.instance.getToken();
//   print("FCMToken $fcmToken");
//
//
//   // Listen for foreground messages
//   FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
//     print("Foreground message received: ${message.messageId}");
//     print("Message data: ${message.data}");
//     // Handle the message as needed, such as updating UI or showing an in-app notification.
//     if (message.notification != null) {
//       print("Message also contains notification: ${message.notification}");
//       print("Title: ${message.notification?.title}");
//       print("Body: ${message.notification?.body}");
//
//       // Show notification
//       if (message.notification != null) {
//         await showNotification(message.notification);
//       }
//     }
//
//   });
//
//   // Initialize the plugin
//   await initNotifications();
//
//   // await NotificationService.initNotifications();
//
//
//   await dotenv.load(fileName: ".env");
//   Stripe.publishableKey = dotenv.env['STRIPE_PUBLISHABLE_KEY']!;
//   await Stripe.instance.applySettings();
//   runApp(MyApp());
// }
//
// Future<void> initNotifications() async {
//   final InitializationSettings initializationSettings =
//   InitializationSettings(
//     android: const AndroidInitializationSettings('ic_launcher'), // Adjust the icon name
//     // iOS: IOSInitializationSettings(),
//   );
//
//   await flutterLocalNotificationsPlugin.initialize(initializationSettings);
// }
//
// Future<void> showNotification(RemoteNotification? notification) async {
//   final AndroidNotificationDetails androidPlatformChannelSpecifics =
//   AndroidNotificationDetails(
//     'your_channel_id', // Adjust channel ID
//     'your_channel_name', // Adjust channel name
//     // 'your_channel_description', // Adjust channel description
//     importance: Importance.max,
//     priority: Priority.high,
//   );
//   final NotificationDetails platformChannelSpecifics =
//   NotificationDetails(android: androidPlatformChannelSpecifics);
//
//   await flutterLocalNotificationsPlugin.show(
//     0, // Notification ID
//     notification?.title, // Notification title
//     notification?.body, // Notification body
//     platformChannelSpecifics,
//   );
// }
//
//
// Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
//   // Handle the background message here
//   print("Handling a background message: ${message.messageId}");
//   print("Message data: ${message.data}");
//   if (message.notification != null) {
//     print("Message also contains notification: ${message.notification}");
//     print("Title: ${message.notification?.title}");
//     print("Body: ${message.notification?.body}");
//
//     // Show notification
//     if (message.notification != null) {
//       await showNotification(message.notification);
//     }
//
//   }
// }
