import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:logging/logging.dart';

final Logger logger = Logger('FirebaseData');

class GutterLocation {
  final String name;
  final String address;
  final String maintenanceStatus;
  final double latitude;
  final double longitude;
  final bool isClogged;

  GutterLocation({
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

Future<void> initializeFirebaseAndFetchData() async {
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (error) {
    logger.severe("Error initializing Firebase or fetching gutter locations: $error");
  }
}

Future<Map<String, dynamic>> fetchGutterLocations() async {
  try {
    DatabaseReference ref = FirebaseDatabase.instance.ref().child('GutterLocations');
    DataSnapshot snapshot = await ref.once().then((event) => event.snapshot);
    List<GutterLocation> locations = [];
    Map<dynamic, dynamic> values = snapshot.value as Map<dynamic, dynamic>;

    values.forEach((deviceId, deviceData) {
      bool isClogged = false;
      DateTime latestTimestamp = DateTime(1970); // Initialize with a past date
      deviceData['isClogged'].forEach((timestamp, cloggedValue) {
        DateTime currentTimestamp = parseTimestamp(timestamp);
        if (currentTimestamp.isAfter(latestTimestamp)) {
          latestTimestamp = currentTimestamp;
          isClogged = cloggedValue;
        }
      });

      locations.add(GutterLocation(
        name: deviceData['name'],
        address: deviceData['address'],
        latitude: deviceData['latitude'],
        longitude: deviceData['longitude'],
        isClogged: isClogged,
        maintenanceStatus: deviceData['maintenanceStatus'],
      ));
    });

    gutterLocations = locations;
    int pendingCount = gutterLocations.where((location) => location.maintenanceStatus == 'pending').length;
    int inProgressCount = gutterLocations.where((location) => location.maintenanceStatus == 'inprogress').length;

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