import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  late double _currentRent;
  late double _currentDeposit;
  String _selectedPayment = 'esewa';
  int _occupants = 1;

  @override
  void initState() {
    super.initState();
    _currentRent = widget.room.rentAmount;
    _currentDeposit = widget.room.securityDeposit;
  }

  Future<void> processPaymentAndBooking() async {
    final state = Provider.of<RoomState>(context, listen: false);
    await state.processPaymentAndBooking(widget.room, _formKey);
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<RoomState>(context);
    final totalPayable = _currentRent + _currentDeposit;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: theme.dividerColor.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Flexible(
            child: SingleChildScrollView(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 24,
                bottom: MediaQuery.of(context).viewInsets.bottom + 32,
              ),
              child: FormBuilder(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Book Room ${widget.room.roomNumber}",
                              style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            Text(widget.room.roomType, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.primary)),
                          ],
                        ),
                        IconButton.filledTonal(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // ── LIVE TOTAL CARD ──────────────────────────────────
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeInOut,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: isDark
                              ? [theme.colorScheme.primary.withValues(alpha: 0.25), const Color(0xFF1A1D2E)]
                              : [theme.colorScheme.primary.withValues(alpha: 0.08), theme.colorScheme.primary.withValues(alpha: 0.03)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.22), width: 1.5),
                        boxShadow: [
                          BoxShadow(color: theme.colorScheme.primary.withValues(alpha: 0.07), blurRadius: 12, offset: const Offset(0, 4)),
                        ],
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(children: [
                                Icon(Icons.receipt_long_rounded, color: theme.colorScheme.primary, size: 18),
                                const SizedBox(width: 8),
                                Text('Payment Breakdown', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: isDark ? Colors.white70 : const Color(0xFF374151))),
                              ]),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: Colors.green.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
                                ),
                                child: Row(children: [
                                  const Icon(Icons.circle, color: Colors.green, size: 7),
                                  const SizedBox(width: 4),
                                  const Text('LIVE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.green, letterSpacing: 0.8)),
                                ]),
                              ),
                            ],
                          ),
                          Divider(height: 20, color: theme.dividerColor.withValues(alpha: 0.3)),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                _miniLabel('Monthly Rent'),
                                Text('Rs. ${_currentRent.toStringAsFixed(0)}', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: isDark ? Colors.white : const Color(0xFF1F2937))),
                                const SizedBox(height: 8),
                                _miniLabel('Security Deposit'),
                                Text('Rs. ${_currentDeposit.toStringAsFixed(0)}', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: isDark ? Colors.white : const Color(0xFF1F2937))),
                              ]),
                              Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                                Text('TOTAL PAYABLE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: isDark ? Colors.white38 : Colors.grey.shade500, letterSpacing: 0.8)),
                                const SizedBox(height: 4),
                                Text('NPR ${totalPayable.toStringAsFixed(0)}', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: theme.colorScheme.primary, letterSpacing: -0.5)),
                              ]),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 28),

                    // ── BOOKING DATES ─────────────────────────────────────
                    _sectionLabel('Booking Dates', Icons.date_range_rounded, isDark),
                    const SizedBox(height: 12),
                    Row(children: [
                      Expanded(child: FormBuilderDateTimePicker(
                        name: 'booking_date',
                        initialValue: DateTime.now(),
                        inputType: InputType.date,
                        format: DateFormat('MMM dd, yyyy'),
                        decoration: _inputDecoration('Booking Date', Icons.calendar_today_rounded, isDark),
                        validator: FormBuilderValidators.required(errorText: 'Required'),
                      )),
                      const SizedBox(width: 12),
                      Expanded(child: FormBuilderDateTimePicker(
                        name: 'move_in_date',
                        initialValue: DateTime.now().add(const Duration(days: 1)),
                        inputType: InputType.date,
                        format: DateFormat('MMM dd, yyyy'),
                        decoration: _inputDecoration('Move-In Date', Icons.event_available_rounded, isDark),
                        validator: FormBuilderValidators.required(errorText: 'Required'),
                      )),
                    ]),
                    const SizedBox(height: 12),
                    FormBuilderDateTimePicker(
                      name: 'move_out_date',
                      inputType: InputType.date,
                      format: DateFormat('MMM dd, yyyy'),
                      decoration: _inputDecoration('Move-Out Date (Optional)', Icons.event_busy_rounded, isDark),
                    ),

                    const SizedBox(height: 24),

                    // ── PAYMENT AMOUNTS ───────────────────────────────────
                    _sectionLabel('Payment Amounts', Icons.payments_rounded, isDark),
                    const SizedBox(height: 12),
                    Row(children: [
                      Expanded(child: FormBuilderTextField(
                        name: 'monthly_rent',
                        initialValue: _currentRent.toStringAsFixed(0),
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        onChanged: (val) => setState(() => _currentRent = double.tryParse(val ?? '') ?? 0.0),
                        decoration: _inputDecoration('Monthly Rent', Icons.account_balance_wallet_rounded, isDark),
                        validator: FormBuilderValidators.compose([
                          FormBuilderValidators.required(errorText: 'Required'),
                          FormBuilderValidators.numeric(errorText: 'Invalid'),
                        ]),
                      )),
                      const SizedBox(width: 12),
                      Expanded(child: FormBuilderTextField(
                        name: 'security_deposit',
                        initialValue: _currentDeposit.toStringAsFixed(0),
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        onChanged: (val) => setState(() => _currentDeposit = double.tryParse(val ?? '') ?? 0.0),
                        decoration: _inputDecoration('Security Deposit', Icons.security_rounded, isDark),
                        validator: FormBuilderValidators.compose([
                          FormBuilderValidators.required(errorText: 'Required'),
                          FormBuilderValidators.numeric(errorText: 'Invalid'),
                        ]),
                      )),
                    ]),

                    const SizedBox(height: 24),

                    // ── TENANT INFO ───────────────────────────────────────
                    _sectionLabel('Tenant Information', Icons.person_rounded, isDark),
                    const SizedBox(height: 12),
                    FormBuilderTextField(
                      name: 'profession',
                      decoration: _inputDecoration('Profession / Occupation', Icons.badge_rounded, isDark),
                      validator: FormBuilderValidators.required(errorText: 'Please enter your profession'),
                    ),
                    const SizedBox(height: 12),

                    // Occupants counter
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1C1F2E) : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: isDark ? Colors.white12 : Colors.grey.shade300),
                      ),
                      child: Row(children: [
                        Icon(Icons.people_rounded, size: 20, color: isDark ? Colors.white54 : Colors.grey.shade500),
                        const SizedBox(width: 12),
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          _miniLabel('Number of Occupants'),
                          Text('$_occupants ${_occupants == 1 ? 'Person' : 'People'}', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: isDark ? Colors.white : const Color(0xFF1F2937))),
                        ])),
                        FormBuilderField<double>(
                          name: 'peoples',
                          initialValue: 1,
                          builder: (field) => Row(children: [
                            _counterBtn(Icons.remove_rounded, _occupants > 1 ? () => setState(() { _occupants--; field.didChange(_occupants.toDouble()); }) : null, isDark, theme.colorScheme.primary),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 14),
                              child: Text('$_occupants', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: theme.colorScheme.primary)),
                            ),
                            _counterBtn(Icons.add_rounded, _occupants < 6 ? () => setState(() { _occupants++; field.didChange(_occupants.toDouble()); }) : null, isDark, theme.colorScheme.primary),
                          ]),
                        ),
                      ]),
                    ),

                    const SizedBox(height: 24),

                    // ── PAYMENT METHOD ────────────────────────────────────
                    _sectionLabel('Payment Method', Icons.credit_card_rounded, isDark),
                    const SizedBox(height: 12),
                    _paymentTile('esewa', 'eSewa Digital Wallet', 'Instant digital payment', Icons.account_balance_wallet_rounded, const Color(0xFF60BB44), isDark, theme.colorScheme.primary),
                    const SizedBox(height: 10),
                    _paymentTile('cash', 'Cash on Move-In', 'Pay when you arrive', Icons.payments_rounded, const Color(0xFFF59E0B), isDark, theme.colorScheme.primary),

                    // Hidden form field for payment_method
                    SizedBox(
                      height: 0,
                      child: Opacity(
                        opacity: 0,
                        child: FormBuilderRadioGroup<String>(
                          name: 'payment_method',
                          initialValue: _selectedPayment,
                          options: const [
                            FormBuilderFieldOption(value: 'esewa'),
                            FormBuilderFieldOption(value: 'cash'),
                          ],
                          decoration: const InputDecoration(border: InputBorder.none),
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // ── CONFIRM BUTTON ────────────────────────────────────
                    SizedBox(
                      width: double.infinity,
                      height: 58,
                      child: ElevatedButton(
                        onPressed: state.isLoading ? null : () async {
                          _formKey.currentState?.fields['payment_method']?.didChange(_selectedPayment);
                          await processPaymentAndBooking();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.colorScheme.primary,
                          foregroundColor: Colors.white,
                          elevation: 8,
                          shadowColor: theme.colorScheme.primary.withValues(alpha: 0.4),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                        ),
                        child: state.isLoading
                            ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                            : Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                                const Icon(Icons.lock_rounded, size: 18),
                                const SizedBox(width: 10),
                                Text('Confirm & Pay NPR ${totalPayable.toStringAsFixed(0)}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                              ]),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Center(child: Text('🔒 Secured by eSewa & SSL', style: TextStyle(fontSize: 11, color: isDark ? Colors.white30 : Colors.grey.shade400))),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _miniLabel(String text) => Text(text, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: Theme.of(context).hintColor));

  Widget _sectionLabel(String label, IconData icon, bool isDark) => Row(children: [
    Icon(icon, size: 16, color: Theme.of(context).colorScheme.primary),
    const SizedBox(width: 8),
    Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: isDark ? Colors.white60 : const Color(0xFF6B7280), letterSpacing: 0.5)),
    const SizedBox(width: 10),
    Expanded(child: Container(height: 1, color: isDark ? Colors.white10 : Colors.grey.shade200)),
  ]);

  Widget _counterBtn(IconData icon, VoidCallback? onTap, bool isDark, Color primary) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: 32, height: 32,
      decoration: BoxDecoration(
        color: onTap != null ? primary.withValues(alpha: 0.15) : (isDark ? Colors.white10 : Colors.grey.shade100),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: onTap != null ? primary.withValues(alpha: 0.3) : Colors.transparent),
      ),
      child: Icon(icon, size: 16, color: onTap != null ? primary : (isDark ? Colors.white24 : Colors.grey.shade400)),
    ),
  );

  Widget _paymentTile(String value, String label, String subtitle, IconData icon, Color iconColor, bool isDark, Color primary) {
    final isSelected = _selectedPayment == value;
    return GestureDetector(
      onTap: () {
        setState(() => _selectedPayment = value);
        _formKey.currentState?.fields['payment_method']?.didChange(value);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? primary.withValues(alpha: isDark ? 0.18 : 0.07) : (isDark ? const Color(0xFF1C1F2E) : Colors.white),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: isSelected ? primary : (isDark ? Colors.white10 : Colors.grey.shade200), width: isSelected ? 2 : 1),
        ),
        child: Row(children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(color: iconColor.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, size: 20, color: iconColor),
          ),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: isDark ? Colors.white : const Color(0xFF1F2937))),
            Text(subtitle, style: TextStyle(fontSize: 11, color: isDark ? Colors.white38 : Colors.grey.shade500)),
          ])),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 22, height: 22,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isSelected ? primary : Colors.transparent,
              border: Border.all(color: isSelected ? primary : (isDark ? Colors.white24 : Colors.grey.shade300), width: 2),
            ),
            child: isSelected ? const Icon(Icons.check_rounded, size: 13, color: Colors.white) : null,
          ),
        ]),
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon, bool isDark) => InputDecoration(
    labelText: label,
    prefixIcon: Icon(icon),
    filled: true,
    fillColor: isDark ? const Color(0xFF1C1F2E) : Colors.white,
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: isDark ? Colors.white12 : Colors.grey.shade300)),
    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: isDark ? Colors.white12 : Colors.grey.shade300)),
    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2)),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
  );
}
