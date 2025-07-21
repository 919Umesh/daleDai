import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:omspos/screen/room/model/room_model.dart';

class BookingBottomSheet extends StatefulWidget {
  final RoomModel room;

  const BookingBottomSheet({super.key, required this.room});

  @override
  State<BookingBottomSheet> createState() => _BookingBottomSheetState();
}

class _BookingBottomSheetState extends State<BookingBottomSheet> {
  late final TextEditingController _rentController;
  late final TextEditingController _depositController;
  late final TextEditingController _bookingDateController;
  late final TextEditingController _moveInDateController;
  late final TextEditingController _moveOutDateController;

  DateTime? _bookingDate;
  DateTime? _moveInDate;
  DateTime? _moveOutDate;

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    final room = widget.room;
    _rentController =
        TextEditingController(text: room.rentAmount.toStringAsFixed(2));
    _depositController =
        TextEditingController(text: room.securityDeposit.toStringAsFixed(2));
    _bookingDateController = TextEditingController();
    _moveInDateController = TextEditingController();
    _moveOutDateController = TextEditingController();
  }

  @override
  void dispose() {
    _rentController.dispose();
    _depositController.dispose();
    _bookingDateController.dispose();
    _moveInDateController.dispose();
    _moveOutDateController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(
      BuildContext context,
      TextEditingController controller,
      DateTime? selected,
      ValueSetter<DateTime> onSelected) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selected ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration()),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            datePickerTheme: DatePickerThemeData(
              headerBackgroundColor: Colors.blue,
              rangeSelectionBackgroundColor: Colors.blue.withOpacity(0.2),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != selected) {
      controller.text = DateFormat('yyyy-MM-dd').format(picked);
      onSelected(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 20,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Align(
                alignment: Alignment.center,
                child: SizedBox(
                  width: 40,
                  height: 4,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Colors.grey,
                      borderRadius: BorderRadius.all(Radius.circular(2)),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Book This Room',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),

              // Booking Date
              TextFormField(
                controller: _bookingDateController,
                decoration: const InputDecoration(
                  labelText: 'Booking Date',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.calendar_today),
                ),
                readOnly: true,
                onTap: () => _selectDate(
                    context, _bookingDateController, _bookingDate, (date) {
                  setState(() => _bookingDate = date);
                }),
                validator: (value) {
                  if (value == null || value.isEmpty)
                    return 'Please select booking date';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Move In Date
              TextFormField(
                controller: _moveInDateController,
                decoration: const InputDecoration(
                  labelText: 'Move-In Date',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.calendar_today),
                ),
                readOnly: true,
                onTap: () => _selectDate(
                    context, _moveInDateController, _moveInDate, (date) {
                  setState(() => _moveInDate = date);
                }),
                validator: (value) {
                  if (value == null || value.isEmpty)
                    return 'Please select move-in date';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Move Out Date (Optional)
              TextFormField(
                controller: _moveOutDateController,
                decoration: const InputDecoration(
                  labelText: 'Move-Out Date (Optional)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.calendar_today),
                ),
                readOnly: true,
                onTap: () => _selectDate(
                    context, _moveOutDateController, _moveOutDate, (date) {
                  setState(() => _moveOutDate = date);
                }),
              ),
              const SizedBox(height: 16),

              // Monthly Rent
              TextFormField(
                controller: _rentController,
                decoration: const InputDecoration(
                  labelText: 'Monthly Rent',
                  border: OutlineInputBorder(),
                  prefixText: '\$ ',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty)
                    return 'Enter monthly rent';
                  if (double.tryParse(value) == null) return 'Invalid amount';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Security Deposit
              TextFormField(
                controller: _depositController,
                decoration: const InputDecoration(
                  labelText: 'Security Deposit',
                  border: OutlineInputBorder(),
                  prefixText: '\$ ',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty)
                    return 'Enter security deposit';
                  if (double.tryParse(value) == null) return 'Invalid amount';
                  return null;
                },
              ),

              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      // Perform booking logic here
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Room booked successfully!')),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Confirm Booking',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
