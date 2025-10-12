import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart' show Lottie;
import 'package:omspos/constants/assets_list.dart' show AssetsList;
import 'package:omspos/screen/booking/model/booking_model.dart';
import 'package:omspos/screen/booking/state/booking_state.dart';
import 'package:omspos/screen/booking/ui/widget/booking_widget.dart';
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
            bottom: TabBar(
              controller: _tabController,
              tabs: _tabs.map((e) => Tab(text: e)).toList(),
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            children: _tabs.map((tab) {
              if (state.isLoading) {
                return Center(child: Lottie.asset(AssetsList.davsan));
              } else if (state.errorMessage != null) {
                return Center(child: Text(state.errorMessage!));
              } else if (state.bookings.isEmpty) {
                return const Center(child: Text("No bookings found"));
              } else {
                return _BookingListView(bookings: state.bookings);
              }
            }).toList(),
          ),
        );
      },
    );
  }
}

class _BookingListView extends StatelessWidget {
  final List<BookingModel> bookings;

  const _BookingListView({required this.bookings});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
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
