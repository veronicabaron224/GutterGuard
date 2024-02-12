import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: [
          ListTile(
            title: const Text('Account'),
            onTap: () {
              // Handle Account settings
            },
          ),
          ListTile(
            title: const Text('Notifications'),
            onTap: () {
              // Handle Notifications settings
            },
          ),
          ListTile(
            title: const Text('Privacy & Security'),
            onTap: () {
              // Handle Privacy & Security settings
            },
          ),
          ListTile(
            title: const Text('Help and Support'),
            onTap: () {
              // Handle Help and Support settings
            },
          ),
          ListTile(
            title: const Text('About'),
            onTap: () {
              // Handle About settings
            },
          ),
          ListTile(
            title: const Text('Logout'),
            onTap: () {
              // Handle Logout
            },
          ),
        ],
      ),
    );
  }
}

void main() {
  runApp(const MaterialApp(
    home: SettingsPage(),
  ));
}