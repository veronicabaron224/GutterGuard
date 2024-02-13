import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'my_tasks.dart';
import 'home.dart';
import 'locations.dart';
import 'settings.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GutterGuard',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.orangeAccent),
        useMaterial3: true,
        textTheme: GoogleFonts.poppinsTextTheme(),
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _currentPageIndex = 0;
  late PageController _pageController;

  final List<String> pageTitles = ['Home', 'Locations', 'My Tasks', 'Settings'];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentPageIndex);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(100.0),
        child: Container(
          padding: const EdgeInsets.only(left: 20.0, bottom: 15.0),
          alignment: Alignment.bottomLeft,
          color: Colors.grey[40],
          child: Text(
            pageTitles[_currentPageIndex],
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.bold,
              fontSize: 28.0,
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
        children: const [
          HomeContent(),
          LocationsPage(),
          MyTasksPage(),
          SettingsPage(),
        ],
      ),
      bottomNavigationBar: SizedBox(
      height: 65.0, // Adjust the height as needed
      child: BottomNavigationBar(
        currentIndex: _currentPageIndex,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.place),
            label: 'Locations',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.check_box),
            label: 'My Tasks',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
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

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}