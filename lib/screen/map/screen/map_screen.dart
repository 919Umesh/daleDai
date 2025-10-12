import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:lottie/lottie.dart' show Lottie;
import 'package:omspos/constants/constants.dart' show AssetsList;
import 'package:omspos/screen/map/state/map_state.dart';
import 'package:omspos/screen/room/ui/room_screen.dart';
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
                  _showLocationDetails(context, location.title,
                      location.address, location.city, location.propertyId);
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

  void _showLocationDetails(BuildContext context, String title, String address,
      String city, String propertyID) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            Row(
              children: [
                const Icon(Icons.location_pin,
                    color: Colors.redAccent, size: 28),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.home_outlined, size: 22, color: Colors.grey),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    address,
                    style: const TextStyle(fontSize: 15, color: Colors.black87),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.location_city_outlined,
                    size: 22, color: Colors.grey),
                const SizedBox(width: 8),
                Text(
                  city,
                  style: const TextStyle(fontSize: 15, color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => RoomScreen(propertyId: propertyID),
                  ));
                },
                icon: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                label: const Text(
                  'View Details',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
