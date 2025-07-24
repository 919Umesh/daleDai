import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:omspos/screen/home/state/home_state.dart';
import 'package:omspos/screen/properties/ui/properties_screen.dart';
import 'package:omspos/screen/room/ui/room_screen.dart';
import 'package:omspos/services/sharedPreference/preference_keys.dart';
import 'package:omspos/services/sharedPreference/sharedPref_service.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<String> carouselImages = [
    'https://xuodtwztsrbqtfiisxrq.supabase.co/storage/v1/object/public/area//basantpur.PNG',
    'https://xuodtwztsrbqtfiisxrq.supabase.co/storage/v1/object/public/area//patan.PNG',
    'https://xuodtwztsrbqtfiisxrq.supabase.co/storage/v1/object/public/area//swaymbu.PNG',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<HomeState>(context, listen: false).getContext = context;
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeState>(builder: (context, state, child) {
      return Stack(
        children: [
          Scaffold(
            body: CustomScrollView(
              controller: _scrollController,
              slivers: [
                // Enhanced Foldable App Bar
                SliverAppBar(
                  expandedHeight: 220.0,
                  floating: false,
                  pinned: true,
                  elevation: 0,
                  backgroundColor: Theme.of(context).primaryColor,
                  flexibleSpace: FlexibleSpaceBar(
                    title: const Text(
                      'Properties Hub',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    background: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Theme.of(context).primaryColor,
                            Theme.of(context).primaryColor.withOpacity(0.7),
                            Theme.of(context).primaryColor?.withOpacity(0.8) ??
                                Theme.of(context).primaryColor.withOpacity(0.8),
                          ],
                        ),
                      ),
                      child: Stack(
                        children: [
                          Positioned(
                            top: 80,
                            right: -20,
                            child: Icon(
                              Icons.business,
                              size: 120,
                              color: Colors.white.withOpacity(0.1),
                            ),
                          ),
                          const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.location_city,
                                  size: 60,
                                  color: Colors.white70,
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Find Your Perfect Property',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Enhanced Search Bar
                SliverToBoxAdapter(
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            spreadRadius: 0,
                            blurRadius: 20,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Search properties, areas...',
                          hintStyle: TextStyle(color: Colors.grey[500]),
                          prefixIcon: Container(
                            padding: const EdgeInsets.all(12),
                            child: Icon(Icons.search,
                                color: Colors.grey[600], size: 24),
                          ),
                          suffixIcon: Container(
                            margin: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .primaryColor
                                  .withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.tune,
                              color: Theme.of(context).primaryColor,
                              size: 20,
                            ),
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 18,
                          ),
                        ),
                        onChanged: (value) {
                          // Implement search functionality
                        },
                      ),
                    ),
                  ),
                ),

                // Areas Section Header with enhanced styling
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 25, 16, 15),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Browse Areas',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${state.areas.length} locations available',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                                color: Theme.of(context).primaryColor),
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child: TextButton(
                            onPressed: () {
                              // Navigate to see all areas
                            },
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 8),
                            ),
                            child: Text(
                              'View All',
                              style: TextStyle(
                                color: Theme.of(context).primaryColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Enhanced Horizontal Areas List
                SliverToBoxAdapter(
                  child: Container(
                    height: 140,
                    margin: const EdgeInsets.only(bottom: 10),
                    child: state.areas.isNotEmpty
                        ? ListView.builder(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: state.areas.length,
                            itemBuilder: (context, index) {
                              final area = state.areas[index];
                              return InkWell(
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                        builder: (context) => PropertiesScreen(
                                              areaId: area.areaId,
                                            )),
                                  );
                                },
                                child: Container(
                                  width: 110,
                                  margin: const EdgeInsets.only(right: 16),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
                                    color: Colors.white,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.08),
                                        spreadRadius: 0,
                                        blurRadius: 10,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Container(
                                          width: 70,
                                          height: 70,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            gradient: LinearGradient(
                                              colors: [
                                                Theme.of(context)
                                                    .primaryColor
                                                    .withOpacity(0.1),
                                                Theme.of(context)
                                                    .primaryColor
                                                    .withOpacity(0.05),
                                              ],
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Theme.of(context)
                                                    .primaryColor
                                                    .withOpacity(0.2),
                                                spreadRadius: 0,
                                                blurRadius: 8,
                                                offset: const Offset(0, 2),
                                              ),
                                            ],
                                          ),
                                          child: CircleAvatar(
                                            radius: 35,
                                            backgroundColor: Colors.transparent,
                                            backgroundImage: area.areaImage !=
                                                    null
                                                ? NetworkImage(area.areaImage!)
                                                : null,
                                            child: area.areaImage == null
                                                ? Icon(
                                                    Icons.location_on,
                                                    size: 32,
                                                    color: Theme.of(context)
                                                        .primaryColor,
                                                  )
                                                : null,
                                          ),
                                        ),
                                        const SizedBox(height: 12),
                                        Text(
                                          area.name,
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.black87,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          )
                        : _buildEmptyState(
                            'No areas available', Icons.location_off),
                  ),
                ),

                // Properties Section Header
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 30, 16, 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Featured Properties',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${state.properties.length} properties available',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                                color: Theme.of(context).primaryColor),
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child: TextButton(
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                    builder: (context) => PropertiesScreen()),
                              );
                            },
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 8),
                            ),
                            child: Text(
                              'View All',
                              style: TextStyle(
                                color: Theme.of(context).primaryColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Enhanced Properties List
                state.properties.isNotEmpty
                    ? SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final property = state.properties[index];
                            return Container(
                              margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.08),
                                    spreadRadius: 0,
                                    blurRadius: 15,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Property Image Placeholder
                                  Container(
                                    height: 200,
                                    decoration: BoxDecoration(
                                      borderRadius: const BorderRadius.vertical(
                                        top: Radius.circular(20),
                                      ),
                                      gradient: LinearGradient(
                                        colors: [
                                          Theme.of(context)
                                              .primaryColor
                                              .withOpacity(0.1),
                                          Theme.of(context)
                                              .primaryColor
                                              .withOpacity(0.05),
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                    ),
                                    child: Stack(
                                      children: [
                                        Center(
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                _getPropertyIcon(
                                                    property.propertyType),
                                                size: 50,
                                                color: Theme.of(context)
                                                    .primaryColor
                                                    .withOpacity(0.6),
                                              ),
                                              const SizedBox(height: 8),
                                              Text(
                                                property.propertyType
                                                    .toUpperCase(),
                                                style: TextStyle(
                                                  color: Theme.of(context)
                                                      .primaryColor,
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Positioned(
                                          top: 15,
                                          right: 15,
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 6,
                                            ),
                                            decoration: BoxDecoration(
                                              color: property.isActive
                                                  ? Colors.green
                                                  : Colors.orange,
                                              borderRadius:
                                                  BorderRadius.circular(15),
                                            ),
                                            child: Text(
                                              property.isActive
                                                  ? 'Available'
                                                  : 'Inactive',
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  // Property Details
                                  Padding(
                                    padding: const EdgeInsets.all(20),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          property.title,
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black87,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 8),

                                        Row(
                                          children: [
                                            Icon(
                                              Icons.location_on,
                                              size: 16,
                                              color: Colors.grey[600],
                                            ),
                                            const SizedBox(width: 4),
                                            Expanded(
                                              child: Text(
                                                '${property.address}, ${property.city}',
                                                style: TextStyle(
                                                  color: Colors.grey[600],
                                                  fontSize: 14,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),

                                        const SizedBox(height: 12),

                                        Text(
                                          property.description,
                                          style: TextStyle(
                                            color: Colors.grey[700],
                                            fontSize: 14,
                                            height: 1.4,
                                          ),
                                          maxLines: 3,
                                          overflow: TextOverflow.ellipsis,
                                        ),

                                        const SizedBox(height: 16),

                                        // Property Features Row
                                        Row(
                                          children: [
                                            _buildFeatureChip(
                                              Icons.square_foot,
                                              '${property.areaSqft} sq ft',
                                            ),
                                            const SizedBox(width: 8),
                                            _buildFeatureChip(
                                              Icons.table_bar_rounded,
                                              property.furnishingStatus,
                                            ),
                                          ],
                                        ),

                                        const SizedBox(height: 16),

                                        // Action Row
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            if (property.availableFrom != null)
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    'Available from',
                                                    style: TextStyle(
                                                      color: Colors.grey[600],
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                  Text(
                                                    _formatDate(property
                                                        .availableFrom!),
                                                    style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                ],
                                              )
                                            else
                                              const SizedBox(),
                                            ElevatedButton(
                                              onPressed: () async {
                                                await SharedPrefService
                                                    .setValue<String>(
                                                        PrefKey.landLordId,
                                                        property.landlordId);
                                                Navigator.of(context).push(
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          RoomScreen(
                                                            propertyId: property
                                                                .propertyId,
                                                          )),
                                                );
                                              },
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    Theme.of(context)
                                                        .primaryColor,
                                                foregroundColor: Colors.white,
                                                elevation: 0,
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                  horizontal: 24,
                                                  vertical: 12,
                                                ),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(25),
                                                ),
                                              ),
                                              child: const Text(
                                                'View Details',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                          childCount: state.properties.length,
                        ),
                      )
                    : SliverToBoxAdapter(
                        child: Container(
                          margin: const EdgeInsets.all(16),
                          child: _buildEmptyState(
                            'No properties available',
                            Icons.business_outlined,
                          ),
                        ),
                      ),

                // Bottom padding for navigation bar
                const SliverToBoxAdapter(
                  child: SizedBox(height: 100),
                ),
              ],
            ),
          ),

          // Enhanced Loading indicator
          if (state.isLoading)
            Container(
              color: Colors.black12,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        spreadRadius: 0,
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(
                        color: Theme.of(context).primaryColor,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Loading properties...',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      );
    });
  }

  // Helper method to build feature chips
  Widget _buildFeatureChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: Theme.of(context).primaryColor,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: Theme.of(context).primaryColor,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // Helper method to get property type icon
  IconData _getPropertyIcon(String propertyType) {
    switch (propertyType.toLowerCase()) {
      case 'commercial':
        return Icons.business;
      case 'residential':
        return Icons.home;
      case 'office':
        return Icons.home;
      case 'retail':
        return Icons.store;
      default:
        return Icons.apartment;
    }
  }

  // Helper method to format date
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  // Helper method to build empty state
  Widget _buildEmptyState(String message, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          Icon(
            icon,
            size: 60,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
