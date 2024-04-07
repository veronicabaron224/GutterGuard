import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'firebase_data.dart';

class HomeContent extends StatefulWidget {
  final List<GutterLocation> gutterLocations;
  const HomeContent({super.key, required this.gutterLocations});
  
  @override
  HomeContentState createState() => HomeContentState();
}

class HomeContentState extends State<HomeContent> {
  bool _isLoading = true;
  int _pendingCount = 0;
  int _inProgressCount = 0;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await initializeFirebaseAndFetchData();
      final data = await fetchGutterLocations();
      setState(() {
        widget.gutterLocations.clear();
        widget.gutterLocations.addAll(data['locations']);
        _pendingCount = data['pendingCount'];
        _inProgressCount = data['inProgressCount'];
        _isLoading = false;
      });
    } catch (error) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleRefresh() async {
    await _fetchData();
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
                              markers: _buildMarkers(),
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
                        _buildMaintenanceCountBox(
                          count: _pendingCount,
                          label: 'drainages are pending maintenance',
                        ),
                        _buildMaintenanceCountBox(
                          count: _inProgressCount,
                          label: 'drainages are currently under maintenance',
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
      Color markerColor = location.isClogged ? Colors.red : Colors.blue;
      return Marker(
        width: 30.0,
        height: 30.0,
        point: LatLng(location.latitude, location.longitude),
        child: Icon(Icons.location_pin, color: markerColor, size: 40.0),
      );
    }).toList();
  }

  Widget _buildMaintenanceCountBox({required int count, required String label}) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.0),
        border: Border.all(color: Colors.black),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 4.0),
      child: SizedBox(
        width: double.infinity,
        child: Container(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            '$count $label',
            style: const TextStyle(fontSize: 16.0),
          ),
        ),
      ),
    );
  }
}