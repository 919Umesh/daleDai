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
        return Scaffold(
          appBar: AppBar(title: const Text('Properties')),
          body: Center(child: Lottie.asset(AssetsList.davsan)),
        );
      }
      if (state.errorMessage != null) {
        return Scaffold(
          appBar: AppBar(title: const Text('Properties')),
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.error_outline,
                      size: 64, color: Theme.of(context).colorScheme.error),
                  const SizedBox(height: 12),
                  Text(state.errorMessage!, textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: state.retry,
                    child: const Text('Try Again'),
                  ),
                ],
              ),
            ),
          ),
        );
      }
      return Scaffold(
        body: RefreshIndicator(
          onRefresh: () async {
            if (state.currentAreaId != null &&
                state.currentAreaId!.isNotEmpty) {
              await state.loadPropertiesByArea(state.currentAreaId!,
                  refresh: true);
            } else {
              await state.loadAllProperties(refresh: true);
            }
          },
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                pinned: true,
                floating: false,
                snap: false,
                automaticallyImplyLeading: true,
                title: const Text(
                  'Properties',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (state.properties.isEmpty)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(child: Text('No properties found')),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  sliver: SliverList.builder(
                    itemCount: state.properties.length,
                    itemBuilder: (context, index) {
                      final property = state.properties[index];
                      return InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () async {
                          try {
                            await SharedPrefService.setValue<String>(
                                PrefKey.landLordId, property.landlordId);
                            await SharedPrefService.setValue<String>(
                                PrefKey.propertyID, property.propertyId);
                            if (!context.mounted) return;
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => RoomScreen(
                                    propertyId: property.propertyId)));
                          } catch (e) {
                            debugPrint('Failed to open property: $e');
                          }
                        },
                        child: PropertiesCard(property: property),
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      );
    });
  }
}
