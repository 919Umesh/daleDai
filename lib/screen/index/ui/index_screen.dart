import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:omspos/screen/booking/ui/bookig_screen.dart';
import 'package:omspos/screen/home/ui/home_screen.dart';
import 'package:omspos/screen/index/state/index_state.dart';
import 'package:omspos/screen/map/screen/map_screen.dart';
import 'package:omspos/screen/profile/ui/profile_screen.dart';
import 'package:provider/provider.dart';

class IndexScreen extends StatelessWidget {
  const IndexScreen({super.key});

  static final List<Widget> _screens = [
    const HomeScreen(),
    const MapScreen(),
    const BookingListScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Consumer<IndexState>(
      builder: (context, state, child) {
        return Scaffold(
          body: AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            transitionBuilder: (child, animation) {
              return FadeTransition(
                opacity: animation,
                child: child,
              );
            },
            child: Container(
              key: ValueKey(state.currentIndex),
              child: _screens[state.currentIndex],
            ),
          ),
          bottomNavigationBar: _buildBottomNavigationBar(context, state),
        );
      },
    );
  }

  Widget _buildBottomNavigationBar(BuildContext context, IndexState state) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: BottomNavigationBar(
            currentIndex: state.currentIndex,
            onTap: (index) => state.updateIndex(index),
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.transparent,
            elevation: 0,
            selectedItemColor: Theme.of(context).primaryColor,
            unselectedItemColor: Colors.grey.shade600,
            selectedFontSize: 12,
            unselectedFontSize: 12,
            iconSize: 24,
            items: [
              BottomNavigationBarItem(
                icon: _buildNavIcon(context, Icons.home_outlined, Icons.home, 0,
                    state.currentIndex),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: _buildNavIcon(context, Icons.explore, Icons.list_alt, 1,
                    state.currentIndex),
                label: 'Explore',
              ),
              BottomNavigationBarItem(
                icon: _buildNavIcon(context, Icons.list_alt_outlined,
                    Icons.favorite, 2, state.currentIndex),
                label: 'Bookings',
              ),
              BottomNavigationBarItem(
                icon: _buildNavIcon(context, Icons.person_outline, Icons.person,
                    3, state.currentIndex),
                label: 'Profile',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavIcon(BuildContext context, IconData outlineIcon,
      IconData filledIcon, int index, int currentIndex) {
    final isSelected = index == currentIndex;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isSelected
            ? Theme.of(context).primaryColor.withOpacity(0.1)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        isSelected ? filledIcon : outlineIcon,
        size: 24,
      ),
    );
  }

  void _handleFabPress(BuildContext context, int currentIndex) {
    HapticFeedback.lightImpact();

    final List<String> messages = [
      'Home action',
      'New booking',
      'Add to wishlist',
      'Profile settings'
    ];

    final List<IconData> icons = [
      Icons.home,
      Icons.add,
      Icons.favorite,
      Icons.settings,
    ];

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icons[currentIndex],
              color: Colors.white,
              size: 18,
            ),
            const SizedBox(width: 8),
            Text(
              messages[currentIndex],
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
        backgroundColor: Theme.of(context).primaryColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        margin: const EdgeInsets.all(16),
        duration: const Duration(milliseconds: 1500),
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
            color: Colors.black87,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(2, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.favorite,
                size: 40,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Your Wishlist',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Save items you love for later',
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
