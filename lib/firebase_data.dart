import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';
import 'package:rxdart/rxdart.dart';
import 'local_notifications.dart';
import 'firebase_options.dart';

final Logger logger = Logger('FirebaseData');
final _messageStreamController = BehaviorSubject<RemoteMessage>();

class GutterLocation {
  final String deviceID;
  final String name;
  final String address;
  final String maintenanceStatus;
  final double latitude;
  final double longitude;
  final bool isClogged;

  GutterLocation({
    required this.deviceID,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.isClogged,
    required this.maintenanceStatus,
  });
}

DateTime parseTimestamp(String timestamp) {
  int month = int.parse(timestamp.substring(0, 2));
  int day = int.parse(timestamp.substring(2, 4));
  int year = int.parse(timestamp.substring(4, 8));
  int hour = int.parse(timestamp.substring(9, 11));
  int minute = int.parse(timestamp.substring(11, 13));
  int second = int.parse(timestamp.substring(13, 15));
  return DateTime(year, month, day, hour, minute, second);
}

List<GutterLocation> gutterLocations = [];
int previousIsCloggedCount = 0;
int previousInProgressCount = 0;
bool isMaintenanceStatusLocked = false;

Future<void> initializeFirebaseAndFetchData() async {
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (error) {
    logger.severe("Error initializing Firebase or fetching gutter locations: $error");
  }

  final messaging = FirebaseMessaging.instance;

  final settings = await messaging.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );

  if (kDebugMode) {
    print('Permission granted: ${settings.authorizationStatus}');
  }

  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    if (kDebugMode) {
      print('Handling a foreground message: ${message.messageId}');
      print('Message data: ${message.data}');
      print('Message notification: ${message.notification?.title}');
      print('Message notification: ${message.notification?.body}');
    }

    _messageStreamController.sink.add(message);
  });

  Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    await Firebase.initializeApp();

    if (kDebugMode) {
      print("Handling a background message: ${message.messageId}");
      print('Message data: ${message.data}');
      print('Message notification: ${message.notification?.title}');
      print('Message notification: ${message.notification?.body}');
    }
  }
   FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
}

Future<Map<String, dynamic>> fetchGutterLocations() async {
  try {
    DatabaseReference ref = FirebaseDatabase.instance.ref().child('GutterLocations');
    DataSnapshot snapshot = await ref.once().then((event) => event.snapshot);
    List<GutterLocation> locations = [];
    Map<dynamic, dynamic> values = snapshot.value as Map<dynamic, dynamic>;

    values.forEach((deviceId, deviceData) {
      bool isClogged = false;
      DateTime latestTimestamp = DateTime(1970);
      deviceData['isClogged'].forEach((timestamp, cloggedValue) {
        DateTime currentTimestamp = parseTimestamp(timestamp);
        if (currentTimestamp.isAfter(latestTimestamp)) {
          latestTimestamp = currentTimestamp;
          isClogged = cloggedValue;
        }
      });

      String maintenanceStatus = deviceData['maintenanceStatus'];

      if (isClogged && maintenanceStatus == 'nomaintenancereq') {
        maintenanceStatus = 'pending';
        ref.child('$deviceId/maintenanceStatus').set(maintenanceStatus);
      }

      locations.add(GutterLocation(
        deviceID: deviceId,
        name: deviceData['name'],
        address: deviceData['address'],
        latitude: deviceData['latitude'],
        longitude: deviceData['longitude'],
        isClogged: isClogged,
        maintenanceStatus: maintenanceStatus,
      ));
    });

    gutterLocations = locations;
    int pendingCount = gutterLocations.where((location) => location.maintenanceStatus == 'pending').length;
    int inProgressCount = gutterLocations.where((location) => location.maintenanceStatus == 'inprogress').length;
    int isCloggedCount = gutterLocations.where((location) => location.isClogged).length;

    if (isCloggedCount > 0 && isCloggedCount != previousIsCloggedCount) {
      LocalNotificationService().showNotification(title: 'Gutter Maintenance Alert', body: '$isCloggedCount gutters require maintenance due to blockage. Please address promptly');
      previousIsCloggedCount = isCloggedCount;
    }

    if (inProgressCount > 0 && inProgressCount != previousInProgressCount) {
      LocalNotificationService().showNotification(title: 'Gutter Maintenance Ongoing', body: '$inProgressCount gutters are currently under maintenance');
      previousInProgressCount = inProgressCount;
    }

    return {
      'locations': gutterLocations,
      'pendingCount': pendingCount,
      'inProgressCount': inProgressCount,
    };
  } catch (error) {
    logger.severe("Error fetching gutter locations: $error");
    return {
      'locations': [],
      'pendingCount': 0,
      'inProgressCount': 0,
    };
  }
}