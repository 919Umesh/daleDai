import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:omspos/screen/booking/ui/bookig_screen.dart';
import 'package:omspos/screen/home/ui/home_screen.dart';
import 'package:omspos/screen/index/state/index_state.dart';
import 'package:omspos/screen/map/screen/map_screen.dart';
import 'package:omspos/screen/profile/ui/profile_screen.dart';
import 'package:omspos/services/language/translation_extension.dart';
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
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                transitionBuilder: (child, animation) {
                  return FadeTransition(opacity: animation, child: child);
                },
                child: Container(
                  key: ValueKey(state.currentIndex),
                  child: _screens[state.currentIndex],
                ),
              ),
              AnimatedPositioned(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                bottom: state.isBottomBarVisible ? 0 : -100,
                left: 0,
                right: 0,
                child: _buildBottomNavigationBar(context, state),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBottomNavigationBar(BuildContext context, IndexState state) {
    return Container(
      margin: const EdgeInsets.all(16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(36),
        child: BottomNavigationBar(
          currentIndex: state.currentIndex,
          onTap: (index) => state.updateIndex(index),
          type: BottomNavigationBarType.fixed,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          elevation: 5,
          selectedItemColor: Theme.of(context).primaryColor,
          unselectedItemColor: Colors.white,
          showSelectedLabels: true,
          showUnselectedLabels: true,
          iconSize: 24,
          items: [
            BottomNavigationBarItem(
              icon: Center(
                child: _buildNavIcon(context, EvaIcons.homeOutline,
                    EvaIcons.home, 0, state.currentIndex),
              ),
              label: context.translate('home'),
            ),
            BottomNavigationBarItem(
              icon: Center(
                child: _buildNavIcon(context, EvaIcons.searchOutline,
                    EvaIcons.search, 1, state.currentIndex),
              ),
              label: context.translate('explore'),
            ),
            BottomNavigationBarItem(
              icon: Center(
                child: _buildNavIcon(context, EvaIcons.calendarOutline,
                    EvaIcons.calendar, 2, state.currentIndex),
              ),
              label: context.translate('bookings'),
            ),
            BottomNavigationBarItem(
              icon: Center(
                child: _buildNavIcon(context, EvaIcons.personOutline,
                    EvaIcons.person, 3, state.currentIndex),
              ),
              label: context.translate('profile'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavIcon(BuildContext context, IconData outlineIcon,
      IconData filledIcon, int index, int currentIndex) {
    final isSelected = index == currentIndex;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isSelected
            ? Colors.green.withOpacity(0.2)
            : Theme.of(context).cardColor,
      ),
      child: Icon(isSelected ? filledIcon : outlineIcon),
    );
  }
}
