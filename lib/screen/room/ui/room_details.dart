import 'package:flutter/material.dart';
import 'package:omspos/screen/room/model/room_model.dart';
import 'package:omspos/screen/room/state/room_state.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

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

  void _showBookingBottomSheet(BuildContext context, RoomModel room) {
    final formKey = GlobalKey<FormState>();
    DateTime? bookingDate;
    DateTime? moveInDate;
    DateTime? moveOutDate;
    double? monthlyRent = room.rentAmount;
    double? securityDeposit = room.securityDeposit;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 16,
          ),
          child: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Book This Room',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildDateField(
                    context,
                    'Booking Date',
                    (date) => bookingDate = date,
                    isRequired: true,
                  ),
                  const SizedBox(height: 16),
                  _buildDateField(
                    context,
                    'Move In Date',
                    (date) => moveInDate = date,
                    isRequired: true,
                  ),
                  const SizedBox(height: 16),
                  _buildDateField(
                    context,
                    'Move Out Date',
                    (date) => moveOutDate = date,
                    isRequired: false,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    initialValue: monthlyRent?.toStringAsFixed(2),
                    decoration: const InputDecoration(
                      labelText: 'Monthly Rent',
                      border: OutlineInputBorder(),
                      prefixText: '\$ ',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter monthly rent';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Please enter a valid amount';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      monthlyRent = double.tryParse(value ?? '0');
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    initialValue: securityDeposit?.toStringAsFixed(2),
                    decoration: const InputDecoration(
                      labelText: 'Security Deposit',
                      border: OutlineInputBorder(),
                      prefixText: '\$ ',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter security deposit';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Please enter a valid amount';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      securityDeposit = double.tryParse(value ?? '0');
                    },
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        if (formKey.currentState!.validate()) {
                          formKey.currentState!.save();
                          // Here you would typically call an API to save the booking
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Room booked successfully!'),
                            ),
                          );
                        }
                      },
                      child: const Text('Confirm Booking'),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDateField(
    BuildContext context,
    String label,
    Function(DateTime) onDateSelected, {
    required bool isRequired,
  }) {
    DateTime? selectedDate;
    final controller = TextEditingController();

    return GestureDetector(
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime.now(),
          lastDate: DateTime(DateTime.now().year + 2),
        );
        if (date != null) {
          selectedDate = date;
          controller.text = DateFormat('yyyy-MM-dd').format(date);
          onDateSelected(date);
        }
      },
      child: AbsorbPointer(
        child: TextFormField(
          controller: controller,
          decoration: InputDecoration(
            labelText: label,
            border: const OutlineInputBorder(),
            suffixIcon: const Icon(Icons.calendar_today),
          ),
          validator: isRequired
              ? (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select $label';
                  }
                  return null;
                }
              : null,
        ),
      ),
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
            Text(
              'Error loading room details',
              style: Theme.of(context).textTheme.titleMedium,
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
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
              onPressed: () => state.getRoomDetails(widget.roomID),
            ),
          ],
        ),
      );
    }

    if (room == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.meeting_room_outlined,
                size: 48, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              'No room data available',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Header Card
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child:
                            const Icon(Icons.meeting_room, color: Colors.blue),
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
                                  color: Colors.grey[600],
                                ),
                              ),
                            ]),
                      ),
                      GestureDetector(
                        onTap: () {
                          if (!room.isOccupied) {
                            _showBookingBottomSheet(context, room);
                          }
                        },
                        child: Chip(
                          label: Text(
                            room.isOccupied ? 'Occupied' : 'Available',
                            style: const TextStyle(color: Colors.white),
                          ),
                          backgroundColor:
                              room.isOccupied ? Colors.orange : Colors.green,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(height: 1),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatItem(
                        'Rent',
                        '\$${room.rentAmount.toStringAsFixed(2)}',
                        Icons.attach_money,
                      ),
                      _buildStatItem(
                        'Deposit',
                        '\$${room.securityDeposit.toStringAsFixed(2)}',
                        Icons.security,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Details Section
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Room Information',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildDetailItem(
                    context,
                    'Room ID',
                    room.roomNumber,
                    Icons.code,
                  ),
                  _buildDetailItem(
                    context,
                    'Property ID',
                    room.roomNumber,
                    Icons.apartment,
                  ),
                  _buildDetailItem(
                    context,
                    'Created',
                    DateFormat('MMM dd, yyyy').format(room.createdAt),
                    Icons.calendar_today,
                  ),
                  _buildDetailItem(
                    context,
                    'Last Updated',
                    DateFormat('MMM dd, yyyy').format(room.updatedAt),
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

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 28, color: Colors.blue),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildDetailItem(
      BuildContext context, String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Icon(icon, size: 24, color: Colors.grey),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
