import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

import '../providers/fire_detection_provider.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  Set<Marker> _markers = {};

  static const CameraPosition _initialPosition = CameraPosition(
    target: LatLng(-7.7956, 110.3695), // Yogyakarta, Indonesia
    zoom: 14,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fire Locations'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<FireDetectionProvider>().refreshData();
            },
          ),
        ],
      ),
      body: Consumer<FireDetectionProvider>(
        builder: (context, provider, child) {
          _updateMarkers(provider.fireLocations);

          return Stack(
            children: [
              GoogleMap(
                initialCameraPosition: _initialPosition,
                markers: _markers,
                onMapCreated: (GoogleMapController controller) {
                  // Map controller can be used for future features
                },
                myLocationEnabled: false,
                myLocationButtonEnabled: false,
              ),
              if (provider.isLoading)
                Container(
                  color: Colors.black26,
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
              Positioned(
                top: 16,
                left: 16,
                right: 16,
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text(
                      'Fire Locations: ${provider.fireLocations.length}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _updateMarkers(List<dynamic> fireLocations) {
    _markers = fireLocations.map((location) {
      return Marker(
        markerId: MarkerId('fire_${location.timestamp.millisecondsSinceEpoch}'),
        position: LatLng(location.latitude, location.longitude),
        infoWindow: InfoWindow(
          title: 'Fire Detection',
          snippet:
              'Severity: ${location.severity}\nTime: ${location.timestamp.toString().substring(0, 16)}',
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(
          location.severity == 'Critical'
              ? BitmapDescriptor.hueRed
              : location.severity == 'Warning'
                  ? BitmapDescriptor.hueOrange
                  : BitmapDescriptor.hueGreen,
        ),
      );
    }).toSet();
  }
}
