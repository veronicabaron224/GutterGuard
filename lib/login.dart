import 'package:flutter/material.dart';

class LocationsPage extends StatefulWidget {
  const LocationsPage({super.key});

  @override
  LocationsPageState createState() => LocationsPageState();
}

class LocationsPageState extends State<LocationsPage> {
  String _selectedFilter = 'All';

  List<Map<String, dynamic>> gutterLocations = [
    {
      'name': 'United Nations',
      'picture': 'assets/united_nations.jpg',
      'address': 'United Nations Street',
      'status': 'Clogged',
      'maintenanceStatus': 'Currently assigned to John Doe',
    },
    // Add more gutter locations as needed
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildFilterOption('All'),
                _buildFilterOption('Clogged'),
                _buildFilterOption('Clear'),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: gutterLocations.length,
              itemBuilder: (context, index) {
                final location = gutterLocations[index];
                if (_selectedFilter == 'All' || location['status'] == _selectedFilter) {
                  return _buildLocationItem(location);
                }
                return Container(); // Return an empty container if filtered out
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterOption(String filter) {
    return ElevatedButton(
      onPressed: () {
        setState(() {
          _selectedFilter = filter;
        });
      },
      child: Text(filter),
    );
  }

  Widget _buildLocationItem(Map<String, dynamic> location) {
    return ListTile(
      title: Text(location['name']),
      subtitle: Text(location['address']),
      leading: CircleAvatar(
        backgroundImage: AssetImage(location['picture']),
      ),
      onTap: () {
        _showLocationDetails(location);
      },
    );
  }

  void _showLocationDetails(Map<String, dynamic> location) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(location['name']),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Address: ${location['address']}'),
              Text('Status: ${location['status']}'),
              Text('Maintenance Status: ${location['maintenanceStatus']}'),
              const SizedBox(height: 16),
              const Text('Comments:'),
              // Add a comment section here
              // You can use a TextField for adding comments and show the comments below
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }
}