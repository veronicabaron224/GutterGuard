import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:flutter/material.dart';

class LocalNotificationService {
  static final FlutterLocalNotificationsPlugin notificationsPlugin =
    FlutterLocalNotificationsPlugin(); 

  Future<void> initNotification() async {
    AndroidInitializationSettings initializationSettingsAndroid =
      const AndroidInitializationSettings('ic_notification');

    var initializationSettings = InitializationSettings(android: initializationSettingsAndroid);
    await notificationsPlugin.initialize(initializationSettings,
      onDidReceiveNotificationResponse: 
        (NotificationResponse notificationResponse) async {});
  }

  notificationDetails() {
    return const NotificationDetails(
      android: AndroidNotificationDetails('channelId', 'channelName', importance: Importance.max)
    );
  }  

  Future showNotification(
  {int id = 0, String? title, String? body, String? payLoad}) async {
    return notificationsPlugin.show(
      id, title, body, await notificationDetails());
  }
  
  // Future<void> showNotification({int id = 0, String? title, String? body, String? payLoad}) async {
  //   if (!await _isAppForeground()) {
  //     await notificationsPlugin.show(
  //         id, title, body, await notificationDetails(),
  //         payload: payLoad);
  //   }
  // }

  // static Future<bool> _isAppForeground() async {
  //   final state = WidgetsBinding.instance.lifecycleState;
  //   return state == AppLifecycleState.resumed;
  // }
}