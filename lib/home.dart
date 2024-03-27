import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class HomeContent extends StatelessWidget {
  const HomeContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        margin: const EdgeInsets.symmetric(horizontal: 30.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20.0),
          // boxShadow: [
          //   BoxShadow(
          //     color: Colors.grey.withOpacity(0.2),
          //     spreadRadius: 5,
          //     blurRadius: 7,
          //     offset: const Offset(0, 3),
          //   ),
          // ],
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
                  urlTemplate: 'https://mt0.google.com/vt/lyrs=m&x={x}&y={y}&z={z}',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
