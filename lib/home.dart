import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class HomeContent extends StatelessWidget {
  const HomeContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        margin: const EdgeInsets.all(18.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20.0),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 5,
              blurRadius: 7,
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
              options: const MapOptions(
                initialCenter: LatLng(14.5825, 120.9846),
                initialZoom: 15,
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
