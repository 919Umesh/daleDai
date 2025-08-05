import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:intl/intl.dart';
import 'package:omspos/screen/room/model/room_model.dart';
import 'package:omspos/screen/room/state/room_state.dart';
import 'package:omspos/services/notification/onesignal_service.dart';
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

  @override
  void initState() {
    super.initState();
    initialRent = widget.room.rentAmount;
    initialDeposit = widget.room.securityDeposit;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

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
                const SizedBox(height: 24),

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
                  child: FormBuilderChoiceChip<String>(
                    name: 'payment_method',
                    decoration: const InputDecoration(
                      labelText: 'Select payment method',
                      border: InputBorder.none,
                    ),
                    validator: FormBuilderValidators.required(
                      errorText: 'Please select a payment method',
                    ),
                    options: [
                      FormBuilderFieldOption<String>(
                        value: 'esewa',
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.payment, color: Colors.green),
                            SizedBox(width: 5),
                            Text('eSewa'),
                          ],
                        ),
                      ),
                      FormBuilderFieldOption<String>(
                        value: 'paylater',
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.schedule, color: Colors.orange),
                            SizedBox(width: 5),
                            Text('Pay Later'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Number of People (Slider)
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
                      const SizedBox(height: 8),
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

                // Simple Confirm Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.saveAndValidate()) {
                        try {
                          final userId =
                              await SharedPrefService.getValue<String>(
                            PrefKey.userId,
                            defaultValue: "-",
                          );
                          final landlordId =
                              await SharedPrefService.getValue<String>(
                            PrefKey.landLordId,
                            defaultValue: "-",
                          );

                          final formValues = _formKey.currentState!.value;

                          // Parse numeric values safely
                          final monthlyRent = (double.tryParse(
                                      formValues['monthly_rent'].toString()) ??
                                  0)
                              .toInt();
                          final securityDeposit = (double.tryParse(
                                      formValues['security_deposit']
                                          .toString()) ??
                                  0)
                              .toInt();
                          final peoples =
                              (formValues['peoples'] as double).toInt();

                          // Format dates
                          final formatDate = (DateTime date) =>
                              date.toIso8601String().split('T')[0];

                          final Map<String, dynamic> formData = {
                            ...formValues,
                            'booking_date': formatDate(
                                formValues['booking_date'] as DateTime),
                            'move_in_date': formatDate(
                                formValues['move_in_date'] as DateTime),
                            'move_out_date': formValues['move_out_date'] != null
                                ? formatDate(
                                    formValues['move_out_date'] as DateTime)
                                : null,
                            'monthly_rent': monthlyRent,
                            'security_deposit': securityDeposit,
                            'profession': formValues['profession'] as String,
                            'peoples': peoples,
                            'room_id': widget.room.roomId,
                            'tenant_id': userId,
                            'landlord_id': landlordId,
                            'status': 'pending',
                          };
                          // Esewa esewa = Esewa();
                          // esewa.pay();
                          await context
                              .read<RoomState>()
                              .createBooking(formData);
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Booking confirmed successfully!'),
                              backgroundColor: Colors.green,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          );
                        } catch (e) {
                          CustomLog.successLog(value: 'Error: ${e.toString()}');
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Booking failed: ${e.toString()}'),
                              backgroundColor: Colors.red,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          );
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
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
      padding: const EdgeInsets.only(bottom: 16),
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
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.blue, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.red),
      ),
      filled: true,
      fillColor: Colors.grey[50],
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 16,
      ),
      labelStyle: TextStyle(
        color: Colors.grey[700],
        fontSize: 14,
      ),
    );
  }
}
