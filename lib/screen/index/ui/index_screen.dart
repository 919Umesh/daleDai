import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:omspos/screen/home/ui/home_screen.dart';
import 'package:omspos/screen/index/state/index_state.dart';
import 'package:omspos/screen/profile/ui/profile_screen.dart';
import 'package:provider/provider.dart';
import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';

class IndexScreen extends StatelessWidget {
  const IndexScreen({super.key});

  static final List<Widget> _screens = [
    const HomeScreen(),
    const BookingListScreen(),
    const WishlistScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: Consumer<IndexState>(
        builder: (context, state, child) {
          return AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (child, animation) {
              return FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0.1, 0),
                    end: Offset.zero,
                  ).animate(CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOutCubic,
                  )),
                  child: child,
                ),
              );
            },
            child: Container(
              key: ValueKey(state.currentIndex),
              child: _screens[state.currentIndex],
            ),
          );
        },
      ),
      floatingActionButton: Consumer<IndexState>(
        builder: (context, state, child) {
          return Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Theme.of(context).primaryColor,
                  Theme.of(context).primaryColor.withOpacity(0.8),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).primaryColor.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                  spreadRadius: 2,
                ),
              ],
            ),
            child: FloatingActionButton(
              backgroundColor: Colors.transparent,
              elevation: 0,
              onPressed: () => _handleFabPress(context, state.currentIndex),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                transitionBuilder: (child, animation) {
                  return RotationTransition(
                    turns: animation,
                    child: child,
                  );
                },
                child: Icon(
                  state.fabIcon,
                  key: ValueKey(state.fabIcon),
                  color: Colors.white,
                  size: 28,
                ),
              ),
            ),
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startDocked,
      bottomNavigationBar: Consumer<IndexState>(
        builder: (context, state, child) {
          return Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, -5),
                  spreadRadius: 0,
                ),
              ],
            ),
            child: AnimatedBottomNavigationBar(
              icons: state.icons,
              activeIndex: state.currentIndex,
              gapLocation: GapLocation.end,
              notchSmoothness: NotchSmoothness.softEdge,
              onTap: (index) => state.updateIndex(index),
              activeColor: Theme.of(context).primaryColor,
              inactiveColor: Colors.grey.shade400,
              backgroundColor: Colors.white,
              splashColor: Theme.of(context).primaryColor.withOpacity(0.1),
              splashSpeedInMilliseconds: 300,
              height: 70,
              iconSize: 26,
              elevation: 0,
              gapWidth: 80,
              leftCornerRadius: 24,
              rightCornerRadius: 0,
              borderColor: Colors.grey.shade200,
              borderWidth: 0.5,
            ),
          );
        },
      ),
    );
  }

  void _handleFabPress(BuildContext context, int currentIndex) {
    // Add haptic feedback
    HapticFeedback.selectionClick();

    final List<String> messages = [
      'Home FAB pressed',
      'Booking FAB pressed',
      'Wishlist FAB pressed',
      'Profile FAB pressed'
    ];

    final List<IconData> icons = [
      Icons.home_rounded,
      Icons.list_alt_rounded,
      Icons.favorite_rounded,
      Icons.person_rounded,
    ];

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icons[currentIndex],
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 12),
            Text(
              messages[currentIndex],
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 15,
              ),
            ),
          ],
        ),
        backgroundColor: Theme.of(context).primaryColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 100),
        duration: const Duration(seconds: 2),
        elevation: 8,
      ),
    );
  }
}

class BookingListScreen extends StatelessWidget {
  const BookingListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          'Booking List',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                Icons.list_alt_rounded,
                size: 64,
                color: Theme.of(context).primaryColor,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Booking List Screen',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade800,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Your bookings will appear here',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class WishlistScreen extends StatelessWidget {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          'Wishlist',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                Icons.favorite_rounded,
                size: 64,
                color: Colors.red.shade400,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Wishlist Screen',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade800,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Your favorite items will appear here',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
