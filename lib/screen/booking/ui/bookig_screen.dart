import 'package:flutter/material.dart';
import 'package:omspos/screen/booking/model/booking_model.dart';
import 'package:omspos/screen/booking/state/booking_state.dart';
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
      final state = Provider.of<BookingState>(context, listen: false);
      state.getContext = context;
      state.loadBookings(status: _tabs[_tabController.index]);
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
          backgroundColor: Colors.grey[50],
          appBar: AppBar(
            title: const Text('Bookings'),
            bottom: TabBar(
              controller: _tabController,
              tabs: _tabs.map((e) => Tab(text: e)).toList(),
              indicatorColor: Colors.blueAccent,
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            children: _tabs.map((tab) {
              return RefreshIndicator(
                onRefresh: () async {
                  await Provider.of<BookingState>(context, listen: false)
                      .loadBookings(status: tab, isRefresh: true);
                },
                child: state.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : state.errorMessage != null
                        ? Center(child: Text(state.errorMessage!))
                        : state.bookings.isEmpty
                            ? const Center(child: Text("No bookings found"))
                            : _BookingListView(bookings: state.bookings),
              );
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
        return Card(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 2,
          child: ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            title: Text(
              booking.roomNumber ?? "Room",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              "Status: ${booking.status}\nDate: ${booking.bookingDate}",
              style: const TextStyle(color: Colors.black54),
            ),
            trailing: IconButton(
              icon: const Icon(Icons.picture_as_pdf, color: Colors.redAccent),
              onPressed: () {
                Provider.of<BookingState>(context, listen: false)
                    .generatePdf(booking);
              },
            ),
          ),
        );
      },
    );
  }
}
