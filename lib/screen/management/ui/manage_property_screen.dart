import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:omspos/screen/management/api/management_api.dart';
import 'package:omspos/screen/management/model/management_models.dart';
import 'package:omspos/screen/management/ui/widget/device_image_picker.dart';
import 'package:omspos/services/images/image_upload_service.dart';

class ManagePropertyScreen extends StatefulWidget {
  const ManagePropertyScreen({super.key, required this.propertyId});
  final String propertyId;

  @override
  State<ManagePropertyScreen> createState() => _ManagePropertyScreenState();
}

class _ManagePropertyScreenState extends State<ManagePropertyScreen> {
  final _money =
      NumberFormat.currency(locale: 'en_IN', symbol: 'NPR ', decimalDigits: 0);
  bool _loading = true;
  String? _error;
  String _title = 'Property';
  List<ManagedUnit> _units = const [];
  List<Map<String, dynamic>> _maintenance = const [];
  List<Map<String, dynamic>> _expenses = const [];
  List<Map<String, dynamic>> _applications = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final result = await Future.wait([
        ManagementApi.getProperty(widget.propertyId),
        ManagementApi.getUnits(widget.propertyId),
        ManagementApi.getMaintenance(widget.propertyId),
        ManagementApi.getExpenses(widget.propertyId),
        ManagementApi.getApplications(widget.propertyId),
      ]);
      if (!mounted) return;
      setState(() {
        _title = (result[0] as Map<String, dynamic>)['title']?.toString() ??
            'Property';
        _units = result[1] as List<ManagedUnit>;
        _maintenance = result[2] as List<Map<String, dynamic>>;
        _expenses = result[3] as List<Map<String, dynamic>>;
        _applications = result[4] as List<Map<String, dynamic>>;
        _loading = false;
      });
    } catch (e) {
      if (mounted)
        setState(() {
          _error = e.toString();
          _loading = false;
        });
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text(_title),
          actions: [
            IconButton(onPressed: _load, icon: const Icon(Icons.refresh))
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _openUnitEditor(),
          icon: const Icon(Icons.add),
          label: const Text('Add unit'),
        ),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? Center(
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                    Text(_error!, textAlign: TextAlign.center),
                    const SizedBox(height: 12),
                    FilledButton(onPressed: _load, child: const Text('Retry'))
                  ]))
                : RefreshIndicator(
                    onRefresh: _load,
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                      children: [
                        _propertySummary(),
                        const SizedBox(height: 18),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: _addExpense,
                            icon: const Icon(Icons.add_card_outlined),
                            label: const Text('Record an expense'),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Rental applications',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.copyWith(fontWeight: FontWeight.bold)),
                            Text('${_applications.length} pending'),
                          ],
                        ),
                        const SizedBox(height: 10),
                        if (_applications.isEmpty)
                          const Card(
                            child: Padding(
                              padding: EdgeInsets.all(20),
                              child: Row(children: [
                                Icon(Icons.assignment_turned_in_outlined),
                                SizedBox(width: 12),
                                Expanded(
                                  child: Text('No pending rental applications.'),
                                ),
                              ]),
                            ),
                          )
                        else
                          ..._applications.map(_applicationCard),
                        const SizedBox(height: 24),
                        Text('Rooms and flats',
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 10),
                        if (_units.isEmpty)
                          const Card(
                              child: Padding(
                                  padding: EdgeInsets.all(24),
                                  child: Column(children: [
                                    Icon(Icons.meeting_room_outlined, size: 48),
                                    SizedBox(height: 8),
                                    Text(
                                        'No units yet. Add a room, flat, shop, or office.')
                                  ]))),
                        ..._units.map(_unitCard),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Expenses',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.copyWith(fontWeight: FontWeight.bold)),
                            Text(_money.format(_expenses.fold<num>(
                                0,
                                (sum, expense) =>
                                    sum +
                                    ((expense['amount'] as num?) ?? 0)))),
                          ],
                        ),
                        const SizedBox(height: 10),
                        if (_expenses.isEmpty)
                          const Card(
                            child: Padding(
                              padding: EdgeInsets.all(20),
                              child: Row(children: [
                                Icon(Icons.receipt_long_outlined),
                                SizedBox(width: 12),
                                Expanded(child: Text('No expenses recorded yet.')),
                              ]),
                            ),
                          ),
                        ..._expenses.take(20).map(_expenseCard),
                        const SizedBox(height: 24),
                        Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Maintenance',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleLarge
                                      ?.copyWith(fontWeight: FontWeight.bold)),
                              Text(
                                  '${_maintenance.where((m) => m['status'] != 'resolved' && m['status'] != 'cancelled').length} open'),
                            ]),
                        const SizedBox(height: 10),
                        if (_maintenance.isEmpty)
                          const Text('No maintenance requests recorded.'),
                        ..._maintenance.take(10).map(_maintenanceCard),
                      ],
                    ),
                  ),
      );

  Widget _propertySummary() {
    final occupied = _units.where((u) => u.isOccupied).length;
    final potential = _units.fold<double>(0, (sum, unit) => sum + unit.rent);
    final cards = [
      ('Units', '${_units.length}', Icons.home_work_outlined, Colors.indigo),
      ('Occupied', '$occupied', Icons.people_alt_outlined, Colors.orange),
      ('Vacant', '${_units.length - occupied}', Icons.meeting_room_outlined,
        Colors.green),
      ('Rent / month', _money.format(potential), Icons.payments_outlined,
        Colors.teal),
    ];
    return LayoutBuilder(
      builder: (context, constraints) {
        final gap = 10.0;
        final width = (constraints.maxWidth - gap) / 2;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: cards
              .map((card) => SizedBox(
                    width: width,
                    child: _statCard(
                        card.$1, card.$2, card.$3, card.$4),
                  ))
              .toList(),
        );
      },
    );
  }

  Widget _statCard(String label, String value, IconData icon, Color color) =>
      Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: color.withValues(alpha: .1),
          border: Border.all(color: color.withValues(alpha: .22)),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: color.withValues(alpha: .16),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(value,
                      style: const TextStyle(
                          fontWeight: FontWeight.w800, fontSize: 17)),
                ),
                Text(label, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
        ]),
      );

  Widget _unitCard(ManagedUnit unit) {
    final statusColor = unit.isOccupied ? Colors.orange : Colors.green;
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            CircleAvatar(
                backgroundColor: statusColor.withValues(alpha: .14),
                child: Icon(
                    unit.kind == 'flat' || unit.kind == 'apartment'
                        ? Icons.apartment
                        : Icons.meeting_room_outlined,
                    color: statusColor)),
            const SizedBox(width: 12),
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text('${_label(unit.kind)} ${unit.number}',
                      style: const TextStyle(
                          fontSize: 17, fontWeight: FontWeight.bold)),
                  Text(
                      '${_money.format(unit.rent)}/month • due day ${unit.rentDueDay}'),
                ])),
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'edit') _openUnitEditor(unit);
                if (value == 'details') _showTenantDetails(unit);
                if (value == 'vacate') _vacate(unit);
              },
              itemBuilder: (_) => [
                const PopupMenuItem(value: 'edit', child: Text('Edit unit')),
                if (unit.isOccupied && unit.tenancyId != null)
                  const PopupMenuItem(
                      value: 'details', child: Text('View resident details')),
                if (unit.isOccupied && unit.tenancyId != null)
                  const PopupMenuItem(
                      value: 'vacate', child: Text('Mark vacant')),
              ],
            ),
          ]),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .surfaceContainerHighest
                    .withValues(alpha: .55),
                borderRadius: BorderRadius.circular(10)),
            child: unit.isOccupied
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                        Row(children: [
                          const Icon(Icons.person_outline, size: 18),
                          const SizedBox(width: 6),
                          Expanded(
                              child: Text(unit.tenantName ?? 'Occupied',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w700)))
                        ]),
                        if (unit.tenantPhone?.isNotEmpty == true)
                          Text(unit.tenantPhone!),
                        if (unit.nextDueDate != null)
                          Text(
                              'Next rent: ${DateFormat.yMMMd().format(unit.nextDueDate!)} • ${_money.format(unit.balanceDue)}'),
                      ])
                : const Row(children: [
                    Icon(Icons.check_circle_outline,
                        color: Colors.green, size: 18),
                    SizedBox(width: 6),
                    Text('Available for a tenant')
                  ]),
          ),
          if (unit.isOccupied && unit.tenancyId != null)
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () => _showTenantDetails(unit),
                icon: const Icon(Icons.badge_outlined, size: 18),
                label: const Text('Tenant details & rent history'),
              ),
            ),
          if (unit.description.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(unit.description, maxLines: 2, overflow: TextOverflow.ellipsis)
          ],
          const SizedBox(height: 10),
          if (unit.isOccupied && unit.tenancyId != null)
            Row(children: [
              Expanded(
                child: FilledButton.tonalIcon(
                  onPressed: () => _showTenantDetails(unit),
                  icon: const Icon(Icons.badge_outlined, size: 18),
                  label: const Text('Resident details'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _vacate(unit),
                  icon: const Icon(Icons.logout, size: 18),
                  label: const Text('Move out'),
                ),
              ),
            ])
          else
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _openUnitEditor(unit),
                icon: const Icon(Icons.edit_outlined, size: 18),
                label: const Text('Edit unit'),
              ),
            ),
        ]),
      ),
    );
  }

  Widget _applicationCard(Map<String, dynamic> application) {
    final moveIn =
        DateTime.tryParse(application['move_in_date']?.toString() ?? '');
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            CircleAvatar(
              backgroundColor:
                  Theme.of(context).colorScheme.primaryContainer,
              child: const Icon(Icons.person_outline),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(application['tenant_name']?.toString() ?? 'Applicant',
                      style: const TextStyle(fontWeight: FontWeight.w700)),
                  Text('Unit ${application['room_number'] ?? ''}'),
                ],
              ),
            ),
            Chip(
              label: const Text('Pending'),
              side: BorderSide.none,
              backgroundColor: Colors.orange.withValues(alpha: .14),
            ),
          ]),
          const SizedBox(height: 10),
          Wrap(spacing: 14, runSpacing: 6, children: [
            if (application['tenant_phone']?.toString().isNotEmpty == true)
              Text('📞 ${application['tenant_phone']}'),
            if (application['tenant_email']?.toString().isNotEmpty == true)
              Text('✉ ${application['tenant_email']}'),
            if (moveIn != null)
              Text('Move-in ${DateFormat.yMMMd().format(moveIn)}'),
            Text('${application['peoples'] ?? 1} occupant(s)'),
          ]),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(
              child: Text(
                '${_money.format((application['monthly_rent'] as num?) ?? 0)}/month',
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
            FilledButton.icon(
              onPressed: () => _approveApplication(application),
              icon: const Icon(Icons.check_circle_outline),
              label: const Text('Approve'),
            ),
          ]),
        ]),
      ),
    );
  }

  Future<void> _approveApplication(Map<String, dynamic> application) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Approve rental application?'),
        content: Text(
          '${application['tenant_name'] ?? 'This tenant'} will be assigned to unit ${application['room_number'] ?? ''}.',
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Approve')),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await ManagementApi.approveApplication(
          application['booking_id'].toString());
      await _load();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tenant assigned successfully.')),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not approve application: $error')),
        );
      }
    }
  }

  Widget _maintenanceCard(Map<String, dynamic> item) {
    final resolved = item['status'] == 'resolved';
    final room = item['rooms'] as Map<String, dynamic>?;
    return Card(
        child: ListTile(
      leading: Icon(resolved ? Icons.check_circle : Icons.build_circle_outlined,
          color: resolved ? Colors.green : null),
      title: Text(item['title']?.toString() ?? 'Maintenance'),
      subtitle: Text(
          '${_label(item['priority']?.toString() ?? 'normal')} priority${room == null ? '' : ' • Unit ${room['room_number']}'}'),
      trailing: resolved
          ? const Text('Resolved')
          : TextButton(
              onPressed: () async {
                await ManagementApi.resolveMaintenance(
                    item['maintenance_id'].toString());
                _load();
              },
              child: const Text('Resolve')),
    ));
  }

  Widget _expenseCard(Map<String, dynamic> expense) {
    final room = expense['rooms'] as Map<String, dynamic>?;
    final date = DateTime.tryParse(expense['expense_date']?.toString() ?? '');
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          child: Icon(
            expense['category'] == 'maintenance'
                ? Icons.build_outlined
                : Icons.receipt_long_outlined,
          ),
        ),
        title: Text(expense['description']?.toString() ?? 'Expense'),
        subtitle: Text([
          _label(expense['category']?.toString() ?? 'other'),
          if (room != null) 'Unit ${room['room_number']}',
          if (date != null) DateFormat.yMMMd().format(date),
        ].join(' • ')),
        trailing: Text(
          _money.format((expense['amount'] as num?) ?? 0),
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
    );
  }

  String _label(String value) => value
      .replaceAll('_', ' ')
      .split(' ')
      .map((e) => e.isEmpty ? e : '${e[0].toUpperCase()}${e.substring(1)}')
      .join(' ');

  Future<void> _openUnitEditor([ManagedUnit? unit]) async {
    final changed = await Navigator.push<bool>(
        context,
        MaterialPageRoute(
            builder: (_) =>
                UnitEditorScreen(propertyId: widget.propertyId, unit: unit)));
    if (changed == true) _load();
  }

  Future<void> _showTenantDetails(ManagedUnit unit) async {
    final tenancyId = unit.tenancyId;
    if (tenancyId == null) return;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (sheetContext) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: .78,
        maxChildSize: .95,
        builder: (_, controller) => FutureBuilder<List<RentLedgerItem>>(
          future: ManagementApi.getTenancyLedger(tenancyId),
          builder: (context, snapshot) => ListView(
            controller: controller,
            padding: const EdgeInsets.all(20),
            children: [
              Center(
                child: Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                unit.tenantName ?? 'Tenant',
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              _tenantRow(Icons.meeting_room_outlined, 'Unit', unit.number),
              _tenantRow(
                  Icons.phone_outlined,
                  'Phone',
                  unit.tenantPhone?.isNotEmpty == true
                      ? unit.tenantPhone!
                      : 'Not provided'),
              _tenantRow(
                  Icons.email_outlined,
                  'Email',
                  unit.tenantEmail?.isNotEmpty == true
                      ? unit.tenantEmail!
                      : 'Not provided'),
              _tenantRow(
                  Icons.emergency_outlined,
                  'Emergency contact',
                  unit.emergencyContact?.isNotEmpty == true
                      ? unit.emergencyContact!
                      : 'Not provided'),
              _tenantRow(
                  Icons.event_available,
                  'Lease started',
                  unit.leaseStart == null
                      ? 'Not recorded'
                      : DateFormat.yMMMd().format(unit.leaseStart!)),
              _tenantRow(
                  Icons.event_busy_outlined,
                  'Lease ends',
                  unit.leaseEnd == null
                      ? 'Open-ended'
                      : DateFormat.yMMMd().format(unit.leaseEnd!)),
              if (unit.tenancyNotes?.isNotEmpty == true)
                _tenantRow(Icons.notes_outlined, 'Notes', unit.tenancyNotes!),
              const Divider(height: 32),
              Text('Rent history',
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              if (snapshot.connectionState == ConnectionState.waiting)
                const Center(
                    child: Padding(
                        padding: EdgeInsets.all(24),
                        child: CircularProgressIndicator()))
              else if (snapshot.hasError)
                Text('Could not load rent history: ${snapshot.error}')
              else if ((snapshot.data ?? const []).isEmpty)
                const Text('No rent schedule has been generated.')
              else
                ...(snapshot.data ?? const []).map((payment) => ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(
                          payment.status == 'paid'
                              ? Icons.check_circle
                              : Icons.schedule,
                          color:
                              payment.status == 'paid' ? Colors.green : null),
                      title: Text(DateFormat.yMMMM().format(payment.dueDate)),
                      subtitle: Text(
                          'Due ${DateFormat.yMMMd().format(payment.dueDate)} • ${_label(payment.status)}'),
                      trailing: Text(
                          _money.format(payment.paidAmount > 0
                              ? payment.paidAmount
                              : payment.amount),
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                    )),
            ],
          ),
        ),
      ),
    );
  }

  Widget _tenantRow(IconData icon, String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(icon, size: 19),
          const SizedBox(width: 10),
          SizedBox(width: 125, child: Text(label)),
          Expanded(
              child: Text(value,
                  style: const TextStyle(fontWeight: FontWeight.w600))),
        ]),
      );

  Future<void> _vacate(ManagedUnit unit) async {
    final confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
              title: const Text('Mark this unit vacant?'),
              content: Text(
                  '${unit.tenantName ?? 'The tenant'} will be moved out and future unpaid rent entries will be waived.'),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(ctx, false),
                    child: const Text('Cancel')),
                FilledButton(
                    onPressed: () => Navigator.pop(ctx, true),
                    child: const Text('Mark vacant'))
              ],
            ));
    if (confirmed != true || unit.tenancyId == null) return;
    try {
      await ManagementApi.vacateTenant(unit.tenancyId!);
      await _load();
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Could not vacate tenant: $e')));
    }
  }

  Future<void> _addExpense() async {
    final formKey = GlobalKey<FormState>();
    final description = TextEditingController();
    final amount = TextEditingController();
    String category = 'maintenance';
    String? roomId;
    final saved = await showModalBottomSheet<bool>(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        builder: (ctx) => StatefulBuilder(
            builder: (ctx, setLocal) => Padding(
                  padding: EdgeInsets.fromLTRB(
                      20, 12, 20, MediaQuery.viewInsetsOf(ctx).bottom + 20),
                  child: Form(
                    key: formKey,
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: Container(
                              width: 42,
                              height: 4,
                              decoration: BoxDecoration(
                                color: Theme.of(ctx).dividerColor,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Row(children: [
                            CircleAvatar(
                              backgroundColor: Theme.of(ctx)
                                  .colorScheme
                                  .primaryContainer,
                              child: const Icon(Icons.add_card_outlined),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Record expense',
                                    style: Theme.of(ctx)
                                        .textTheme
                                        .titleLarge
                                        ?.copyWith(fontWeight: FontWeight.bold)),
                                const Text('Track a property operating cost'),
                              ],
                            ),
                          ]),
                          const SizedBox(height: 20),
                          DropdownButtonFormField<String>(
                        value: category,
                        decoration: const InputDecoration(
                            labelText: 'Category',
                            prefixIcon: Icon(Icons.category_outlined)),
                        items: const [
                          'maintenance',
                          'utilities',
                          'tax',
                          'salary',
                          'supplies',
                          'other'
                        ]
                            .map((e) => DropdownMenuItem(
                                value: e, child: Text(_label(e))))
                            .toList(),
                        onChanged: (v) => setLocal(() => category = v!)),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String?>(
                        value: roomId,
                        isExpanded: true,
                        decoration: const InputDecoration(
                            labelText: 'Unit',
                            prefixIcon: Icon(Icons.meeting_room_outlined)),
                        items: [
                          const DropdownMenuItem<String?>(
                              value: null, child: Text('Whole property')),
                          ..._units.map((u) => DropdownMenuItem<String?>(
                              value: u.id, child: Text(u.number)))
                        ],
                        onChanged: (v) => setLocal(() => roomId = v)),
                    const SizedBox(height: 12),
                    TextFormField(
                        controller: description,
                        textCapitalization: TextCapitalization.sentences,
                        decoration: const InputDecoration(
                            labelText: 'Description',
                            hintText: 'What was this expense for?',
                            prefixIcon: Icon(Icons.notes_outlined)),
                        validator: (value) => value == null || value.trim().isEmpty
                            ? 'Enter a description'
                            : null),
                    const SizedBox(height: 12),
                    TextFormField(
                        controller: amount,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        decoration: const InputDecoration(
                            labelText: 'Amount',
                            prefixText: 'NPR ',
                            prefixIcon: Icon(Icons.payments_outlined)),
                        validator: (value) =>
                            (double.tryParse(value?.trim() ?? '') ?? 0) <= 0
                                ? 'Enter a valid amount'
                                : null),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: FilledButton.icon(
                        onPressed: () {
                          if (formKey.currentState!.validate()) {
                            Navigator.pop(ctx, true);
                          }
                        },
                        icon: const Icon(Icons.save_outlined),
                        label: const Text('Save expense'),
                      ),
                    ),
                        ],
                      ),
                    ),
                  ),
                )));
    if (saved == true) {
      await ManagementApi.addExpense(
          propertyId: widget.propertyId,
          roomId: roomId,
          category: category,
          description: description.text.trim(),
          amount: double.parse(amount.text),
          expenseDate: DateTime.now());
      await _load();
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Expense recorded')));
      }
    }
    description.dispose();
    amount.dispose();
  }
}
class UnitEditorScreen extends StatefulWidget {
  const UnitEditorScreen({super.key, required this.propertyId, this.unit});
  final String propertyId;
  final ManagedUnit? unit;

