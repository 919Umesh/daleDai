import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:intl/intl.dart';
import 'package:omspos/screen/room/model/room_model_images.dart';
import 'package:omspos/screen/room/state/room_state.dart';
import 'package:provider/provider.dart';

class BookingBottomSheet extends StatefulWidget {
  final RoomModelImage room;
  const BookingBottomSheet({super.key, required this.room});

  @override
  State<BookingBottomSheet> createState() => _BookingBottomSheetState();
}

class _BookingBottomSheetState extends State<BookingBottomSheet> {
  final _formKey = GlobalKey<FormBuilderState>();
  late final double initialRent;
  late final double initialDeposit;

  @override
  void initState() {
    super.initState();
    initialRent = widget.room.rentAmount;
    initialDeposit = widget.room.securityDeposit;
  }

  Future<void> processPaymentAndBooking() async {
    final state = Provider.of<RoomState>(context, listen: false);
    await state.processPaymentAndBooking(widget.room, _formKey);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: FormBuilder(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),

                const Center(
                  child: Text(
                    'Book Room',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                _buildFormField(
                  FormBuilderDateTimePicker(
                    name: 'booking_date',
                    initialValue: null,
                    inputType: InputType.date,
                    format: DateFormat('MMM dd, yyyy'),
                    decoration: _getInputDecoration('Booking Date'),
                    validator: FormBuilderValidators.required(
                      errorText: 'Please select booking date',
                    ),
                  ),
                ),
                _buildFormField(
                  FormBuilderDateTimePicker(
                    name: 'move_in_date',
                    initialValue: null,
                    inputType: InputType.date,
                    format: DateFormat('MMM dd, yyyy'),
                    decoration: _getInputDecoration('Move-In Date'),
                    validator: FormBuilderValidators.required(
                      errorText: 'Please select move-in date',
                    ),
                  ),
                ),
                _buildFormField(
                  FormBuilderDateTimePicker(
                    name: 'move_out_date',
                    initialValue: null,
                    inputType: InputType.date,
                    format: DateFormat('MMM dd, yyyy'),
                    decoration: _getInputDecoration('Move-Out Date (Optional)'),
                  ),
                ),

                _buildFormField(
                  FormBuilderTextField(
                    name: 'monthly_rent',
                    initialValue: initialRent.toStringAsFixed(2),
                    decoration: _getInputDecoration('Monthly Rent (\$)'),
                    keyboardType: TextInputType.number,
                    validator: FormBuilderValidators.compose([
                      FormBuilderValidators.required(
                          errorText: 'Enter monthly rent'),
                      FormBuilderValidators.numeric(
                          errorText: 'Must be a valid number'),
                    ]),
                  ),
                ),
                _buildFormField(
                  FormBuilderTextField(
                    name: 'security_deposit',
                    initialValue: initialDeposit.toStringAsFixed(2),
                    decoration: _getInputDecoration('Security Deposit (\$)'),
                    keyboardType: TextInputType.number,
                    validator: FormBuilderValidators.compose([
                      FormBuilderValidators.required(
                          errorText: 'Enter security deposit'),
                      FormBuilderValidators.numeric(
                          errorText: 'Must be a valid number'),
                    ]),
                  ),
                ),
                _buildFormField(
                  FormBuilderTextField(
                    name: 'profession',
                    decoration: _getInputDecoration('Profession'),
                    validator: FormBuilderValidators.required(
                      errorText: 'Please enter your profession',
                    ),
                  ),
                ),
                _buildFormField(
                  FormBuilderSlider(
                    name: 'peoples',
                    min: 1,
                    max: 10,
                    initialValue: 1,
                    divisions: 9,
                    decoration: const InputDecoration(
                      labelText: 'Number of People',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                    displayValues: DisplayValues.current,
                    validator: FormBuilderValidators.required(
                      errorText: 'Please select number of people',
                    ),
                  ),
                ),
                FormBuilderRadioGroup(
                  name: 'payment_method',
                  initialValue: 'cash',
                  decoration: InputDecoration(
                    labelText: 'Select Payment Method',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  options: [
                    FormBuilderFieldOption(
                      value: 'cash',
                      child: const Text('Cash'),
                    ),
                    FormBuilderFieldOption(
                      value: 'esewa',
                      child: const Text('eSewa'),
                    ),
                  ],
                  validator: FormBuilderValidators.required(
                    errorText: 'Please select payment method',
                  ),
                ),

                const SizedBox(height: 12),

                // Confirm Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: processPaymentAndBooking,
                    style: ElevatedButton.styleFrom(
                      elevation: 10,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Confirm Booking',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFormField(Widget child) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: child,
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  InputDecoration _getInputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }
}
