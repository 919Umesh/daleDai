import 'package:flutter/material.dart';
import 'package:omspos/screen/room/model/room_model.dart';
import 'package:omspos/screen/room/state/room_state.dart';
import 'package:omspos/screen/room/ui/booking_bottom_sheet.dart';
import 'package:provider/provider.dart';

class RoomDetailScreen extends StatefulWidget {
  final String roomID;

  const RoomDetailScreen({super.key, required this.roomID});

  @override
  State<RoomDetailScreen> createState() => _RoomDetailScreenState();
}

class _RoomDetailScreenState extends State<RoomDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RoomState>().getRoomDetails(widget.roomID);
    });
  }

  void _openBookingSheet(RoomModel room) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => BookingBottomSheet(room: room),
    );
  }

  @override
  Widget build(BuildContext context) {
    final roomState = context.watch<RoomState>();
    final room = roomState.selectedRoom;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Room Details'),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => roomState.getRoomDetails(widget.roomID),
          ),
        ],
      ),
      body: _buildBody(roomState, room),
    );
  }

  Widget _buildBody(RoomState state, RoomModel? room) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state.errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            const Text(
              'Error Loading Room',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                state.errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => state.getRoomDetails(widget.roomID),
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Retry'),
            ),
          ],
        ),
      );
    }
    if (room == null) {
      return const Center(child: Text('No room data available'));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Header Card
          Card(
            elevation: 3,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.meeting_room,
                            color: Colors.blue, size: 32),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Room ${room.roomNumber}',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              room.roomType,
                              style: TextStyle(
                                  color: Colors.grey[600], fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: !room.isOccupied
                            ? () => _openBookingSheet(room)
                            : null,
                        child: Chip(
                          label: Text(
                            room.isOccupied ? 'Occupied' : 'Available',
                            style: const TextStyle(
                                color: Colors.white, fontSize: 13),
                          ),
                          backgroundColor:
                              room.isOccupied ? Colors.orange : Colors.green,
                          visualDensity: VisualDensity.compact,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Divider(height: 1),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildStatItem(
                          'Rent',
                          '\$${room.rentAmount.toStringAsFixed(2)}',
                          Icons.attach_money),
                      _buildStatItem(
                          'Deposit',
                          '\$${room.securityDeposit.toStringAsFixed(2)}',
                          Icons.security),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Details Section
          Card(
            elevation: 3,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Room Information',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  _buildDetailItem(
                      context, 'Room ID', room.roomNumber, Icons.qr_code),
                  _buildDetailItem(context, 'Property ID',
                      room.propertyId ?? 'N/A', Icons.apartment),
                  _buildDetailItem(
                    context,
                    'Created',
                    _formatDate(room.createdAt),
                    Icons.calendar_today,
                  ),
                  _buildDetailItem(
                    context,
                    'Updated',
                    _formatDate(room.updatedAt),
                    Icons.update,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 26, color: Colors.blue),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _buildDetailItem(
      BuildContext context, String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 13, color: Colors.grey[600]),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style:
                    const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
