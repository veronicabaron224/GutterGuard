import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'GutterGuard',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'GutterGuard is a smart device designed to monitor road gutters and detect if they are clogged. It utilizes a float switch mechanism to detect the water level in the gutter, providing real-time information on its status.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            Text(
              'Features:',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            FeatureItem(
              icon: Icons.check_circle_outline,
              text: 'Real-time Monitoring',
            ),
            FeatureItem(
              icon: Icons.notification_important_outlined,
              text: 'Alerts on Clogging',
            ),
            FeatureItem(
              icon: Icons.settings_outlined,
              text: 'Easy Installation',
            ),
            SizedBox(height: 20),
            Text(
              'Purpose:',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'The goal of GutterGuard is to provide convenience to road maintenance workers by giving them awareness of gutter clogs without needing to be physically present. This helps in timely maintenance and prevents potential flooding issues.',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}

class FeatureItem extends StatelessWidget {
  final IconData icon;
  final String text;

  const FeatureItem({
    super.key,
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(
            icon,
            size: 24,
            color: Theme.of(context).primaryColor,
          ),
          const SizedBox(width: 10),
          Text(
            text,
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }
}