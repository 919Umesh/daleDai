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
      ]);
      if (!mounted) return;
      setState(() {
        _title = (result[0] as Map<String, dynamic>)['title']?.toString() ??
            'Property';
        _units = result[1] as List<ManagedUnit>;
        _maintenance = result[2] as List<Map<String, dynamic>>;
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
                        Row(children: [
                          Expanded(
                              child: OutlinedButton.icon(
                                  onPressed: _addExpense,
                                  icon: const Icon(Icons.receipt_long_outlined),
                                  label: const Text('Add expense'))),
                          const SizedBox(width: 10),
                          Expanded(
                              child: OutlinedButton.icon(
                                  onPressed: _addMaintenance,
                                  icon: const Icon(Icons.build_outlined),
                                  label: const Text('Maintenance'))),
                        ]),
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
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(children: [
          Expanded(child: _stat('Units', '${_units.length}')),
          Expanded(child: _stat('Occupied', '$occupied')),
          Expanded(child: _stat('Vacant', '${_units.length - occupied}')),
          Expanded(child: _stat('Rent/month', _money.format(potential))),
        ]),
      ),
    );
  }

  Widget _stat(String label, String value) => Column(children: [
        FittedBox(
            child: Text(value,
                style: const TextStyle(
                    fontWeight: FontWeight.w800, fontSize: 16))),
        const SizedBox(height: 3),
        Text(label,
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center),
      ]);

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
                if (value == 'tenant') _assignTenant(unit);
                if (value == 'vacate') _vacate(unit);
              },
              itemBuilder: (_) => [
                const PopupMenuItem(value: 'edit', child: Text('Edit unit')),
                if (!unit.isOccupied)
                  const PopupMenuItem(
                      value: 'tenant', child: Text('Assign tenant')),
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
          Row(children: [
            Expanded(
                child: OutlinedButton.icon(
                    onPressed: () => _openUnitEditor(unit),
                    icon: const Icon(Icons.edit_outlined, size: 18),
                    label: const Text('Edit'))),
            const SizedBox(width: 8),
            Expanded(
                child: FilledButton.icon(
              onPressed: unit.isOccupied
                  ? (unit.tenancyId == null ? null : () => _vacate(unit))
                  : () => _assignTenant(unit),
              icon: Icon(unit.isOccupied ? Icons.logout : Icons.person_add_alt),
              label: Text(unit.isOccupied ? 'Vacate' : 'Add tenant'),
            )),
          ]),
        ]),
      ),
    );
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

  Future<void> _assignTenant(ManagedUnit unit) async {
    final changed = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) =>
          TenantEditorSheet(propertyId: widget.propertyId, unit: unit),
    );
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
    final description = TextEditingController();
    final amount = TextEditingController();
    String category = 'maintenance';
    String? roomId;
    final saved = await showDialog<bool>(
        context: context,
        builder: (ctx) => StatefulBuilder(
            builder: (ctx, setLocal) => AlertDialog(
                  title: const Text('Add expense'),
                  content: SingleChildScrollView(
                      child: Column(mainAxisSize: MainAxisSize.min, children: [
                    DropdownButtonFormField(
                        value: category,
                        decoration:
                            const InputDecoration(labelText: 'Category'),
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
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String?>(
                        value: roomId,
                        decoration:
                            const InputDecoration(labelText: 'Unit (optional)'),
                        items: [
                          const DropdownMenuItem<String?>(
                              value: null, child: Text('Whole property')),
                          ..._units.map((u) => DropdownMenuItem<String?>(
                              value: u.id, child: Text(u.number)))
                        ],
                        onChanged: (v) => setLocal(() => roomId = v)),
                    const SizedBox(height: 10),
                    TextField(
                        controller: description,
                        decoration:
                            const InputDecoration(labelText: 'Description')),
                    const SizedBox(height: 10),
                    TextField(
                        controller: amount,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                            labelText: 'Amount', prefixText: 'NPR ')),
                  ])),
                  actions: [
                    TextButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        child: const Text('Cancel')),
                    FilledButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        child: const Text('Save'))
                  ],
                )));
    if (saved == true &&
        description.text.trim().isNotEmpty &&
        (double.tryParse(amount.text) ?? 0) > 0) {
      await ManagementApi.addExpense(
          propertyId: widget.propertyId,
          roomId: roomId,
          category: category,
          description: description.text.trim(),
          amount: double.parse(amount.text),
          expenseDate: DateTime.now());
      if (mounted)
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Expense recorded')));
    }
    description.dispose();
    amount.dispose();
  }

  Future<void> _addMaintenance() async {
    final title = TextEditingController();
    final description = TextEditingController();
    String priority = 'normal';
    String? roomId;
    final saved = await showModalBottomSheet<bool>(
        context: context,
        isScrollControlled: true,
        builder: (ctx) => StatefulBuilder(
            builder: (ctx, setLocal) => Padding(
                  padding: EdgeInsets.fromLTRB(
                      20, 20, 20, MediaQuery.viewInsetsOf(ctx).bottom + 20),
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    Text('New maintenance request',
                        style: Theme.of(ctx).textTheme.titleLarge),
                    const SizedBox(height: 16),
                    TextField(
                        controller: title,
                        decoration:
                            const InputDecoration(labelText: 'Issue title')),
                    const SizedBox(height: 10),
                    TextField(
                        controller: description,
                        minLines: 2,
                        maxLines: 4,
                        decoration:
                            const InputDecoration(labelText: 'Description')),
                    const SizedBox(height: 10),
                    Row(children: [
                      Expanded(
                          child: DropdownButtonFormField<String?>(
                              value: roomId,
                              decoration:
                                  const InputDecoration(labelText: 'Unit'),
                              items: [
                                const DropdownMenuItem<String?>(
                                    value: null, child: Text('Property')),
                                ..._units.map((u) => DropdownMenuItem<String?>(
                                    value: u.id, child: Text(u.number)))
                              ],
                              onChanged: (v) => setLocal(() => roomId = v))),
                      const SizedBox(width: 10),
                      Expanded(
                          child: DropdownButtonFormField(
                              value: priority,
                              decoration:
                                  const InputDecoration(labelText: 'Priority'),
                              items: const ['low', 'normal', 'high', 'urgent']
                                  .map((e) => DropdownMenuItem(
                                      value: e, child: Text(_label(e))))
                                  .toList(),
                              onChanged: (v) => setLocal(() => priority = v!)))
                    ]),
                    const SizedBox(height: 18),
                    SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                            onPressed: () => Navigator.pop(ctx, true),
                            child: const Text('Create request'))),
                  ]),
                )));
    if (saved == true && title.text.trim().isNotEmpty) {
      await ManagementApi.addMaintenance(
          propertyId: widget.propertyId,
          roomId: roomId,
          title: title.text.trim(),
          description: description.text.trim(),
          priority: priority);
      await _load();
    }
    title.dispose();
    description.dispose();
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

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
            title:
                Text(widget.unit == null ? 'Add room or flat' : 'Edit unit')),
        body: Form(
            key: _form,
            child: ListView(padding: const EdgeInsets.all(16), children: [
              Row(children: [
                Expanded(
                    child: DropdownButtonFormField(
                        value: _kind,
                        decoration:
                            const InputDecoration(labelText: 'Unit kind'),
                        items: const [
                          'room',
                          'flat',
                          'apartment',
                          'shop',
                          'office',
                          'other'
                        ]
                            .map((e) =>
                                DropdownMenuItem(value: e, child: Text(e)))
                            .toList(),
                        onChanged: (v) => setState(() => _kind = v!))),
                const SizedBox(width: 10),
                Expanded(
                    child: TextFormField(
                        controller: _number,
                        decoration: const InputDecoration(
                            labelText: 'Unit number/name'),
                        validator: _required))
              ]),
              const SizedBox(height: 12),
              DropdownButtonFormField(
                  value: _type,
                  decoration: const InputDecoration(labelText: 'Room layout'),
                  items: const [
                    'single',
                    'double',
                    'shared',
                    'master',
                    'deluxe'
                  ]
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (v) => setState(() => _type = v!)),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(
                    child: TextFormField(
                        controller: _rent,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                            labelText: 'Monthly rent', prefixText: 'NPR '),
                        validator: _required)),
                const SizedBox(width: 10),
                Expanded(
                    child: TextFormField(
                        controller: _deposit,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                            labelText: 'Deposit', prefixText: 'NPR '),
                        validator: _required))
              ]),
              const SizedBox(height: 12),
              DropdownButtonFormField<int>(
                  value: _dueDay,
                  decoration:
                      const InputDecoration(labelText: 'Rent due each month'),
                  items: List.generate(
                      28,
                      (i) => DropdownMenuItem(
                          value: i + 1, child: Text('Day ${i + 1}'))),
                  onChanged: (v) => setState(() => _dueDay = v!)),
              const SizedBox(height: 12),
              TextFormField(
                  controller: _description,
                  minLines: 3,
                  maxLines: 5,
                  decoration: const InputDecoration(labelText: 'Description'),
                  validator: _required),
              const SizedBox(height: 12),
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
              const SizedBox(height: 22),
              FilledButton.icon(
                  onPressed: _saving ? null : _save,
                  icon: const Icon(Icons.save_outlined),
                  label: Text(_saving ? 'Saving…' : 'Save unit')),
            ])),
      );

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    final rent = double.tryParse(_rent.text);
    final deposit = double.tryParse(_deposit.text);
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

