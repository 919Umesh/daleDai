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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<BookingState>(context, listen: false).getContext = context;
    });

    _tabController.addListener(() {
      if (_tabController.indexIsChanging) return;
      final state = Provider.of<BookingState>(context, listen: false);
      state.loadBookings(status: _tabs[_tabController.index]);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
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
              return BookingTab(status: tab);
            }).toList(),
          ),
        );
      },
    );
  }
}

class BookingTab extends StatefulWidget {
  final String status;

  const BookingTab({super.key, required this.status});

  @override
  State<BookingTab> createState() => _BookingTabState();
}

class _BookingTabState extends State<BookingTab>
    with AutomaticKeepAliveClientMixin {
  late final ScrollController _scrollController;
  double _lastScrollOffset = 0;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_scrollListener);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = Provider.of<BookingState>(context, listen: false);
      // trigger load if we don't have cached data for this status
      final key = widget.status.toLowerCase();
      if (state.getCachedBookings(key).isEmpty) {
        state.loadBookings(status: key);
      }
    });
  }

  void _scrollListener() {
    final offset = _scrollController.offset;
    final indexState = context.read<IndexState>();
    if (offset > _lastScrollOffset && offset > 100) {
      indexState.hideBottomBar();
    } else if (offset < _lastScrollOffset) {
      indexState.showBottomBar();
    }
    _lastScrollOffset = offset;
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_scrollListener)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final state = Provider.of<BookingState>(context);
    final key = widget.status.toLowerCase();
    final bookings = state.getCachedBookings(key);

    if (!state.hasInternet) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(AssetsList.noInternet, fit: BoxFit.contain),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => state.loadBookings(status: key),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (state.isLoading && bookings.isEmpty) {
      return Center(child: Lottie.asset(AssetsList.davsan));
    }

    if (state.errorMessage != null && bookings.isEmpty) {
      return Center(child: Text(state.errorMessage!));
    }

    if (bookings.isEmpty) {
      return RefreshIndicator(
        onRefresh: () => state.loadBookings(status: key, isRefresh: true),
        child: ListView(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          children: const [
            SizedBox(height: 180),
            Icon(Icons.event_busy_outlined, size: 48),
            SizedBox(height: 12),
            Center(child: Text('No bookings found')),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        await state.loadBookings(status: key, isRefresh: true);
      },
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 96),
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
