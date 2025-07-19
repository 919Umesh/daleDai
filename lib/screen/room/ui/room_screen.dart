import 'package:flutter/material.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:omspos/screen/room/model/room_model.dart';
import 'package:omspos/screen/room/state/room_state.dart';
import 'package:omspos/widgets/no_data_widget.dart';
import 'package:provider/provider.dart';
import 'package:omspos/utils/loading_indicator.dart';

class RoomScreen extends StatefulWidget {
  final String propertyId;

  const RoomScreen({super.key, required this.propertyId});

  @override
  State<RoomScreen> createState() => _RoomScreenState();
}

class _RoomScreenState extends State<RoomScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<RoomState>(context, listen: false)
          .loadRoomsByProperty(widget.propertyId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Room List'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () =>
                Provider.of<RoomState>(context, listen: false).refreshRooms(),
          ),
        ],
      ),
      body: Consumer<RoomState>(
        builder: (context, state, child) {
          if (state.isLoading && state.rooms.isEmpty) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          if (state.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error: ${state.errorMessage}'),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => state.refreshRooms(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state.rooms.isEmpty) {
            return const NoDataWidget();
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: state.rooms.length,
            itemBuilder: (context, index) {
              final room = state.rooms[index];
              return _RoomCard(room: room);
            },
          );
        },
      ),
    );
  }
}

class _RoomCard extends StatelessWidget {
  final RoomModel room;

  const _RoomCard({required this.room});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Room ${room.roomNumber}',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: room.isOccupied
                        ? Colors.red.withOpacity(0.1)
                        : Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: room.isOccupied ? Colors.red : Colors.green,
                      width: 1,
                    ),
                  ),
                  child: Text(
                    room.isOccupied ? 'Occupied' : 'Available',
                    style: TextStyle(
                      color: room.isOccupied ? Colors.red : Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Type: ${room.roomType.toUpperCase()}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _InfoChip(
                  icon: Icons.monetization_on,
                  label: 'Rent: NPR ${room.rentAmount.toStringAsFixed(0)}',
                ),
                _InfoChip(
                  icon: Icons.security,
                  label:
                      'Deposit: NPR ${room.securityDeposit.toStringAsFixed(0)}',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: Icon(
        icon,
        size: 18,
        color: Theme.of(context).primaryColor,
      ),
      label: Text(
        label,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
      ),
      backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}
