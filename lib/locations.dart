import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:logging/logging.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'firebase_data.dart';

final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();
final Logger _logger = Logger('GutterLocations');

void main() {
  runApp(const LocationsPage());
}

class LocationsPage extends StatefulWidget {
  final String? selectedMaintenanceFilter;
  const LocationsPage({super.key, this.selectedMaintenanceFilter = 'All'});

  @override
  LocationsPageState createState() => LocationsPageState();
}

class LocationsPageState extends State<LocationsPage> {
  late Future<void> _dataLoadingFuture;
  String selectedStatusFilter = 'All';
  String selectedMaintenanceFilter = 'All';
  List<GutterLocation> gutterLocations = [];
  final List<String> statusFilters = ['All', 'Clogged', 'Clear'];
  final List<String> maintenanceFilters = ['All', 'Pending', 'In progress', 'No maintenance required'];
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _dataLoadingFuture = initializeFirebaseAndFetchData();
    _fetchGutterLocationsAndApplyFilters();
    searchController.addListener(_onSearchTextChanged);
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _refreshLocations,
      child:  Scaffold(
        appBar: AppBar(
          title: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey),
            ),
            child: TextField(
              controller: searchController,
              decoration: const InputDecoration(
                hintText: 'Search...',
                hintStyle: TextStyle(color: Colors.grey, fontSize: 14.5),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 15),
              ),
              style: const TextStyle(color: Colors.black),
            ),
          ),
          actions: [
            IconButton(
              onPressed: _showFilterMenu,
              icon: const Icon(Icons.filter_list),
            ),
          ],
        ),
        body: FutureBuilder<void>(
          future: _dataLoadingFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else if (snapshot.hasError) {
              return Center(
                child: Text('Error occurred: ${snapshot.error}'),
              );
            } else {
              return _buildLocationList();
            }
          },
        ),
      )
    );
  }

  Future<void> _fetchGutterLocationsAndApplyFilters() async {
    try {
      await _fetchGutterLocations();
      _applyFilters();
    } catch (error) {
      _logger.severe("Error fetching gutter locations: $error");
    }
  }

  Future<void> _fetchGutterLocations() async {
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

      setState(() {
        gutterLocations = locations;
      });
    } catch (error) {
      _logger.severe("Error fetching gutter locations: $error");
    }
  }

  Future<void> _applyFilters() async {
    List<GutterLocation> filteredLocations = [];
    try {
      if (gutterLocations.isEmpty) {
        await _fetchGutterLocations();
      }

      if (searchController.text.isNotEmpty) {
        filteredLocations = gutterLocations.where((location) {
          bool matchesSearch = location.name.toLowerCase().contains(searchController.text.toLowerCase()) ||
              location.address.toLowerCase().contains(searchController.text.toLowerCase());
          return matchesSearch;
        }).toList();
      } else {
        filteredLocations = List.from(gutterLocations);
      }

      filteredLocations = filteredLocations.where((location) {
        bool matchesStatusFilter = selectedStatusFilter == 'All' ||
            (selectedStatusFilter == 'Clogged' && location.isClogged) ||
            (selectedStatusFilter == 'Clear' && !location.isClogged);
        bool matchesMaintenanceFilter = selectedMaintenanceFilter == 'All' ||
            (selectedMaintenanceFilter == 'In progress' && location.maintenanceStatus == 'inprogress') ||
            (selectedMaintenanceFilter == 'Pending' && location.maintenanceStatus == 'pending') ||
            (selectedMaintenanceFilter == 'No maintenance required' && location.maintenanceStatus == 'nomaintenancereq');
        return matchesStatusFilter && matchesMaintenanceFilter;
      }).toList();

      setState(() {
        gutterLocations = filteredLocations;
      });

      await _refreshLocations();
    } catch (error) {
      _scaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(
          content: Text('Error fetching gutter locations: $error'),
        ),
      );
    }
  }

  void _onSearchTextChanged() {
    setState(() {
      _applyFilters();
    });
  }

  Future<void> _refreshLocations() async {
    try {
      await _fetchGutterLocations();
    } catch (error) {
      _logger.severe("Error refreshing gutter locations: $error");
    }
  }

  List<GutterLocation> getGutterLocations() {
    return gutterLocations;
  }

  void _showFilterMenu() {
    showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Status',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Wrap(
                    spacing: 8,
                    children: statusFilters.map((filter) {
                      return ChoiceChip(
                        label: Text(filter),
                        selected: selectedStatusFilter == filter,
                        onSelected: (selected) {
                          setState(() {
                            selectedStatusFilter = filter;
                            if (filter == 'Clear') {
                              selectedMaintenanceFilter = 'No maintenance required';
                            } else if (filter == 'Clogged') {
                              selectedMaintenanceFilter = 'All';
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Maintenance',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Wrap(
                    spacing: 8,
                    children: maintenanceFilters.map((filter) {
                      bool locked = (selectedStatusFilter == 'Clear' && (filter == 'Pending' || filter == 'In progress')) ||
                          (selectedStatusFilter == 'Clogged' && filter == 'No maintenance required');
                      return Opacity(
                        opacity: locked ? 0.5 : 1.0,
                        child: ChoiceChip(
                          label: Text(filter),
                          selected: selectedMaintenanceFilter == filter,
                          onSelected: locked ? null : (selected) {
                            setState(() {
                              selectedMaintenanceFilter = filter;
                            });
                          },
                          backgroundColor: locked ? Colors.grey : null,
                          selectedColor: locked ? Colors.grey[400] : null,
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      _applyFilters();
                    },
                    child: const Text('Apply Filters'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildLocationList() {
    return Column(
      children: [
        Expanded(
          child: gutterLocations.isEmpty
            ? const Center(
                child: Text(
                  'You have no devices to display', // IF DB HAS NO LOCATIONS. DI PA TO NAGANA NG MAAYOS
                  style: TextStyle(fontSize: 16.0),
                ),
              )
            : Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25.0),
            child: ListView.builder(
              itemCount: gutterLocations.length,
              itemBuilder: (BuildContext context, int index) {
                final location = gutterLocations[index];
    
                bool matchesSearch = searchController.text.isEmpty ||
                    location.name.toLowerCase().contains(searchController.text.toLowerCase()) ||
                    location.address.toLowerCase().contains(searchController.text.toLowerCase());
                bool matchesStatusFilter = selectedStatusFilter == 'All' ||
                    (selectedStatusFilter == 'Clogged' && location.isClogged) ||
                    (selectedStatusFilter == 'Clear' && !location.isClogged);
                bool matchesMaintenanceFilter = selectedMaintenanceFilter == 'All' ||
                    (selectedMaintenanceFilter == 'In progress' && location.maintenanceStatus == 'inprogress') ||
                    (selectedMaintenanceFilter == 'Pending' && location.maintenanceStatus == 'pending') ||
                    (selectedMaintenanceFilter == 'No maintenance required' && location.maintenanceStatus == 'nomaintenancereq');
    
                if (matchesSearch &&
                    matchesStatusFilter &&
                    matchesMaintenanceFilter) {
                  return ListTile(
                    title: Text(location.name),
                    subtitle: Text(location.address),
                    leading: const Icon(
                      Icons.location_pin,
                      size: 35,
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => GutterDetailsPage(location: location),
                        ),
                      );
                    },
                  );
                } else {
                  return const SizedBox.shrink();
                }
              },
            ),
          ),
        ),
      ],
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
    String maintenanceStatusText = '';

    if (widget.location.maintenanceStatus.toLowerCase().contains('pending')) {
      maintenanceStatusText = 'Pending';
    } else if (widget.location.maintenanceStatus.toLowerCase().contains('inprogress')) {
      maintenanceStatusText = 'In progress';
    } else if (widget.location.maintenanceStatus.toLowerCase().contains('nomaintenancereq')) {
      maintenanceStatusText = 'No maintenance required';
    }
    
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.location.name),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            flex: 2,
            child: FlutterMap(
              options: MapOptions(
                initialCenter: LatLng(widget.location.latitude, widget.location.longitude),
                initialZoom: 17,
                cameraConstraint: CameraConstraint.contain(
                  bounds: LatLngBounds(
                    // LatLng(widget.location.latitude - 0.003, widget.location.longitude - 0.003),
                    // LatLng(widget.location.latitude + 0.003, widget.location.longitude + 0.003),
                    const LatLng(14.4137, 120.9384), // Southwest coordinate (Manila)
                    const LatLng(14.7176, 121.1077), // Northeast coordinate (Manila)
                  ),
                ),
                interactionOptions: const InteractionOptions(
                  // flags: ~InteractiveFlag.rotate,
                ),
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}.png',
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      width: 40.0,
                      height: 40.0,
                      point: LatLng(widget.location.latitude, widget.location.longitude),
                      child: const Icon(
                        Icons.location_pin,
                        color: Colors.pink,
                        size: 40.0,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Address: ${widget.location.address}'),
                  Text('Status: ${widget.location.isClogged ? 'Clogged' : 'Clear'}'),
                  Text('Maintenance: $maintenanceStatusText'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String getMaintenanceStatusText(String status) {
    if (status.toLowerCase().contains('pending')) {
      return 'Pending';
    } else if (status.toLowerCase().contains('inprogress')) {
      return 'In Progress';
    } else if (status.toLowerCase().contains('nomaintenancereq')) {
      return 'No Maintenance Required';
    } else {
      return 'Unknown';
    }
  }
}