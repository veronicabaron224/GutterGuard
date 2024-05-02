import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import 'local_notifications.dart';
import 'firebase_data.dart';
import 'user_manual.dart';
import 'locations.dart';
import 'home.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp();
  } catch (e) {
    logger.severe('Error initializing Firebase: $e');
  }
  
  FirebaseMessaging.onBackgroundMessage(backgroundHandler);
  LocalNotificationService().initNotification();
  await initializeFirebaseAndFetchData();
  runApp(const MyApp());
}

Future backgroundHandler(RemoteMessage msg) async {}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: fetchGutterLocations(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const MaterialApp(
            home: Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            ),
          );
        } else if (snapshot.hasError) {
          return MaterialApp(
            home: Scaffold(
              body: Center(
                child: Text('Error loading data: ${snapshot.error}'),
              ),
            ),
          );
        } else {
          List<GutterLocation> gutterLocations = List<GutterLocation>.from(snapshot.data!['locations']);
          return MaterialApp(
            title: 'GutterGuard',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.orangeAccent),
              useMaterial3: true,
              textTheme: GoogleFonts.poppinsTextTheme(),
            ),
            home: MyHomePage(
            gutterLocations: gutterLocations,
            pendingCount: snapshot.data!['pendingCount'],
            inProgressCount: snapshot.data!['inProgressCount'],
            ),
          );
        }
      }
    );
  }
}

class MyHomePage extends StatefulWidget {
  final List<GutterLocation> gutterLocations;
  final int pendingCount;
  final int inProgressCount;

  const MyHomePage({
    super.key,
    required this.gutterLocations,
    required this.pendingCount,
    required this.inProgressCount,
  });

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _currentPageIndex = 0;
  late PageController _pageController;
  final _selectedMaintenanceFilter = 'All';

  final List<String> pageTitles = ['Home', 'Device Locations', 'User Manual'];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentPageIndex);

    _checkConnectivity((widget) {
      showDialog(
        context: context,
        builder: (context) => widget,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80.0),
        child: Container(
          padding: const EdgeInsets.only(top: 25.0, bottom: 0.0),
          alignment: Alignment.center,
          color: Colors.grey[40],
          child: Text(
            pageTitles[_currentPageIndex],
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 21.0,
            ),
          ),
        ),
      ),
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentPageIndex = index;
          });
        },
        children: [
          HomeContent(gutterLocations: widget.gutterLocations),
          LocationsPage(selectedMaintenanceFilter: _selectedMaintenanceFilter),
          const UserManualPage(),
        ],
      ),
      bottomNavigationBar: SizedBox(
        height: 65.0,
        child: BottomNavigationBar(
          currentIndex: _currentPageIndex,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.place),
              label: 'Device Locations',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.info),
              label: 'User Manual',
            ),
          ],
          selectedItemColor: Colors.orangeAccent,
          unselectedItemColor: Colors.grey,
          showSelectedLabels: false,
          showUnselectedLabels: false,
          onTap: (index) {
            _pageController.jumpToPage(index);
          },
        ),
      ),
    );
  }

  Future<void> _checkConnectivity(void Function(Widget) showDialogCallback) async {
    List<ConnectivityResult> connectivityResults = await Connectivity().checkConnectivity();
    if (connectivityResults.contains(ConnectivityResult.none)) {
      showDialogCallback(
        AlertDialog(
          title: const Text('No Internet Connection'),
          content: const Text('Please check your internet connection and try again.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}