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
import 'package:omspos/screen/home/ui/widget/profile_modal.dart';
import 'package:omspos/screen/home/ui/widget/property_modal.dart';
import 'package:omspos/screen/home/ui/widget/resort_card.dart';
import 'package:omspos/themes/theme_state.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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
    final currentOffset = _scrollController.offset;
    final indexState = Provider.of<IndexState>(context, listen: false);
    if (currentOffset > _lastScrollOffset && currentOffset > 100) {
      indexState.hideBottomBar();
    } else if (currentOffset < _lastScrollOffset) {
      indexState.showBottomBar();
    }
    _lastScrollOffset = currentOffset;
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeState>(
      builder: (context, state, child) {
        if (!state.hanInternet) {
          return _errorState(
            context,
            icon: Icons.wifi_off_rounded,
            title: 'No Internet',
            subtitle: 'Please check your connection and try again.',
            onRetry: state.retry,
          );
        }
        if (state.isLoading) {
          return Scaffold(
            body: Center(child: Lottie.asset(AssetsList.davsan, width: 200)),
          );
        }
        if (state.errorMessage != null) {
          return _errorState(
            context,
            icon: Icons.error_outline_rounded,
            title: 'Something went wrong',
            subtitle: state.errorMessage ?? '',
            onRetry: state.retry,
          );
        }

        return SafeArea(
          child: Scaffold(
            body: RefreshIndicator(
              onRefresh: () async {
                await state.refreshProfile();
                await state.refreshAreas();
                await state.refreshProperties();
              },
              child: CustomScrollView(
                controller: _scrollController,
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        const SizedBox(height: 8),
                        // Header / search
                        ProfileModalWidget(userModel: state.user),
                        const SizedBox(height: 20),

                        // Best Destination section
                        _SectionHeader(
                          title: context.translate('best_destination'),
                          onViewAll: () => Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (_) => PropertiesScreen()),
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 210,
                          child: state.areas.isEmpty
                              ? const _EmptySection(
                                  icon: Icons.location_off_outlined,
                                  message: 'No destinations available',
                                )
                              : ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: state.areas.length,
                                  itemBuilder: (context, index) {
                                    final area = state.areas[index];
                                    return GestureDetector(
                                      onTap: () => Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (_) => PropertiesScreen(
                                              areaId: area.areaId),
                                        ),
                                      ),
                                      child: PropertyModalWidget(area: area),
                                    );
                                  },
                                ),
                        ),
                        const SizedBox(height: 20),

                        // Recommended section
                        _SectionHeader(
                          title: context.translate('recommended_destination'),
                          onViewAll: () => Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (_) => PropertiesScreen()),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Property cards
                        if (state.properties.isEmpty)
                          const _EmptySection(
                            icon: Icons.home_work_outlined,
                            message: 'No recommended properties available',
                          )
                        else
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: state.properties.length,
                            itemBuilder: (context, index) {
                              final property = state.properties[index];
                              return GestureDetector(
                                onTap: () async {
                                  try {
                                    await SharedPrefService.setValue<String>(
                                        PrefKey.landLordId,
                                        property.landlordId);
                                    await SharedPrefService.setValue<String>(
                                        PrefKey.propertyID,
                                        property.propertyId);
                                    if (!context.mounted) return;
                                    Navigator.of(context)
                                        .push(MaterialPageRoute(
                                      builder: (_) => RoomScreen(
                                        propertyId:
                                            property.propertyId.toString(),
                                      ),
                                    ));
                                  } catch (e) {
                                    debugPrint('Navigation error: $e');
                                  }
                                },
                                child: ResortCard(property: property),
                              );
                            },
                          ),

                        // Extra bottom padding for floating nav bar
                        const SizedBox(height: 100),
                      ]),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _errorState(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onRetry,
  }) {
    final theme = Theme.of(context);
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: ThemeState.primaryGreen.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 40, color: ThemeState.primaryGreen),
              ),
              const SizedBox(height: 20),
              Text(title, style: theme.textTheme.titleLarge),
              const SizedBox(height: 8),
              Text(subtitle,
                  style: theme.textTheme.bodyMedium,
                  textAlign: TextAlign.center),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptySection extends StatelessWidget {
  final IconData icon;
  final String message;

  const _EmptySection({required this.icon, required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 36, color: Theme.of(context).colorScheme.outline),
          const SizedBox(height: 8),
          Text(message, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onViewAll;
  const _SectionHeader({required this.title, this.onViewAll});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: theme.textTheme.titleLarge),
        if (onViewAll != null)
          GestureDetector(
            onTap: onViewAll,
            child: Text(
              'View All',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: ThemeState.primaryGreen,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    );
  }
}
