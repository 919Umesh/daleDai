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
        color: colorScheme.surface,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          left: 24,
          right: 24,
          top: 12,
        ),
        child: SingleChildScrollView(
          child: FormBuilder(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Modern Drag Handle
                Center(
                  child: Container(
                    width: 48,
                    height: 4,
                    decoration: BoxDecoration(
                      color: colorScheme.onSurfaceVariant.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Modern Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        Icons.home_rounded,
                        color: colorScheme.onPrimaryContainer,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Book This Room',
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          Text(
                            'Fill in the details to confirm your booking',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Date Section
                _buildSectionTitle(
                    'Booking Dates', Icons.event_rounded, context),
                const SizedBox(height: 16),

                // Booking Date
                _buildModernDatePicker(
                  name: 'booking_date',
                  label: 'Booking Date',
                  hint: 'When did you book?',
                  icon: Icons.event_note_rounded,
                  context: context,
                  validator: FormBuilderValidators.required(
                    errorText: 'Please select booking date',
                  ),
                ),
                const SizedBox(height: 16),

                // Move-In Date
                _buildModernDatePicker(
                  name: 'move_in_date',
                  label: 'Move-In Date',
                  hint: 'When will you move in?',
                  icon: Icons.login_rounded,
                  context: context,
                  validator: FormBuilderValidators.required(
                    errorText: 'Please select move-in date',
                  ),
                ),
                const SizedBox(height: 16),

                // Move-Out Date
                _buildModernDatePicker(
                  name: 'move_out_date',
                  label: 'Move-Out Date',
                  hint: 'When will you move out? (Optional)',
                  icon: Icons.logout_rounded,
                  context: context,
                  isOptional: true,
                ),

                const SizedBox(height: 32),

                // Payment Section
                _buildSectionTitle(
                    'Payment Details', Icons.payments_rounded, context),
                const SizedBox(height: 16),

                // Monthly Rent
                _buildModernTextField(
                  name: 'monthly_rent',
                  label: 'Monthly Rent',
                  hint: 'Enter monthly rent amount',
                  icon: Icons.attach_money_rounded,
                  prefixText: '\$ ',
                  initialValue: initialRent.toStringAsFixed(2),
                  context: context,
                  validator: FormBuilderValidators.compose([
                    FormBuilderValidators.required(
                        errorText: 'Enter monthly rent'),
                    FormBuilderValidators.numeric(
                        errorText: 'Must be a valid number'),
                  ]),
                ),
                const SizedBox(height: 16),

                // Security Deposit
                _buildModernTextField(
                  name: 'security_deposit',
                  label: 'Security Deposit',
                  hint: 'Enter security deposit amount',
                  icon: Icons.security_rounded,
                  prefixText: '\$ ',
                  initialValue: initialDeposit.toStringAsFixed(2),
                  context: context,
                  validator: FormBuilderValidators.compose([
                    FormBuilderValidators.required(
                        errorText: 'Enter security deposit'),
                    FormBuilderValidators.numeric(
                        errorText: 'Must be a valid number'),
                  ]),
                ),

                const SizedBox(height: 40),

                // Modern Confirm Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
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

                          // Parse numeric values safely - first to double, then to int
                          final monthlyRent = (double.tryParse(
                                      formValues['monthly_rent'].toString()) ??
                                  0)
                              .toInt();
                          final securityDeposit = (double.tryParse(
                                      formValues['security_deposit']
                                          .toString()) ??
                                  0)
                              .toInt();

                          // Format dates to match the 'date' type in your table (not timestamp)
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
                            'room_id': widget.room.roomId,
                            'tenant_id': userId,
                            'landlord_id': landlordId,
                            'status': 'pending',
                          };
                          await context
                              .read<RoomState>()
                              .createBooking(formData);
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Row(
                                children: [
                                  Icon(Icons.check_circle_rounded,
                                      color: Colors.white),
                                  const SizedBox(width: 12),
                                  const Text('Booking confirmed successfully!'),
                                ],
                              ),
                              backgroundColor: Colors.green,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          );
                        } catch (e) {
                          CustomLog.successLog(value: 'Error: ${e.toString()}');
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Row(
                                children: [
                                  Icon(Icons.error_rounded,
                                      color: Colors.white),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child:
                                        Text('Booking failed: ${e.toString()}'),
                                  ),
                                ],
                              ),
                              backgroundColor: Colors.red,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          );
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      foregroundColor: colorScheme.onPrimary,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_circle_rounded, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Confirm Booking',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onPrimary,
                          ),
                        ),
                      ],
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

  Widget _buildSectionTitle(String title, IconData icon, BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: colorScheme.secondaryContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            size: 20,
            color: colorScheme.onSecondaryContainer,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  Widget _buildModernDatePicker({
    required String name,
    required String label,
    required String hint,
    required IconData icon,
    required BuildContext context,
    String? Function(DateTime?)? validator,
    bool isOptional = false,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return FormBuilderDateTimePicker(
      name: name,
      initialValue: null,
      inputType: InputType.date,
      format: DateFormat('MMM dd, yyyy'),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Container(
          margin: const EdgeInsets.all(12),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer.withOpacity(0.3),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            size: 20,
            color: colorScheme.primary,
          ),
        ),
        suffixIcon: isOptional
            ? Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Chip(
                  label: Text(
                    'Optional',
                    style: TextStyle(fontSize: 12),
                  ),
                  backgroundColor: colorScheme.surfaceVariant,
                  side: BorderSide.none,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: colorScheme.outline.withOpacity(0.2),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: colorScheme.outline.withOpacity(0.2),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: colorScheme.primary,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: colorScheme.error,
          ),
        ),
        filled: true,
        fillColor: colorScheme.surfaceVariant.withOpacity(0.3),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 20,
        ),
      ),
      validator: validator,
    );
  }

  Widget _buildModernTextField({
    required String name,
    required String label,
    required String hint,
    required IconData icon,
    required BuildContext context,
    String? prefixText,
    String? initialValue,
    String? Function(String?)? validator,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return FormBuilderTextField(
      name: name,
      initialValue: initialValue,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Container(
          margin: const EdgeInsets.all(12),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer.withOpacity(0.3),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            size: 20,
            color: colorScheme.primary,
          ),
        ),
        prefixText: prefixText,
        prefixStyle: TextStyle(
          color: colorScheme.onSurface,
          fontWeight: FontWeight.w500,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: colorScheme.outline.withOpacity(0.2),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: colorScheme.outline.withOpacity(0.2),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: colorScheme.primary,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: colorScheme.error,
          ),
        ),
        filled: true,
        fillColor: colorScheme.surfaceVariant.withOpacity(0.3),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 20,
        ),
      ),
      keyboardType: TextInputType.number,
      validator: validator,
    );
  }
}
