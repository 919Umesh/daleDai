import 'dart:ui';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:omspos/screen/booking/ui/bookig_screen.dart';
import 'package:omspos/screen/home/ui/home_screen.dart';
import 'package:omspos/screen/index/state/index_state.dart';
import 'package:omspos/screen/map/screen/map_screen.dart';
import 'package:omspos/screen/management/ui/owner_dashboard_screen.dart';
import 'package:omspos/screen/profile/ui/profile_screen.dart';
import 'package:omspos/services/language/translation_extension.dart';
import 'package:omspos/services/sharedPreference/preference_keys.dart';
import 'package:omspos/services/sharedPreference/sharedPref_service.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class IndexScreen extends StatefulWidget {
  const IndexScreen({super.key});

  @override
  State<IndexScreen> createState() => _IndexScreenState();
}

class _IndexScreenState extends State<IndexScreen> {
  static final List<Widget> _tenantScreens = [
    HomeScreen(),
    MapScreen(),
    BookingListScreen(),
    ProfileScreen(),
  ];

  static final List<Widget> _ownerScreens = [
    OwnerDashboardScreen(showSectionTabs: false),
    OwnerDashboardScreen(
      section: OwnerDashboardSection.properties,
      showSectionTabs: false,
    ),
    OwnerDashboardScreen(
      section: OwnerDashboardSection.rent,
      showSectionTabs: false,
    ),
    ProfileScreen(),
  ];

  static const _tenantItems = [
    _NavItem(EvaIcons.homeOutline, EvaIcons.home, 'home'),
    _NavItem(EvaIcons.searchOutline, EvaIcons.search, 'explore'),
    _NavItem(EvaIcons.calendarOutline, EvaIcons.calendar, 'bookings'),
    _NavItem(EvaIcons.personOutline, EvaIcons.person, 'profile'),
  ];

  static const _ownerItems = [
    _NavItem(Icons.dashboard_outlined, Icons.dashboard, 'dashboard'),
    _NavItem(Icons.apartment_outlined, Icons.apartment, 'properties'),
    _NavItem(Icons.receipt_long_outlined, Icons.receipt_long, 'rent'),
    _NavItem(EvaIcons.personOutline, EvaIcons.person, 'profile'),
  ];

  String? _role;

  @override
  void initState() {
    super.initState();
    _loadRole();
  }

  Future<void> _loadRole() async {
    String role = 'tenant';
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        final row = await Supabase.instance.client
            .from('users')
            .select('user_type')
            .eq('user_id', user.id)
            .maybeSingle();
        role = row?['user_type']?.toString() ??
            user.userMetadata?['user_type']?.toString() ??
            'tenant';
        await SharedPrefService.setValue<String>(PrefKey.accountRole, role);
      } else {
        role = await SharedPrefService.getValue<String>(
              PrefKey.accountRole,
              defaultValue: 'tenant',
            ) ??
            'tenant';
      }
    } catch (_) {
      role = await SharedPrefService.getValue<String>(
            PrefKey.accountRole,
            defaultValue: 'tenant',
          ) ??
          'tenant';
    }
    if (!mounted) return;
    Provider.of<IndexState>(context, listen: false).reset();
    setState(() => _role = role);
  }

  @override
  Widget build(BuildContext context) {
    if (_role == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final isOwner = _role == 'landlord' || _role == 'admin';
    final screens = isOwner ? _ownerScreens : _tenantScreens;
    final items = isOwner ? _ownerItems : _tenantItems;
    return Consumer<IndexState>(
      builder: (context, state, child) {
        return Scaffold(
          extendBody: true,
          body: Stack(
            children: [
              // IndexedStack keeps all screens alive → instant tab switching, no rebuild
              NotificationListener<UserScrollNotification>(
                onNotification: (notification) {
                  if (notification.direction == ScrollDirection.reverse) {
                    state.hideBottomBar();
                  } else if (notification.direction ==
                      ScrollDirection.forward) {
                    state.showBottomBar();
                  }
                  return false;
                },
                child: IndexedStack(
                  index: state.currentIndex,
                  children: screens,
                ),
              ),
              AnimatedPositioned(
                duration: const Duration(milliseconds: 350),
                curve: Curves.easeInOutCubic,
                bottom: state.isBottomBarVisible ? 12 : -100,
                left: 20,
                right: 20,
                child: _FloatingNavBar(state: state, items: items),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _FloatingNavBar extends StatelessWidget {
  final IndexState state;
  final List<_NavItem> items;
  const _FloatingNavBar({required this.state, required this.items});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ClipRRect(
      borderRadius: BorderRadius.circular(32),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          height: 68,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDark
                  ? [
                      Colors.black.withValues(alpha: 0.6),
                      Colors.black.withValues(alpha: 0.8)
                    ]
                  : [
                      Colors.white.withValues(alpha: 0.7),
                      Colors.white.withValues(alpha: 0.9)
                    ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(32),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : Colors.black.withValues(alpha: 0.06),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.25),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(items.length, (i) {
              return _NavItemWidget(
                item: items[i],
                index: i,
                currentIndex: state.currentIndex,
                isDark: isDark,
                onTap: () => state.updateIndex(i),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData outlineIcon;
  final IconData filledIcon;
  final String labelKey;
  const _NavItem(this.outlineIcon, this.filledIcon, this.labelKey);
}

class _NavItemWidget extends StatelessWidget {
  final _NavItem item;
  final int index;
  final int currentIndex;
  final bool isDark;
  final VoidCallback onTap;

  const _NavItemWidget({
    required this.item,
    required this.index,
    required this.currentIndex,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = index == currentIndex;
    final primaryColor = Theme.of(context).primaryColor;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? primaryColor.withValues(alpha: 0.18)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Icon(
                isSelected ? item.filledIcon : item.outlineIcon,
                key: ValueKey(isSelected),
                color: isSelected
                    ? primaryColor
                    : (isDark ? Colors.white54 : Colors.black45),
                size: 22,
              ),
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              child: isSelected
                  ? Padding(
                      padding: const EdgeInsets.only(left: 6),
                      child: Text(
                        context.translate(item.labelKey),
                        style: TextStyle(
                          color: primaryColor,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}
