import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:location/location.dart';
import 'package:latlong2/latlong.dart';
import 'firebase_data.dart';
import 'locations.dart';

class HomeContent extends StatefulWidget {
  final List<GutterLocation> gutterLocations;
  const HomeContent({super.key, required this.gutterLocations});
  
  @override
  HomeContentState createState() => HomeContentState();
}

class HomeContentState extends State<HomeContent> {
  final _location = Location();
  LatLng _userLocation = const LatLng(0.0, 0.0);
  bool _isLoading = true;
  int _pendingCount = 0;
  int _inProgressCount = 0;

  @override
  void initState() {
    super.initState();
    _fetchUserLocation();
    _fetchData();
  }

  Future<void> _handleRefresh() async {
    await _fetchData();
  }

  Future<void> _fetchData() async {
  if (!mounted) return;

  setState(() {
    _isLoading = true;
  });

  try {
    await initializeFirebaseAndFetchData();
    final data = await fetchGutterLocations();
    if (mounted) { 
      setState(() {
        widget.gutterLocations.clear();
        widget.gutterLocations.addAll(data['locations']);
        _pendingCount = data['pendingCount'];
        _inProgressCount = data['inProgressCount'];
        _isLoading = false;
      });
    }
  } catch (error) {
    if (mounted) { // Check again before updating state
      setState(() {
        _isLoading = false;
      });
    }
  }
}

Future<void> _fetchUserLocation() async {
  LocationData? currentLocation;
  try {
    currentLocation = await _location.getLocation();
  } catch (e) {
    logger.severe('Error fetching location: $e');
    return;
  }

  if (mounted) {
    setState(() {
      _userLocation = LatLng(currentLocation!.latitude!, currentLocation.longitude!);
    });
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.4,
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 30.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 2,
                            blurRadius: 2,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20.0),
                        child: SizedBox(
                          width: double.infinity,
                          height: 300.0,
                          child: FlutterMap(
                            options: MapOptions(
                              initialCenter: const LatLng(14.5825, 120.9846),
                              initialZoom: 15,
                              cameraConstraint: CameraConstraint.contain(
                                bounds: LatLngBounds(
                                  const LatLng(14.4137, 120.9384), // Southwest coordinate (Manila)
                                  const LatLng(14.7176, 121.1077), // Northeast coordinate (Manila)
                                ),
                              ),
                              interactionOptions: const InteractionOptions(
                                // flags: ~InteractiveFlag.rotate,
                                enableScrollWheel: true,
                                rotationThreshold: 20.0,
                                pinchZoomThreshold: 0.5,
                                pinchMoveThreshold: 40.0,
                                enableMultiFingerGestureRace: true,
                                debugMultiFingerGestureWinner: true,
                                pinchZoomWinGestures: MultiFingerGesture.pinchZoom,
                                pinchMoveWinGestures: MultiFingerGesture.pinchMove,
                                rotationWinGestures: MultiFingerGesture.rotate,
                              ),
                            ),
                            children: [
                              TileLayer(
                                urlTemplate: 'https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}.png',
                              ),
                              MarkerLayer(
                                markers: _buildMarkers() + _buildUserLocationMarker(),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLegendBox(),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const LocationsPage(selectedMaintenanceFilter: 'Pending'),
                              ),
                            );
                          },
                          child: _buildMaintenanceCountBox(
                            count: _pendingCount,
                            label: 'Pending maintenance:',
                            icon: Icons.pending_actions,
                            color: Colors.amber,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const LocationsPage(selectedMaintenanceFilter: 'In progress'),
                              ),
                            );
                          },
                          child: _buildMaintenanceCountBox(
                            count: _inProgressCount,
                            label: 'Under maintenance:',
                            icon: Icons.published_with_changes,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
      ),
    );
  }

  List<Marker> _buildMarkers() {
    return widget.gutterLocations.map((location) {
      Color markerColor = Colors.transparent;
      if (location.maintenanceStatus == 'pending') {
        markerColor = Colors.red;
      } else if (location.maintenanceStatus == 'inprogress') {
        markerColor = Colors.yellow;
      } else if (location.maintenanceStatus == 'nomaintenancereq') {
        markerColor = Colors.green;
      }

      return Marker(
        width: 100.0,
        height: 60.0,
        point: LatLng(location.latitude, location.longitude),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(location.name, style: const TextStyle(color: Colors.black, fontSize: 12.0, fontWeight: FontWeight.bold)),
            Icon(Icons.location_pin, color: markerColor, size: 40.0)
          ],
        ),
      );
    }).toList();
  }

  List<Marker> _buildUserLocationMarker() {
    return [
      Marker(
        width: 60.0,
        height: 60.0,
        point: _userLocation,
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('You', style: TextStyle(color: Colors.black, fontSize: 12.0, fontWeight: FontWeight.bold)),
            Icon(Icons.location_pin, color: Colors.blue, size: 40.0)
          ],
        ),
      ),
    ];
  }

  Widget _buildMaintenanceCountBox({required int count, required String label, required IconData icon, required Color color}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 2,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      margin: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 4.0),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Icon(
              icon,
              size: 24,
              color: color,
            ),
            const SizedBox(width: 8),
            Text(
              '$label $count',
              style: const TextStyle(fontSize: 16.0),
            ),
          ] 
        ),
      ),
    );
  }

  Widget _buildLegendBox() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 2,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      margin: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 4.0),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(8.0),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                SizedBox(width: 2),
                Text(
                  'Legend',
                  style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.place, size: 24, color: Colors.red),
                SizedBox(width: 8),
                Text(
                  'Pending',
                  style: TextStyle(fontSize: 16.0),
                ),
              ],
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.place, size: 24, color: Colors.yellow),
                SizedBox(width: 8),
                Text(
                  'In progress',
                  style: TextStyle(fontSize: 16.0),
                ),
              ],
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.place, size: 24, color: Colors.green),
                SizedBox(width: 8),
                Text(
                  'No maintenance required',
                  style: TextStyle(fontSize: 16.0),
                ),
              ],
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.place, size: 24, color: Colors.blue),
                SizedBox(width: 8),
                Text(
                  'You',
                  style: TextStyle(fontSize: 16.0),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}