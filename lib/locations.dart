import 'package:flutter/material.dart';

// Create a data model for gutter locations
class GutterLocation {
  final String name;
  final String imagePath;
  final String address;
  final bool isClogged;
  final String maintenanceStatus;

  GutterLocation({
    required this.name,
    required this.imagePath,
    required this.address,
    required this.isClogged,
    required this.maintenanceStatus,
  });
}

class LocationsPage extends StatefulWidget {
  const LocationsPage({super.key});

  @override
  LocationsPageState createState() => LocationsPageState();
}

class LocationsPageState extends State<LocationsPage> {
  // Define filter options
  static const List<String> filterOptions = ['All', 'Clogged', 'Clear'];

  // Default filter option
  String selectedFilter = 'All';

  // Sample gutter locations
  final List<GutterLocation> gutterLocations = [
    GutterLocation(
      name: 'United Nations',
      imagePath: 'assets/united_nations_gutter.jpg',
      address: 'United Nations Street, City',
      isClogged: true,
      maintenanceStatus: 'Currently assigned to Poncholo Riego de Dios',
    ),
    // Add more gutter locations as needed
    // ...
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Filter options dropdown
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: DropdownButton<String>(
              value: selectedFilter,
              onChanged: (String? newValue) {
                setState(() {
                  selectedFilter = newValue!;
                });
              },
              items: filterOptions.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
          ),
          // Gutter locations list
          Expanded(
            child: ListView.separated(
              itemCount: gutterLocations.length,
              separatorBuilder: (BuildContext context, int index) {
                return const Divider(height: 1, color: Colors.grey);
              },
              itemBuilder: (BuildContext context, int index) {
                final location = gutterLocations[index];

                // Apply filter logic
                if (selectedFilter == 'All' ||
                    (selectedFilter == 'Clogged' && location.isClogged) ||
                    (selectedFilter == 'Clear' && !location.isClogged)) {
                  return ListTile(
                    title: Text(location.name),
                    subtitle: Text(location.address),
                    leading: Image.asset(
                      location.imagePath,
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                    ),
                    onTap: () {
                      // Navigate to details page
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => GutterDetailsPage(location: location),
                        ),
                      );
                    },
                  );
                } else {
                  return const SizedBox.shrink(); // Hidden item if not matching filter
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

class GutterDetailsPage extends StatelessWidget {
  final GutterLocation location;

  const GutterDetailsPage({super.key, required this.location});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(location.name),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset(
              location.imagePath,
              width: 200,
              height: 200,
              fit: BoxFit.cover,
            ),
            const SizedBox(height: 16),
            Text('Address: ${location.address}'),
            Text('Status: ${location.isClogged ? 'Clogged' : 'Clear'}'),
            Text('Maintenance Status: ${location.maintenanceStatus}'),
            // Add more details as needed
            const SizedBox(height: 16),
            // Comment section (you can add more features here)
            const Text('Comments:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            // Add your comment section UI and logic here
          ],
        ),
      ),
    );
  }
}