import 'package:flutter/material.dart';

class UserManualPage extends StatelessWidget {
  const UserManualPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(50.0),
            child: AppBar(
              automaticallyImplyLeading: false,
              title: const SizedBox.shrink(),
              bottom: const PreferredSize(
                preferredSize: Size.fromHeight(30.0),
                child: TabBar(
                  tabs: [
                    Tab(text: 'Home'),
                    Tab(text: 'Locations'),
                  ],
                ),
              ),
            ),
          ),
          body: TabBarView(
            children: [
              _buildTabContent(
                title: 'Home',
                content: 'The Home page provides an overview of the gutter maintenance status and device locations.'
                '\n\n- Map View: Displays all GutterGuard device locations marked with icons.'
                '\n- Maintenance Status Counts: Shows the number of devices currently under maintenance or pending maintenance.',
              ),
              _buildTabContent(
                title: 'Device Locations',
                content: 'The Device Locations page provides detailed information about each GutterGuard device installed.'
                '\n\n- List of Devices: Displays a list of all GutterGuard devices installed, along with their details such as location, clog status, and maintenance status.'
                '\n- Details View: Tap on a device to view its detailed information, including its exact location on the map, clog status, and maintenance history.',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabContent({required String title, required String content}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 17.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 0.0, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10.0),
          Text(
            content,
            style: const TextStyle(fontSize: 16.0),
          ),
        ],
      ),
    );
  }
}

void main() {
  runApp(const MaterialApp(
    home: UserManualPage(),
  ));
}