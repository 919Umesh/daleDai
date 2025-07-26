import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:omspos/screen/home/model/property_model.dart';
import 'package:omspos/screen/map/state/map_state.dart';
import 'package:provider/provider.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ChangeNotifierProvider(
        create: (context) => MapState()..getContext = context,
        child: Consumer<MapState>(
          builder: (context, state, child) {
            return Stack(
              children: [
                FlutterMap(
                  mapController: state.mapController,
                  options: MapOptions(
                    initialCenter:
                        state.currentPosition ?? const LatLng(27.7172, 85.3240),
                    initialZoom: 13.0,
                    maxZoom: 18.0,
                    minZoom: 10.0,
                    onMapReady: () {
                      if (state.currentPosition != null) {
                        state.mapController.move(state.currentPosition!, 14.0);
                      }
                    },
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.example.omspos',
                    ),
                    MarkerLayer(
                      markers: [
                        if (state.currentPosition != null)
                          Marker(
                            point: state.currentPosition!,
                            width: 40,
                            height: 40,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.blue,
                                shape: BoxShape.circle,
                                border:
                                    Border.all(color: Colors.white, width: 3),
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
                        ...state.properties.map(
                          (property) => Marker(
                            point:
                                LatLng(property.latitude, property.longitude),
                            width: 44,
                            height: 44,
                            child: GestureDetector(
                              onTap: () =>
                                  _navigateToProperty(property, context),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: property.isActive
                                      ? Colors.green
                                      : Colors.orange,
                                  shape: BoxShape.circle,
                                  border:
                                      Border.all(color: Colors.white, width: 2),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.2),
                                      spreadRadius: 1,
                                      blurRadius: 3,
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  _getPropertyIcon(property.propertyType),
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Positioned(
                  top: MediaQuery.of(context).padding.top + 16,
                  left: 16,
                  right: 16,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
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
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '${state.properties.length} properties',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            IconButton(
                              onPressed: () => state.centerMapOnUserLocation(),
                              icon: Icon(
                                Icons.my_location,
                                color: Theme.of(context).primaryColor,
                              ),
                              tooltip: 'Center on my location',
                            ),
                            IconButton(
                              onPressed: () => state.refreshProperties(),
                              icon: Icon(
                                Icons.refresh,
                                color: Theme.of(context).primaryColor,
                              ),
                              tooltip: 'Refresh properties',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                if (state.isLoadingLocation)
                  const Center(
                    child: CircularProgressIndicator(),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _navigateToProperty(PropertyModel property, BuildContext context) {
    // Implement property details navigation
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(property.title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(property.address),
            const SizedBox(height: 8),
            Text('${property.city}, ${property.state} - ${property.pincode}'),
            const SizedBox(height: 8),
            Text('Type: ${property.propertyType}'),
            Text('Area: ${property.areaSqft} sqft'),
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
  }

  IconData _getPropertyIcon(String propertyType) {
    switch (propertyType.toLowerCase()) {
      case 'apartment':
        return Icons.apartment;
      case 'house':
        return Icons.house;
      case 'villa':
        return Icons.villa;
      case 'office':
        return Icons.work;
      case 'land':
        return Icons.landscape;
      default:
        return Icons.location_on;
    }
  }
}
