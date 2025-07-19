// index_screen.dart
import 'package:flutter/material.dart';
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
      body: Consumer<IndexState>(
        builder: (context, state, child) {
          return _screens[state.currentIndex];
        },
      ),
      floatingActionButton: Consumer<IndexState>(
        builder: (context, state, child) {
          return FloatingActionButton(
            onPressed: () => _handleFabPress(context, state.currentIndex),
            child: Icon(state.fabIcon),
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      bottomNavigationBar: Consumer<IndexState>(
        builder: (context, state, child) {
          return AnimatedBottomNavigationBar(
            icons: state.icons,
            activeIndex: state.currentIndex,
            gapLocation: GapLocation.end,
            notchSmoothness: NotchSmoothness.defaultEdge,
            onTap: (index) => state.updateIndex(index),
            activeColor: Theme.of(context).primaryColor,
            inactiveColor: Colors.grey,
            height: 60,
            iconSize: 30,
            elevation: 8,
            gapWidth: 60,
            leftCornerRadius: 20,
            rightCornerRadius: 20,
          );
        },
      ),
    );
  }

  // Handle FAB press based on current index
  void _handleFabPress(BuildContext context, int currentIndex) {
    // Add specific actions for each tab if needed
    switch (currentIndex) {
      case 0: // Home
        // Handle home FAB press
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Home FAB pressed')),
        );
        break;
      case 1: // Booking
        // Handle booking FAB press
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Booking FAB pressed')),
        );
        break;
      case 2: // Wishlist
        // Handle wishlist FAB press
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Wishlist FAB pressed')),
        );
        break;
      case 3: // Profile
        // Handle profile FAB press
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile FAB pressed')),
        );
        break;
    }
  }
}

// Placeholder screens (move these to separate files in production)
class BookingListScreen extends StatelessWidget {
  const BookingListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          'Booking List Screen',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}

class WishlistScreen extends StatelessWidget {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          'Wishlist Screen',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}