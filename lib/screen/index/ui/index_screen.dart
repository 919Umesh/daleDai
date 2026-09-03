import 'dart:ui';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:omspos/screen/booking/ui/bookig_screen.dart';
import 'package:omspos/screen/home/ui/home_screen.dart';
import 'package:omspos/screen/index/state/index_state.dart';
import 'package:omspos/screen/map/screen/map_screen.dart';
import 'package:omspos/screen/profile/ui/profile_screen.dart';
import 'package:omspos/services/language/translation_extension.dart';
import 'package:omspos/themes/theme_state.dart';
import 'package:provider/provider.dart';

class IndexScreen extends StatelessWidget {
  const IndexScreen({super.key});

  static final List<Widget> _screens = [
    HomeScreen(),
    MapScreen(),
    BookingListScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Consumer<IndexState>(
      builder: (context, state, child) {
        return Scaffold(
          extendBody: true,
          body: Stack(
            children: [
              // IndexedStack keeps all screens alive → instant tab switching, no rebuild
              IndexedStack(
                index: state.currentIndex,
                children: _screens,
              ),
              AnimatedPositioned(
                duration: const Duration(milliseconds: 350),
                curve: Curves.easeInOutCubic,
                bottom: state.isBottomBarVisible ? 12 : -100,
                left: 20,
                right: 20,
                child: _FloatingNavBar(state: state),
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
  const _FloatingNavBar({required this.state});

  static const _items = [
    _NavItem(EvaIcons.homeOutline, EvaIcons.home, 'home'),
    _NavItem(EvaIcons.searchOutline, EvaIcons.search, 'explore'),
    _NavItem(EvaIcons.calendarOutline, EvaIcons.calendar, 'bookings'),
    _NavItem(EvaIcons.personOutline, EvaIcons.person, 'profile'),
  ];

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
                  ? [Colors.black.withOpacity(0.6), Colors.black.withOpacity(0.8)]
                  : [Colors.white.withOpacity(0.7), Colors.white.withOpacity(0.9)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(32),
            border: Border.all(
              color: isDark
                  ? Colors.white.withOpacity(0.08)
                  : Colors.black.withOpacity(0.06),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.25),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(_items.length, (i) {
              return _NavItemWidget(
                item: _items[i],
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? primaryColor.withOpacity(0.18)
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
