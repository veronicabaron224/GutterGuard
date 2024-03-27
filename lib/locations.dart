import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:logging/logging.dart';
import 'firebase_options.dart';

final Logger _logger = Logger('GutterLocations');
dynamic gutterlocfetch; // FOR DEBUGGING
dynamic gutterlocrefresh; // FOR DEBUGGING
dynamic firebaseinit; // FOR DEBUGGING
bool working = false; // FOR DEBUGGING

// Data model for gutter locations
class GutterLocation {
  final String name;
  final String address;
  final bool isClogged;
  final bool maintenanceStatus;

  GutterLocation({
    required this.name,
    required this.address,
    required this.isClogged,
    required this.maintenanceStatus,
  });
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const LocationsPage());
}

class LocationsPage extends StatefulWidget {
  const LocationsPage({super.key});

  @override
  LocationsPageState createState() => LocationsPageState();
}

class LocationsPageState extends State<LocationsPage> {
  String selectedFilter = 'All';
  List<GutterLocation> gutterLocations = [];

  @override
  void initState() {
    super.initState();
    initializeFirebaseAndFetchData();
  }

  Future<void> initializeFirebaseAndFetchData() async {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      await fetchGutterLocations();
      working = true; // FOR DEBUGGING
    } catch (error) {
      _logger.severe("Error initializing Firebase or fetching gutter locations: $error");
      firebaseinit = error; // FOR DEBUGGING
    }
  }

  Future<void> fetchGutterLocations() async {
    try {
      DatabaseReference ref = FirebaseDatabase.instance.ref().child('GutterLocations');

      DataSnapshot snapshot = await ref.once().then((event) => event.snapshot);

      List<GutterLocation> locations = [];
      Map<dynamic, dynamic> values = snapshot.value as Map<dynamic, dynamic>;

      values.forEach((key, value) {
        locations.add(GutterLocation(
          name: value['name'],
          address: value['address'],
          isClogged: value['isClogged'],
          maintenanceStatus: value['maintenanceStatus'],
        ));
      });

      setState(() {
        gutterLocations = locations;
      });
    } catch (error) {
      _logger.severe("Error fetching gutter locations: $error");
      gutterlocfetch = error; // FOR DEBUGGING
    }
  }

  Future<void> _refreshLocations() async {
    try {
      await fetchGutterLocations();
    } catch (error) {
      _logger.severe("Error refreshing gutter locations: $error");
      gutterlocrefresh = error; // FOR DEBUGGING
    }
  }

  @override
  Widget build(BuildContext context) {
    debugPrint("Firebase initialization: $working"); // FOR DEBUGGING
    working = false; // FOR DEBUGGING
    debugPrint("Error initializing Firebase or fetching gutter locations: $firebaseinit"); // FOR DEBUGGING
    debugPrint("Error fetching gutter locations: $gutterlocfetch"); // FOR DEBUGGING
    debugPrint("Error refreshing gutter locations: $gutterlocrefresh"); // FOR DEBUGGING
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _refreshLocations,
        child: Column(
          children: [
            // Filter options buttons
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          selectedFilter = 'All';
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: selectedFilter == 'All' ? Colors.orange[300] : null,
                        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                      ),
                      child: const Text('All'),
                    ),
                  ),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          selectedFilter = 'Clogged';
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: selectedFilter == 'Clogged' ? Colors.orange[300] : null,
                        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                      ),
                      child: const Text('Clogged'),
                    ),
                  ),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          selectedFilter = 'Clear';
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: selectedFilter == 'Clear' ? Colors.orange[300] : null,
                        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                      ),
                      child: const Text('Clear'),
                    ),
                  ),
                ],
              ),
            ),
            // Gutter locations list
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0),
                child: ListView.builder(
                  itemCount: gutterLocations.length,
                  itemBuilder: (BuildContext context, int index) {
                    final location = gutterLocations[index];

                    // Apply filter logic
                    if (selectedFilter == 'All' ||
                        (selectedFilter == 'Clogged' && location.isClogged) ||
                        (selectedFilter == 'Clear' && !location.isClogged)) {
                      return ListTile(
                        title: Text(location.name),
                        subtitle: Text(location.address),
                        leading: const Icon(
                          Icons.location_pin,
                          size: 35,
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
            ),
          ],
        ),
      ),
    );
  }
}

class GutterDetailsPage extends StatefulWidget {
  final GutterLocation location;

  const GutterDetailsPage({super.key, required this.location});

  @override
  GutterDetailsPageState createState() => GutterDetailsPageState();
}

class GutterDetailsPageState extends State<GutterDetailsPage> {
  String comment = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.location.name),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            Text('Address: ${widget.location.address}'),
            Text('Status: ${widget.location.isClogged ? 'Clogged' : 'Clear'}'),
            Text('Maintenance: ${widget.location.maintenanceStatus ? 'In Progress' : 'Unassigned'}'),
            const SizedBox(height: 16),
            const Text(
              'Comments:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            TextField(
              onChanged: (value) {
                setState(() {
                  comment = value;
                });
              },
              decoration: const InputDecoration(
                hintText: 'Write your comment...',
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                if (comment.isNotEmpty) {
                  Text(
                    'Posted comment: $comment',
                    // Other properties like style, alignment, etc. can be added here
                  );
                  setState(() {
                    comment = '';
                  });
                }
              },
              child: const Text('Comment'),
            ),
          ],
        ),
      ),
    );
  }
}