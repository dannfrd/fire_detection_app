import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

import '../providers/fire_detection_provider.dart';
import '../utils/app_theme.dart';

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
        title: const Text(
          'Fire Locations Map',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
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
                myLocationEnabled: true,
                myLocationButtonEnabled: true,
                mapToolbarEnabled: true,
                compassEnabled: true,
                mapType: MapType.normal,
                zoomControlsEnabled: false, // We'll add our own fab instead
              ),
              if (provider.isLoading)
                Container(
                  color: Colors.black.withOpacity(0.3),
                  child: const Center(
                    child: CircularProgressIndicator(
                      color: Colors.white,
                    ),
                  ),
                ),
              Positioned(
                top: 16,
                left: 16,
                right: 16,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.shadowColor,
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryGreen.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.local_fire_department_rounded,
                          color: AppTheme.primaryGreen,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Fire Locations: ${provider.fireLocations.length}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                bottom: 24,
                right: 16,
                child: FloatingActionButton(
                  backgroundColor: AppTheme.primaryGreen,
                  foregroundColor: Colors.white,
                  elevation: 4,
                  onPressed: () {
                    // You could center the map on current position or most recent fire
                    if (provider.fireLocations.isNotEmpty) {
                      // Future enhancement: add map controller to animate to position
                    }
                  },
                  child: const Icon(Icons.my_location_rounded),
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
