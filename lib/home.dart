import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class HomeContent extends StatelessWidget {
  const HomeContent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20.0),
          child: SizedBox(
            width: double.infinity,
            height: 300.0,
            child: FlutterMap(
              options: MapOptions(
                center: const LatLng(14.5825, 120.9846),
                zoom: 15,
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
