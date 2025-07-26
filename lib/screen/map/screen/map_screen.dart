import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:omspos/screen/map/state/map_state.dart'; // Adjust import path

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MapState>()..getContext = context;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MapState(),
      child: Consumer<MapState>(
        builder: (context, mapState, child) {
          return Scaffold(
            body: Stack(
              children: [
                // Map Widget
                FlutterMap(
                  mapController: mapState.mapController,
                  options: MapOptions(
                    initialCenter: mapState.currentPosition ??
                        const LatLng(27.7172, 85.3240), // Default Kathmandu
                    initialZoom: 13.0,
                    maxZoom: 18.0,
                    minZoom: 5.0,
                  ),
                  children: [
                    // Tile Layer (OpenStreetMap)
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.example.omspos', // Replace with your package name
                    ),
                    // Marker Layer for Properties
                    MarkerLayer(
                      markers: mapState.markers, // Use markers from state
                    ),
                    // Marker Layer for User Location (if available)
                    if (mapState.currentPosition != null)
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: mapState.currentPosition!,
                            width: 40,
                            height: 40,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.blue,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 3),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.3),
                                    spreadRadius: 1,
                                    blurRadius: 3,
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.my_location,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),

                // Top Overlay (Title, Count, Controls)
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.5),
                          Colors.transparent,
                        ],
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Properties Map',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              '${mapState.properties.length} properties',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            GestureDetector(
                              onTap: mapState.isLoadingLocation
                                  ? null
                                  : () => mapState.centerMapOnUserLocation(),
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.9),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.my_location,
                                  color: Theme.of(context).primaryColor,
                                  size: 18,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            GestureDetector(
                              onTap: mapState.isLoading
                                  ? null
                                  : () => mapState.refreshMap(),
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.9),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.refresh,
                                  color: Theme.of(context).primaryColor,
                                  size: 18,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // Loading Indicator for Location
                if (mapState.isLoadingLocation)
                  Positioned(
                    bottom: 16,
                    right: 16,
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              // color: Theme.of(context).primaryColor,
                            ),
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Getting location...',
                            style: TextStyle(fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                  ),

                // Loading Indicator for Properties
                 if (mapState.isLoading && !mapState.isLoadingLocation)
                  const Center(
                    child: CircularProgressIndicator(),
                  ),

                // Error Message Display
                if (mapState.errorMessage != null)
                  Positioned(
                    top: kToolbarHeight + 20, // Below AppBar
                    left: 20,
                    right: 20,
                    child: Card(
                      color: Colors.red.shade100,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'Error: ${mapState.errorMessage}',
                          style: const TextStyle(color: Colors.red, fontSize: 12),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
