import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:omspos/constants/assets_list.dart';
import 'package:omspos/screen/home/state/home_state.dart';
import 'package:omspos/screen/index/state/index_state.dart';
import 'package:omspos/screen/properties/ui/properties_screen.dart';
import 'package:omspos/screen/room/room.dart';
import 'package:omspos/services/language/translation_extension.dart';
import 'package:omspos/services/sharedPreference/preference_keys.dart';
import 'package:omspos/services/sharedPreference/sharedPref_service.dart';
import 'package:omspos/themes/fonts_style.dart';
import 'package:omspos/screen/home/ui/widget/profile_modal.dart';
import 'package:omspos/screen/home/ui/widget/property_modal.dart';
import 'package:omspos/screen/home/ui/widget/resort_card.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  late ScrollController _scrollController;
  double _lastScrollOffset = 0;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<HomeState>(context, listen: false).getContext = context;
    });
  }

  void _scrollListener() {
    final currentScrollOffset = _scrollController.offset;
    final indexState = Provider.of<IndexState>(context, listen: false);
    if (currentScrollOffset > _lastScrollOffset && currentScrollOffset > 100) {
      indexState.hideBottomBar();
    } else if (currentScrollOffset < _lastScrollOffset) {
      indexState.showBottomBar();
    }

    _lastScrollOffset = currentScrollOffset;
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeState>(
      builder: (context, state, child) {
        if (!state.hanInternet) {
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
        return SafeArea(
          child: Scaffold(
            body: CustomScrollView(
              controller: _scrollController,
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.only(left: 8, right: 8),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      ProfileModalWidget(
                        userModel: state.user,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 16, bottom: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              context.translate('best_destination'),
                              style: titleListTextStyle,
                            ),
                            InkWell(
                              onTap: () {
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) => PropertiesScreen()));
                              },
                              child: Text(
                                context.translate('view_all'),
                                style: subTitleTextStyle,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 200,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: state.areas.length,
                          itemBuilder: (context, index) {
                            final area = state.areas[index];
                            return Padding(
                              padding: const EdgeInsets.only(right: 12.0),
                              child: InkWell(
                                onTap: () {
                                  Navigator.of(context).push(MaterialPageRoute(
                                      builder: (context) => PropertiesScreen(
                                          areaId: area.areaId)));
                                },
                                child: PropertyModalWidget(
                                  area: area,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 16, bottom: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              context.translate('recommended_destination'),
                              style: titleListTextStyle,
                            ),
                            Text(
                              context.translate('view_all'),
                              style: subTitleTextStyle,
                            ),
                          ],
                        ),
                      ),
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
                                  // Handle error if saving fails
                                  debugPrint('Failed to save landlordId: $e');
                                }
                              },
                              child: ResortCard(
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
          ),
        );
      },
    );
  }
}
