import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart' show Lottie;
import 'package:omspos/constants/assets_list.dart' show AssetsList;
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
            actions: [
              IconButton(
                  onPressed: () async {
                    await state.refreshBookings();
                  },
                  icon: Icon(Icons.refresh))
            ],
            bottom: TabBar(
              controller: _tabController,
              tabs: _tabs.map((e) => Tab(text: e)).toList(),
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            children: _tabs.map((tab) {
              return BookingTab(
                  status: tab, scrollController: _scrollController);
            }).toList(),
          ),
        );
      },
    );
  }
}

class BookingTab extends StatefulWidget {
  final String status;
  final ScrollController scrollController;

  const BookingTab(
      {super.key, required this.status, required this.scrollController});

  @override
  State<BookingTab> createState() => _BookingTabState();
}

class _BookingTabState extends State<BookingTab>
    with AutomaticKeepAliveClientMixin {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = Provider.of<BookingState>(context, listen: false);
      // trigger load if we don't have cached data for this status
      final key = widget.status.toLowerCase();
      if (state.getCachedBookings(key).isEmpty) {
        state.loadBookings(status: key);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final state = Provider.of<BookingState>(context);
    final key = widget.status.toLowerCase();
    final bookings = state.getCachedBookings(key);

    if (!state.hasInternet) {
      return Scaffold(
          appBar: AppBar(
            title: const Text('No Internet'),
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

    if (state.isLoading && bookings.isEmpty) {
      return Center(child: Lottie.asset(AssetsList.davsan));
    }

    if (state.errorMessage != null && bookings.isEmpty) {
      return Center(child: Text(state.errorMessage!));
    }

    if (bookings.isEmpty) return const Center(child: Text("No bookings found"));

    return RefreshIndicator(
      onRefresh: () async {
        await state.loadBookings(status: key, isRefresh: true);
      },
      child: ListView.builder(
        controller: widget.scrollController,
        padding: const EdgeInsets.all(12),
        itemCount: bookings.length,
        itemBuilder: (context, index) {
          final booking = bookings[index];
          return BookingWidget(
            booking: booking,
          );
        },
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
