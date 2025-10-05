// import 'dart:convert';
//
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:rxdart/subjects.dart';
//
// import '../../entities/received_notification.dart';
// import '../event/event_bus_mixin.dart';
//
// final BehaviorSubject<ReceivedNotification> didReceiveLocalNotificationSubject =
//     BehaviorSubject<ReceivedNotification>();
//
// class NotificationService with EventBusMixin {
//   static final FlutterLocalNotificationsPlugin _notificationsPlugin =
//       FlutterLocalNotificationsPlugin();
//
//   static Future<void> initialize() async {
//     // await _configureLocalTimeZone();
//     InitializationSettings initializationSettings = InitializationSettings(
//         android: const AndroidInitializationSettings('@mipmap/ic_logo'),
//         iOS: IOSInitializationSettings(
//           requestAlertPermission: false,
//           requestBadgePermission: false,
//           requestSoundPermission: false,
//           onDidReceiveLocalNotification: (
//             int id,
//             String? title,
//             String? body,
//             String? payload,
//           ) async {
//             didReceiveLocalNotificationSubject.add(ReceivedNotification(
//               id: id,
//               title: title,
//               body: body,
//               payload: payload,
//             ));
//           },
//         ));
//
//     _notificationsPlugin
//         .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
//         ?.requestPermissions(
//           alert: true,
//           badge: true,
//           sound: true,
//         );
//
//     _notificationsPlugin.initialize(initializationSettings, onSelectNotification: (route) {
//       //handle click when click app mode background or force ground
//       print('on click $route');
//       handleLocalNotification(route, isTap: true);
//     });
//   }
//
//   static Future<void> display(RemoteMessage message) async {
//     try {
//       final id = DateTime.now().millisecondsSinceEpoch ~/ 1000;
//
//       const NotificationDetails notificationDetails = NotificationDetails(
//           android: AndroidNotificationDetails(
//             'approach',
//             'app_channel',
//             icon: '@mipmap/ic_logo',
//             importance: Importance.max,
//             priority: Priority.high,
//             timeoutAfter: 1800000,
//           ),
//           iOS: IOSNotificationDetails());
//       await _notificationsPlugin.show(
//         id,
//         message.notification?.title ?? message.data['title'],
//         message.notification?.body ?? message.data['body'],
//         notificationDetails,
//         payload: jsonEncode(message.data),
//       );
//     } on Exception catch (e) {
//       print(e.toString());
//     }
//   }
//
//   static void handleNotification(RemoteMessage? message, {bool isTap = false}) {
//     debugPrint(
//         '===============================Data from notification=====================\n$message');
//     print('A new message opened app event was published');
//   }
//
//   static void handleLocalNotification(String? message, {bool isTap = false}) {
//     debugPrint(
//         '===============================Data from notification=====================\n$message');
//   }
// }
