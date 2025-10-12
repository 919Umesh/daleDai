import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:lottie/lottie.dart' show Lottie;
import 'package:omspos/constants/constants.dart' show AssetsList;
import 'package:omspos/screen/map/state/map_state.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> with TickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<MapState>(context, listen: false).getContext = context;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Consumer<MapState>(
        builder: (context, state, _) {
          if (state.isLoadingLocation || state.isLoading) {
            return Center(child: Lottie.asset(AssetsList.davsan));
          }

          if (state.errorMessage != null) {
            return Center(
              child: Text(
                state.errorMessage!,
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          final LatLng center =
              state.currentPosition ?? const LatLng(27.7172, 85.3240);

          final markers = state.locations.map((location) {
            return Marker(
              width: 45.0,
              height: 45.0,
              point: LatLng(location.latitude, location.longitude),
              child: GestureDetector(
                onTap: () {
                  _showLocationDetails(
                      context, location.title, location.address, location.city);
                },
                child: const Icon(
                  Icons.location_pin,
                  size: 40,
                  color: Colors.redAccent,
                ),
              ),
            );
          }).toList();

          if (state.currentPosition != null) {
            markers.add(
              Marker(
                width: 40,
                height: 40,
                point: state.currentPosition!,
                child: const Icon(
                  Icons.my_location,
                  color: Colors.blueAccent,
                  size: 30,
                ),
              ),
            );
          }

          return Scaffold(
            body: FlutterMap(
              mapController: state.mapController,
              options: MapOptions(
                initialCenter: center,
                initialZoom: 18.0,
                interactionOptions: const InteractionOptions(
                  flags: InteractiveFlag.all,
                ),
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.oms.omspos.posoms.omspos',
                ),
                MarkerLayer(markers: markers),
                RichAttributionWidget(
                  attributions: [
                    TextSourceAttribution(
                      'OpenStreetMap contributors',
                      onTap: () => launchUrl(
                        Uri.parse('https://openstreetmap.org/copyright'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
            floatingActionButton: Column(
              children: [
                FloatingActionButton(
                  heroTag: 'refreshBtn',
                  onPressed: () async {
                    await state.refresh();
                  },
                  mini: true,
                  tooltip: 'Refresh Map Data',
                  child: const Icon(Icons.refresh),
                ),
                FloatingActionButton(
                  heroTag: 'recenterBtn',
                  onPressed: () {
                    state.moveToCurrentLocation();
                  },
                  mini: true,
                  tooltip: 'Recenter to Current Location',
                  child: const Icon(Icons.my_location),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showLocationDetails(
      BuildContext context, String title, String address, String city) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(address),
            Text(city, style: const TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}