class TenantEditorSheet extends StatefulWidget {
  const TenantEditorSheet(
      {super.key, required this.propertyId, required this.unit});
  final String propertyId;
  final ManagedUnit unit;

  @override
  State<TenantEditorSheet> createState() => _TenantEditorSheetState();
}

class _TenantEditorSheetState extends State<TenantEditorSheet> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _email = TextEditingController();
  final _emergency = TextEditingController();
  final _notes = TextEditingController();
  late final TextEditingController _rent;
  late final TextEditingController _deposit;
  DateTime _start = DateTime.now();
  DateTime? _end;
  late int _dueDay;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _rent = TextEditingController(text: widget.unit.rent.toStringAsFixed(0));
    _deposit =
        TextEditingController(text: widget.unit.deposit.toStringAsFixed(0));
    _dueDay = widget.unit.rentDueDay;
  }

  @override
  void dispose() {
    for (final c in [
      _name,
      _phone,
      _email,
      _emergency,
      _notes,
      _rent,
      _deposit
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  String? _required(String? v) =>
      v == null || v.trim().isEmpty ? 'Required' : null;

  @override
  Widget build(BuildContext context) => Padding(
        padding: EdgeInsets.fromLTRB(
            18, 12, 18, MediaQuery.viewInsetsOf(context).bottom + 18),
        child: Form(
            key: _form,
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
                              color: Colors.grey,
                              borderRadius: BorderRadius.circular(4)))),
                  const SizedBox(height: 16),
                  Text('Assign tenant to ${widget.unit.number}',
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  TextFormField(
                      controller: _name,
                      decoration:
                          const InputDecoration(labelText: 'Tenant full name'),
                      validator: _required),
                  const SizedBox(height: 10),
                  Row(children: [
                    Expanded(
                        child: TextFormField(
                            controller: _phone,
                            keyboardType: TextInputType.phone,
                            decoration:
                                const InputDecoration(labelText: 'Phone'),
                            validator: _required)),
                    const SizedBox(width: 10),
                    Expanded(
                        child: TextFormField(
                            controller: _email,
                            keyboardType: TextInputType.emailAddress,
                            decoration: const InputDecoration(
                                labelText: 'Email (optional)')))
                  ]),
                  const SizedBox(height: 10),
                  TextFormField(
                      controller: _emergency,
                      decoration: const InputDecoration(
                          labelText: 'Emergency contact')),
                  const SizedBox(height: 10),
                  Row(children: [
                    Expanded(
                        child: TextFormField(
                            controller: _rent,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                                labelText: 'Monthly rent', prefixText: 'NPR '),
                            validator: _required)),
                    const SizedBox(width: 10),
                    Expanded(
                        child: TextFormField(
                            controller: _deposit,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                                labelText: 'Deposit', prefixText: 'NPR '),
                            validator: _required))
                  ]),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<int>(
                      value: _dueDay,
                      decoration:
                          const InputDecoration(labelText: 'Monthly due date'),
                      items: List.generate(
                          28,
                          (i) => DropdownMenuItem(
                              value: i + 1, child: Text('Day ${i + 1}'))),
                      onChanged: (v) => setState(() => _dueDay = v!)),
                  const SizedBox(height: 10),
                  Row(children: [
                    Expanded(
                        child: OutlinedButton.icon(
                            onPressed: () => _pickDate(true),
                            icon: const Icon(Icons.event),
                            label: Text(
                                'Starts ${DateFormat.yMMMd().format(_start)}'))),
                    const SizedBox(width: 8),
                    Expanded(
                        child: OutlinedButton.icon(
                            onPressed: () => _pickDate(false),
                            icon: const Icon(Icons.event_available),
                            label: Text(_end == null
                                ? 'No end date'
                                : 'Ends ${DateFormat.yMMMd().format(_end!)}')))
                  ]),
                  const SizedBox(height: 10),
                  TextFormField(
                      controller: _notes,
                      minLines: 2,
                      maxLines: 3,
                      decoration:
                          const InputDecoration(labelText: 'Agreement notes')),
                  const SizedBox(height: 18),
                  SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                          onPressed: _saving ? null : _save,
                          icon: const Icon(Icons.person_add_alt),
                          label: Text(_saving
                              ? 'Assigning…'
                              : 'Assign tenant & create rent schedule'))),
                ]))),
      );

  Future<void> _pickDate(bool start) async {
    final date = await showDatePicker(
        context: context,
        firstDate: DateTime(2020),
        lastDate: DateTime(2040),
        initialDate:
            start ? _start : (_end ?? _start.add(const Duration(days: 365))));
    if (date != null)
      setState(() {
        if (start) {
          _start = date;
        } else {
          _end = date;
        }
      });
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      await ManagementApi.assignTenant(
          propertyId: widget.propertyId,
          roomId: widget.unit.id,
          values: {
            'tenant_name': _name.text.trim(),
            'tenant_phone': _phone.text.trim(),
            'tenant_email':
                _email.text.trim().isEmpty ? null : _email.text.trim(),
            'emergency_contact': _emergency.text.trim(),
            'lease_start': _start.toIso8601String().split('T').first,
            'lease_end': _end?.toIso8601String().split('T').first,
            'monthly_rent': double.parse(_rent.text),
            'security_deposit': double.parse(_deposit.text),
            'rent_due_day': _dueDay,
            'notes': _notes.text.trim(),
          });
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Could not assign tenant: $e')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}
