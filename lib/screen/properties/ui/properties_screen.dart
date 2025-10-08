import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:omspos/constants/assets_list.dart';
import 'package:omspos/screen/properties/state/properties_state.dart';
import 'package:omspos/screen/properties/ui/widget/properties_card.dart';
import 'package:omspos/screen/room/ui/room_screen.dart';
import 'package:omspos/services/sharedPreference/preference_keys.dart';
import 'package:omspos/services/sharedPreference/sharedPref_service.dart';
import 'package:provider/provider.dart';

class PropertiesScreen extends StatefulWidget {
  final String? areaId;

  const PropertiesScreen({super.key, this.areaId});

  @override
  State<PropertiesScreen> createState() => _PropertiesScreenState();
}

class _PropertiesScreenState extends State<PropertiesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = Provider.of<PropertiesState>(context, listen: false);
      state.fetchProperties(areaId: widget.areaId ?? '');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PropertiesState>(builder: (context, state, child) {
      if (!state.hasInternet) {
        return Scaffold(
            appBar: AppBar(
              title: Text('No Internet'),
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    AssetsList.noInternet,
                    fit: BoxFit.contain,
                  ),
                  ElevatedButton(
                    onPressed: state.retry,
                    child: Text('Retry'),
                  ),
                ],
              ),
            ));
      }
      if (state.isLoading) {
        return Center(child: Lottie.asset(AssetsList.davsan));
      }
      if (state.errorMessage != null) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error, size: 64),
              Text('Error: ${state.errorMessage}'),
              ElevatedButton(
                onPressed: state.retry,
                child: Text('Try Again'),
              ),
            ],
          ),
        );
      }
      return Scaffold(
        body: CustomScrollView(
          slivers: [
            SliverAppBar(
              pinned: true,
              floating: false,
              snap: false,
              automaticallyImplyLeading: true,
              leading: IconButton(
                icon: Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              title: Text(
                'Properties',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.only(left: 8, right: 8),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  ListView.builder(
                    shrinkWrap: true,
                    physics:
                        const NeverScrollableScrollPhysics(), // so it scrolls with parent CustomScrollView
                    itemCount: state.properties.length,
                    itemBuilder: (context, index) {
                      final property = state.properties[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 5),
                        child: InkWell(
                          onTap: () async {
                            try {
                              await SharedPrefService.setValue<String>(
                                  PrefKey.landLordId, property.landlordId);
                              await SharedPrefService.setValue<String>(
                                  PrefKey.propertyID, property.propertyId);
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => RoomScreen(
                                      propertyId:
                                          property.propertyId.toString())));
                            } catch (e) {
                              debugPrint('Failed to save landlordId: $e');
                            }
                          },
                          child: PropertiesCard(
                            property: property,
                          ),
                        ),
                      );
                    },
                  ),
                ]),
              ),
            ),
          ],
        ),
      );
    });
  }
}