  @override
  State<UnitEditorScreen> createState() => _UnitEditorScreenState();
}

class _UnitEditorScreenState extends State<UnitEditorScreen> {
  final _form = GlobalKey<FormState>();
  late final TextEditingController _number;
  late final TextEditingController _rent;
  late final TextEditingController _deposit;
  late final TextEditingController _description;
  List<XFile> _selectedImages = const [];
  List<String> _existingImages = const [];
  final List<String> _removedImages = [];
  String _kind = 'room';
  String _type = 'single';
  int _dueDay = 1;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final u = widget.unit;
    _number = TextEditingController(text: u?.number ?? '');
    _rent = TextEditingController(text: u?.rent.toStringAsFixed(0) ?? '');
    _deposit = TextEditingController(text: u?.deposit.toStringAsFixed(0) ?? '');
    _description = TextEditingController(text: u?.description ?? '');
    _kind = u?.kind ?? _kind;
    _type = u?.type ?? _type;
    _dueDay = u?.rentDueDay ?? 1;
    if (u != null) _loadImages(u.id);
  }

  Future<void> _loadImages(String roomId) async {
    try {
      final images = await ManagementApi.getRoomImages(roomId);
      if (mounted) setState(() => _existingImages = images);
    } catch (_) {
      // The unit can still be edited if an old image record is unavailable.
    }
  }

  @override
  void dispose() {
    _number.dispose();
    _rent.dispose();
    _deposit.dispose();
    _description.dispose();
    super.dispose();
  }

  String? _required(String? v) =>
      v == null || v.trim().isEmpty ? 'Required' : null;

  String? _moneyValidator(String? value) {
    final amount = int.tryParse(value?.trim() ?? '');
    if (amount == null) return 'Enter a whole amount';
    if (amount <= 0) return 'Must be greater than zero';
    return null;
  }

  String? _depositValidator(String? value) {
    final amount = int.tryParse(value?.trim() ?? '');
    if (amount == null) return 'Enter a whole amount';
    if (amount < 0) return 'Cannot be negative';
    return null;
  }

  String _label(String value) => value
      .split('_')
      .map((part) =>
          part.isEmpty ? part : '${part[0].toUpperCase()}${part.substring(1)}')
      .join(' ');

  Widget _sectionCard({required String title, required List<Widget> children}) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 14),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _responsivePair(Widget first, Widget second) => LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 440) {
            return Column(children: [
              first,
              const SizedBox(height: 12),
              second,
            ]);
          }
          return Row(children: [
            Expanded(child: first),
            const SizedBox(width: 12),
            Expanded(child: second),
          ]);
        },
      );

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
            title:
                Text(widget.unit == null ? 'Add room or flat' : 'Edit unit')),
        body: Form(
          key: _form,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
            children: [
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .primaryContainer
                      .withValues(alpha: .55),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(children: [
                  CircleAvatar(
                    radius: 24,
                    child: Icon(widget.unit == null
                        ? Icons.add_home_work_outlined
                        : Icons.edit_outlined),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.unit == null
                              ? 'Create a rentable unit'
                              : 'Update unit details',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 3),
                        const Text('Add pricing, layout and clear photos.'),
                      ],
                    ),
                  ),
                ]),
              ),
              const SizedBox(height: 16),
              _sectionCard(title: 'Unit details', children: [
                _responsivePair(
                  DropdownButtonFormField<String>(
                    value: _kind,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: 'Unit kind',
                      prefixIcon: Icon(Icons.home_work_outlined),
                    ),
                    items: const [
                      'room',
                      'flat',
                      'apartment',
                      'shop',
                      'office',
                      'other'
                    ]
                        .map((e) => DropdownMenuItem(
                              value: e,
                              child: Text(_label(e),
                                  overflow: TextOverflow.ellipsis),
                            ))
                        .toList(),
                    onChanged: (v) => setState(() => _kind = v!),
                  ),
                  TextFormField(
                    controller: _number,
                    decoration: const InputDecoration(
                      labelText: 'Unit number or name',
                      prefixIcon: Icon(Icons.tag_outlined),
                    ),
                    validator: _required,
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _type,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'Room layout',
                    prefixIcon: Icon(Icons.bed_outlined),
                  ),
                  items: const ['single', 'double', 'shared']
                      .map((e) => DropdownMenuItem(
                            value: e,
                            child: Text(_label(e)),
                          ))
                      .toList(),
                  onChanged: (v) => setState(() => _type = v!),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _description,
                  minLines: 3,
                  maxLines: 5,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    hintText: 'Describe the space and its best features',
                    prefixIcon: Icon(Icons.notes_outlined),
                    alignLabelWithHint: true,
                  ),
                  validator: _required,
                ),
              ]),
              const SizedBox(height: 12),
              _sectionCard(title: 'Rent and billing', children: [
                _responsivePair(
                  TextFormField(
                    controller: _rent,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Monthly rent',
                      prefixText: 'NPR ',
                      prefixIcon: Icon(Icons.payments_outlined),
                    ),
                    validator: _moneyValidator,
                  ),
                  TextFormField(
                    controller: _deposit,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Security deposit',
                      prefixText: 'NPR ',
                      prefixIcon: Icon(Icons.savings_outlined),
                    ),
                    validator: _depositValidator,
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<int>(
                  value: _dueDay,
                  decoration: const InputDecoration(
                    labelText: 'Rent due each month',
                    prefixIcon: Icon(Icons.event_repeat_outlined),
                  ),
                  items: List.generate(
                    28,
                    (i) => DropdownMenuItem(
                      value: i + 1,
                      child: Text('Day ${i + 1}'),
                    ),
                  ),
                  onChanged: (v) => setState(() => _dueDay = v!),
                ),
              ]),
              const SizedBox(height: 12),
              _sectionCard(title: 'Unit photos', children: [
                DeviceImagePicker(
                  selectedFiles: _selectedImages,
                  existingUrls: _existingImages,
                  onFilesChanged: (files) =>
                      setState(() => _selectedImages = files),
                  onExistingRemoved: (url) => setState(() {
                    _existingImages = [..._existingImages]..remove(url);
                    _removedImages.add(url);
                  }),
                ),
              ]),
              const SizedBox(height: 18),
              SizedBox(
                height: 52,
                child: FilledButton.icon(
                  onPressed: _saving ? null : _save,
                  icon: _saving
                      ? const SizedBox.square(
                          dimension: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.save_outlined),
                  label: Text(_saving ? 'Saving unit…' : 'Save unit'),
                ),
              ),
            ],
          ),
        ),
      );

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    final rent = int.tryParse(_rent.text.trim());
    final deposit = int.tryParse(_deposit.text.trim());
    if (rent == null || deposit == null) return;
    if (_existingImages.isEmpty && _selectedImages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add at least one unit photo.')),
      );
      return;
    }
    setState(() => _saving = true);
    try {
      final roomId = await ManagementApi.saveUnit(
          roomId: widget.unit?.id,
          values: {
            'property_id': widget.propertyId,
            'room_number': _number.text.trim(),
            'rent_amount': rent,
            'security_deposit': deposit,
            'room_type': _type,
            'unit_kind': _kind,
            'rent_due_day': _dueDay,
            'description': _description.text.trim(),
          });
      final uploaded = await ImageUploadService.uploadAsWebp(
        bucket: 'rooms',
        entityId: roomId,
        files: _selectedImages,
      );
      await ManagementApi.replaceRoomImages(
        roomId,
        [..._existingImages, ...uploaded],
      );
      await ImageUploadService.deleteOwnedUrls(
        bucket: 'rooms',
        urls: _removedImages,
      );
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Could not save unit: $e')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}
