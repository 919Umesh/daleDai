import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart' show Lottie;
import 'package:omspos/constants/assets_list.dart' show AssetsList;
import 'package:omspos/screen/booking/model/booking_model.dart';
import 'package:omspos/screen/booking/state/booking_state.dart';
import 'package:omspos/screen/booking/ui/widget/booking_widget.dart';
import 'package:omspos/screen/index/state/index_state.dart';
import 'package:provider/provider.dart';

class BookingListScreen extends StatefulWidget {
  const BookingListScreen({super.key});

  @override
  State<BookingListScreen> createState() => _BookingListScreenState();
}

class _BookingListScreenState extends State<BookingListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _tabs = ["Confirmed", "Pending", "Completed"];
  late ScrollController _scrollController;
  double _lastScrollOffset = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<BookingState>(context, listen: false).getContext = context;
    });

    _tabController.addListener(() {
      if (_tabController.indexIsChanging) return;
      final state = Provider.of<BookingState>(context, listen: false);
      state.loadBookings(status: _tabs[_tabController.index]);
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
    _tabController.dispose();
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<BookingState>(
      builder: (context, state, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Bookings'),
            bottom: TabBar(
              controller: _tabController,
              tabs: _tabs.map((e) => Tab(text: e)).toList(),
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            children: _tabs.map((tab) {
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
                        ],
                      ),
                    ));
              }
              if (state.isLoading) {
                return Center(child: Lottie.asset(AssetsList.davsan));
              }
              if (state.errorMessage != null) {
                return Center(child: Text(state.errorMessage!));
              }
              if (state.bookings.isEmpty) {
                return const Center(child: Text("No bookings found"));
              }
              return _BookingListView(
                  bookings: state.bookings,
                  scrollController: _scrollController);
            }).toList(),
          ),
        );
      },
    );
  }
}

class _BookingListView extends StatelessWidget {
  final List<BookingModel> bookings;
  final ScrollController scrollController;

  const _BookingListView({
    required this.bookings,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: scrollController,
      padding: const EdgeInsets.all(12),
      itemCount: bookings.length,
      itemBuilder: (context, index) {
        final booking = bookings[index];
        return BookingWidget(
          booking: booking,
        );
      },
    );
  }
}
