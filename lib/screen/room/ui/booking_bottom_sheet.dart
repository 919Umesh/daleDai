import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:intl/intl.dart';
import 'package:omspos/screen/room/model/room_model.dart';
import 'package:omspos/screen/room/state/room_state.dart';
import 'package:omspos/services/esewa/esewa_service.dart';
import 'package:omspos/services/sharedPreference/preference_keys.dart';
import 'package:omspos/services/sharedPreference/sharedPref_service.dart';
import 'package:omspos/utils/custom_log.dart';
import 'package:provider/provider.dart';

class BookingBottomSheet extends StatefulWidget {
  final RoomModel room;

  const BookingBottomSheet({super.key, required this.room});

  @override
  State<BookingBottomSheet> createState() => _BookingBottomSheetState();
}

class _BookingBottomSheetState extends State<BookingBottomSheet> {
  final _formKey = GlobalKey<FormBuilderState>();
  late final double initialRent;
  late final double initialDeposit;
  bool _isProcessingPayment = false;

  @override
  void initState() {
    super.initState();
    initialRent = widget.room.rentAmount;
    initialDeposit = widget.room.securityDeposit;
  }

  Future<void> _handleBooking(Map<String, dynamic> formData) async {
    try {
      await context.read<RoomState>().createBooking(formData);
      Navigator.pop(context);
      Fluttertoast.showToast(
        msg: 'Booking successful!',
        toastLength: Toast.LENGTH_LONG,
      );
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'Booking failed: ${e.toString()}',
        toastLength: Toast.LENGTH_LONG,
        backgroundColor: Colors.red,
      );
      CustomLog.errorLog(value: 'Booking Error: ${e.toString()}');
    }
  }

  Future<void> _processPaymentAndBooking() async {
    if (!_formKey.currentState!.saveAndValidate()) return;

    setState(() => _isProcessingPayment = true);

    try {
      final userId = await SharedPrefService.getValue<String>(
        PrefKey.userId,
        defaultValue: "-",
      );
      final landlordId = await SharedPrefService.getValue<String>(
        PrefKey.landLordId,
        defaultValue: "-",
      );

      final formValues = _formKey.currentState!.value;
      final paymentMethod =
          formValues['paymentMethods'] as String? ?? 'payLater';

      // Format dates
      final formatDate =
          (DateTime date) => date.toIso8601String().split('T')[0];

      final Map<String, dynamic> formData = {
        'booking_date': formatDate(formValues['booking_date'] as DateTime),
        'move_in_date': formatDate(formValues['move_in_date'] as DateTime),
        'move_out_date': formValues['move_out_date'] != null
            ? formatDate(formValues['move_out_date'] as DateTime)
            : null,
        'monthly_rent':
            (double.tryParse(formValues['monthly_rent'].toString()) ?? 0)
                .toInt(),
        'security_deposit':
            (double.tryParse(formValues['security_deposit'].toString()) ?? 0)
                .toInt(),
        'profession': formValues['profession'] as String,
        'peoples': (formValues['peoples'] as double).toInt(),
        'room_id': widget.room.roomId,
        'tenant_id': userId,
        'landlord_id': landlordId,
        'status': paymentMethod == 'eSewa' ? 'paid' : 'pending',
        'payment_method': paymentMethod,
      };

      if (paymentMethod == 'eSewa') {
        // Process eSewa payment first
        final totalAmount =
            (formData['monthly_rent'] + formData['security_deposit'])
                .toString();

        final esewa = Esewa();
        await esewa.pay(
          amount: '100',
          onSuccess: (result) async {
            // Payment succeeded, now create booking
            await _handleBooking(formData);
          },
          onFailure: () {
            Fluttertoast.showToast(
              msg: 'Payment failed. Please try again.',
              toastLength: Toast.LENGTH_LONG,
              backgroundColor: Colors.red,
            );
          },
          onCancel: () {
            Fluttertoast.showToast(
              msg: 'Payment was cancelled.',
              toastLength: Toast.LENGTH_LONG,
            );
          },
        );
      } else {
        // Pay Later - just create booking
        await _handleBooking(formData);
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'Error: ${e.toString()}',
        toastLength: Toast.LENGTH_LONG,
        backgroundColor: Colors.red,
      );
      CustomLog.errorLog(value: 'Payment Processing Error: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() => _isProcessingPayment = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          left: 20,
          right: 20,
          top: 8,
        ),
        child: SingleChildScrollView(
          child: FormBuilder(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Simple Drag Handle
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Simple Header
                Text(
                  'Book Room',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                Text(
                  'Fill in the details below',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 10),

                // Booking Date
                _buildSimpleField(
                  child: FormBuilderDateTimePicker(
                    name: 'booking_date',
                    initialValue: null,
                    inputType: InputType.date,
                    format: DateFormat('MMM dd, yyyy'),
                    decoration: _getInputDecoration(
                        'Booking Date', Icons.calendar_today),
                    validator: FormBuilderValidators.required(
                      errorText: 'Please select booking date',
                    ),
                  ),
                ),

                // Move-In Date
                _buildSimpleField(
                  child: FormBuilderDateTimePicker(
                    name: 'move_in_date',
                    initialValue: null,
                    inputType: InputType.date,
                    format: DateFormat('MMM dd, yyyy'),
                    decoration:
                        _getInputDecoration('Move-In Date', Icons.login),
                    validator: FormBuilderValidators.required(
                      errorText: 'Please select move-in date',
                    ),
                  ),
                ),

                // Move-Out Date (Optional)
                _buildSimpleField(
                  child: FormBuilderDateTimePicker(
                    name: 'move_out_date',
                    initialValue: null,
                    inputType: InputType.date,
                    format: DateFormat('MMM dd, yyyy'),
                    decoration: _getInputDecoration(
                        'Move-Out Date (Optional)', Icons.logout),
                  ),
                ),

                // Monthly Rent
                _buildSimpleField(
                  child: FormBuilderTextField(
                    name: 'monthly_rent',
                    initialValue: initialRent.toStringAsFixed(2),
                    decoration: _getInputDecoration(
                        'Monthly Rent (\$)', Icons.attach_money),
                    keyboardType: TextInputType.number,
                    validator: FormBuilderValidators.compose([
                      FormBuilderValidators.required(
                          errorText: 'Enter monthly rent'),
                      FormBuilderValidators.numeric(
                          errorText: 'Must be a valid number'),
                    ]),
                  ),
                ),

                // Security Deposit
                _buildSimpleField(
                  child: FormBuilderTextField(
                    name: 'security_deposit',
                    initialValue: initialDeposit.toStringAsFixed(2),
                    decoration: _getInputDecoration(
                        'Security Deposit (\$)', Icons.security),
                    keyboardType: TextInputType.number,
                    validator: FormBuilderValidators.compose([
                      FormBuilderValidators.required(
                          errorText: 'Enter security deposit'),
                      FormBuilderValidators.numeric(
                          errorText: 'Must be a valid number'),
                    ]),
                  ),
                ),

                // Profession
                _buildSimpleField(
                  child: FormBuilderTextField(
                    name: 'profession',
                    decoration: _getInputDecoration('Profession', Icons.work),
                    validator: FormBuilderValidators.required(
                      errorText: 'Please enter your profession',
                    ),
                  ),
                ),
                _buildSimpleField(
                    child: FormBuilderChoiceChips(
                  name: 'paymentMethods',
                  decoration: const InputDecoration(
                    labelText: 'Payment Method',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                  spacing: 3,
                  runSpacing: 3,
                  selectedColor: Theme.of(context).colorScheme.primary,
                  options: [
                    FormBuilderChipOption(
                      value: 'eSewa',
                      child: Container(
                        width: 120,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'eSewa',
                              style: TextStyle(fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ),
                    ),
                    FormBuilderChipOption(
                      value: 'payLater',
                      child: Container(
                        width: 120,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.schedule, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'Pay Later',
                              style: TextStyle(fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                )),
                _buildSimpleField(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Number of People',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[700],
                        ),
                      ),
                      FormBuilderSlider(
                        name: 'peoples',
                        min: 1,
                        max: 10,
                        initialValue: 1,
                        divisions: 9,
                        activeColor: Colors.blue,
                        inactiveColor: Colors.grey[300],
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                        ),
                        displayValues: DisplayValues.current,
                        validator: FormBuilderValidators.required(
                          errorText: 'Please select number of people',
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed:
                        _isProcessingPayment ? null : _processPaymentAndBooking,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isProcessingPayment
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(
                            'Confirm Booking',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSimpleField({required Widget child}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: child,
    );
  }

  InputDecoration _getInputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(
        icon,
        color: Colors.grey[600],
        size: 20,
      ),
    );
  }
}
