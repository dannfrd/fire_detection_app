import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import '../providers/fire_detection_provider.dart';
import '../utils/app_theme.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  List<Marker> _markers = [];
  final MapController _mapController = MapController();

  static const LatLng _initialPosition = LatLng(-7.7956, 110.3695); // Yogyakarta, Indonesia

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
              FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: _initialPosition,
                  initialZoom: 14.0,
                  keepAlive: true,
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.example.fire_detections_app',
                    subdomains: const ['a', 'b', 'c'],
                  ),
                  MarkerLayer(markers: _markers),
                ],
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
                    // Center the map on current position or most recent fire
                    if (provider.fireLocations.isNotEmpty) {
                      final latestLocation = provider.fireLocations.first;
                      _mapController.move(
                        LatLng(latestLocation.latitude, latestLocation.longitude),
                        15.0,
                      );
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
        width: 40.0,
        height: 40.0,
        point: LatLng(location.latitude, location.longitude),
        child: GestureDetector(
          onTap: () {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Fire Detection'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Severity: ${location.severity}'),
                    Text('Time: ${location.timestamp.toString().substring(0, 16)}'),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Close'),
                  ),
                ],
              ),
            );
          },
          child: Icon(
            Icons.local_fire_department_rounded,
            color: location.severity == 'Critical'
                ? Colors.red
                : location.severity == 'Warning'
                    ? Colors.orange
                    : Colors.green,
            size: 40.0,
          ),
        ),
      );
    }).toList();
  }
}
