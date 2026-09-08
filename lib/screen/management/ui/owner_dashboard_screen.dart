import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:omspos/screen/management/api/management_api.dart';
import 'package:omspos/screen/management/model/management_models.dart';
import 'package:omspos/screen/management/ui/widget/device_image_picker.dart';
import 'package:omspos/services/images/image_upload_service.dart';
import 'package:omspos/services/location/location_service.dart';
import 'package:omspos/services/router/router_name.dart';

enum OwnerDashboardSection { overview, properties, rent }

class OwnerDashboardScreen extends StatefulWidget {
  const OwnerDashboardScreen({
    super.key,
    this.section = OwnerDashboardSection.overview,
    this.showSectionTabs = true,
  });

  final OwnerDashboardSection section;
  final bool showSectionTabs;

  @override
  State<OwnerDashboardScreen> createState() => _OwnerDashboardScreenState();
}

class _OwnerDashboardScreenState extends State<OwnerDashboardScreen> {
  final _money =
      NumberFormat.currency(locale: 'en_IN', symbol: 'NPR ', decimalDigits: 0);
  bool _loading = true;
  String? _error;
  Map<String, dynamic>? _ownerProfile;
  OwnerMetrics _metrics = const OwnerMetrics();
  List<OwnerProperty> _properties = const [];
  List<RentLedgerItem> _ledger = const [];

  @override
  void initState() {
    super.initState();
    ManagementApi.changes.addListener(_handleManagementChange);
    _load();
  }

  void _handleManagementChange() => _load();

  @override
  void dispose() {
    ManagementApi.changes.removeListener(_handleManagementChange);
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final role = await ManagementApi.getCurrentUserRole();
      if (role != 'landlord' && role != 'admin') {
        throw StateError(
            'Property management is only available to owner accounts.');
      }
      final profile = await ManagementApi.getOwnerProfile();
      if (!mounted) return;
      if (profile == null || profile['onboarding_complete'] != true) {
        setState(() {
          _ownerProfile = profile;
          _loading = false;
        });
        return;
      }
      final results = await Future.wait([
        ManagementApi.getMetrics(),
        ManagementApi.getProperties(),
        ManagementApi.getRentLedger(),
      ]);
      if (!mounted) return;
      setState(() {
        _ownerProfile = profile;
        _metrics = results[0] as OwnerMetrics;
        _properties = results[1] as List<OwnerProperty>;
        _ledger = results[2] as List<RentLedgerItem>;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _openPropertyEditor([String? propertyId]) async {
    final changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
          builder: (_) => PropertyEditorScreen(propertyId: propertyId)),
    );
    if (changed == true) _load();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Property management')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.cloud_off_outlined, size: 48),
              const SizedBox(height: 12),
              Text(_error!, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              FilledButton.icon(
                  onPressed: _load,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Try again')),
            ]),
          ),
        ),
      );
    }
    if (_ownerProfile == null ||
        _ownerProfile!['onboarding_complete'] != true) {
      return OwnerOnboardingScreen(onComplete: _load);
    }

    if (!widget.showSectionTabs) {
      final title = switch (widget.section) {
        OwnerDashboardSection.overview => 'Owner dashboard',
        OwnerDashboardSection.properties => 'My properties',
        OwnerDashboardSection.rent => 'Rent collection',
      };
      final body = switch (widget.section) {
        OwnerDashboardSection.overview => _overview(),
        OwnerDashboardSection.properties => _propertyList(),
        OwnerDashboardSection.rent => _rentLedger(),
      };
      return Scaffold(
        appBar: AppBar(
          title: Text(title),
          actions: [
            IconButton(
              onPressed: _load,
              icon: const Icon(Icons.refresh),
              tooltip: 'Refresh',
            ),
          ],
        ),
        floatingActionButton: widget.section == OwnerDashboardSection.rent
            ? null
            : Padding(
                // This screen is embedded above IndexScreen's floating nav.
                // Reserve its height so the primary action remains tappable.
                padding: const EdgeInsets.only(bottom: 76),
                child: FloatingActionButton.extended(
                  onPressed: () => _openPropertyEditor(),
                  icon: const Icon(Icons.add_home_work_outlined),
                  label: const Text('Add property'),
                ),
              ),
        body: body,
      );
    }

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(_ownerProfile!['business_name']?.toString() ??
              'Property management'),
          actions: [
            IconButton(
                onPressed: _load,
                icon: const Icon(Icons.refresh),
                tooltip: 'Refresh')
          ],
          bottom: const TabBar(tabs: [
            Tab(text: 'Overview'),
            Tab(text: 'Properties'),
            Tab(text: 'Rent'),
          ]),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _openPropertyEditor(),
          icon: const Icon(Icons.add_home_work_outlined),
          label: const Text('Add property'),
        ),
        body: TabBarView(children: [
          _overview(),
          _propertyList(),
          _rentLedger(),
        ]),
      ),
    );
  }

  Widget _overview() {
    final theme = Theme.of(context);
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        children: [
          Text('Portfolio health',
              style: theme.textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: MediaQuery.sizeOf(context).width > 650 ? 4 : 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 1.35,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            children: [
              _MetricCard('Properties', '${_metrics.properties}',
                  Icons.apartment, theme.colorScheme.primary),
              _MetricCard(
                  'Occupancy',
                  '${(_metrics.occupancyRate * 100).round()}%',
                  Icons.people_alt_outlined,
                  Colors.teal),
              _MetricCard(
                  'Collected',
                  _money.format(_metrics.collectedThisMonth),
                  Icons.payments_outlined,
                  Colors.green),
              _MetricCard('Outstanding', _money.format(_metrics.outstanding),
                  Icons.schedule_outlined, theme.colorScheme.error),
            ],
          ),
          const SizedBox(height: 20),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('This month',
                        style: theme.textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 14),
                    _summaryRow('Potential rent',
                        _money.format(_metrics.monthlyPotential)),
                    _summaryRow('Operating expenses',
                        _money.format(_metrics.expensesThisMonth)),
                    const Divider(height: 24),
                    _summaryRow(
                        'Net cash flow', _money.format(_metrics.netIncome),
                        strong: true),
                  ]),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: CircleAvatar(child: Text('${_metrics.openMaintenance}')),
              title: const Text('Open maintenance requests'),
              subtitle: const Text('Review maintenance inside each property'),
              trailing: const Icon(Icons.chevron_right),
            ),
          ),
          if (_metrics.units == 0) ...[
            const SizedBox(height: 24),
            const Icon(Icons.domain_add_outlined, size: 56),
            const SizedBox(height: 10),
            const Text(
                'Add your first property, then create rooms or flats inside it.',
                textAlign: TextAlign.center),
          ],
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value, {bool strong = false}) =>
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child:
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(label),
          Text(value,
              style: TextStyle(
                  fontWeight: strong ? FontWeight.w800 : FontWeight.w600)),
        ]),
      );

  Widget _propertyList() => RefreshIndicator(
        onRefresh: _load,
        child: _properties.isEmpty
            ? ListView(children: const [
                SizedBox(height: 140),
                Icon(Icons.home_work_outlined, size: 64),
                SizedBox(height: 12),
                Text('No properties yet', textAlign: TextAlign.center)
              ])
            : ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                itemCount: _properties.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (_, index) {
                  final property = _properties[index];
                  return Card(
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () => context
                          .push(managePropertyPath, extra: property.id)
                          .then((_) => _load()),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(children: [
                                Expanded(
                                    child: Text(property.title,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium
                                            ?.copyWith(
                                                fontWeight: FontWeight.bold))),
                                PopupMenuButton<String>(
                                  onSelected: (value) {
                                    if (value == 'edit') {
                                      _openPropertyEditor(property.id);
                                    }
                                  },
                                  itemBuilder: (_) => const [
                                    PopupMenuItem(
                                        value: 'edit',
                                        child: Text('Edit property'))
                                  ],
                                ),
                              ]),
                              Text('${property.address}, ${property.city}',
                                  style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurfaceVariant)),
                              const SizedBox(height: 14),
                              Wrap(spacing: 8, runSpacing: 8, children: [
                                Chip(
                                    label: Text('${property.unitCount} units')),
                                Chip(
                                    label: Text(
                                        '${property.occupiedCount} occupied')),
                                Chip(
                                    label:
                                        Text('${property.vacantCount} vacant')),
                              ]),
                              const SizedBox(height: 8),
                              Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                        '${_money.format(property.monthlyPotential)}/month',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w700)),
                                    const Icon(Icons.chevron_right),
                                  ]),
                            ]),
                      ),
                    ),
                  );
                },
              ),
      );

  Widget _rentLedger() {
    final items = _ledger
        .where((item) => item.status != 'paid' && item.status != 'waived')
        .toList();
    return RefreshIndicator(
      onRefresh: _load,
      child: items.isEmpty
          ? ListView(children: const [
              SizedBox(height: 140),
              Icon(Icons.receipt_long_outlined, size: 64),
              SizedBox(height: 12),
              Text('No outstanding rent', textAlign: TextAlign.center)
            ])
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (_, index) {
                final item = items[index];
                final overdue =
                    item.dueDate.isBefore(DateTime.now()) && item.balance > 0;
                return Card(
                    child: ListTile(
                  leading: CircleAvatar(
                      backgroundColor: overdue
                          ? Theme.of(context).colorScheme.errorContainer
                          : null,
                      child: const Icon(Icons.currency_rupee)),
                  title: Text('${item.tenantName} • ${item.unitNumber}'),
                  subtitle: Text(
                      '${overdue ? 'Overdue' : 'Due'} ${DateFormat.yMMMd().format(item.dueDate)}\nBalance ${_money.format(item.balance)}'),
                  isThreeLine: true,
                  trailing: item.balance <= 0
                      ? const Icon(Icons.check_circle, color: Colors.green)
                      : FilledButton(
                          onPressed: () => _recordPayment(item),
                          child: const Text('Paid')),
                ));
              },
            ),
    );
  }

  Future<void> _recordPayment(RentLedgerItem item) async {
    final controller =
        TextEditingController(text: item.balance.toStringAsFixed(0));
    final amount = await showDialog<double>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Record rent payment'),
        content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
                labelText: 'Amount received', prefixText: 'NPR ')),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
              onPressed: () =>
                  Navigator.pop(ctx, double.tryParse(controller.text)),
              child: const Text('Record')),
        ],
      ),
    );
    if (amount == null || amount <= 0) return;
    try {
      await ManagementApi.markRentPaid(item.id, amount);
      await _load();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Could not record payment: $e')));
      }
    }
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard(this.label, this.value, this.icon, this.color);
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) => Card(
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: color),
                FittedBox(
                    child: Text(value,
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge
                            ?.copyWith(fontWeight: FontWeight.w800))),
                Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
              ]),
        ),
      );
}

class OwnerOnboardingScreen extends StatefulWidget {
  const OwnerOnboardingScreen({super.key, required this.onComplete});
  final Future<void> Function() onComplete;

  @override
  State<OwnerOnboardingScreen> createState() => _OwnerOnboardingScreenState();
}

class _OwnerOnboardingScreenState extends State<OwnerOnboardingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _business = TextEditingController();
  final _phone = TextEditingController();
  final _address = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _business.dispose();
    _phone.dispose();
    _address.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Complete owner profile')),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Icon(Icons.real_estate_agent_outlined,
                  size: 64, color: Theme.of(context).colorScheme.primary),
              const SizedBox(height: 18),
              Text('Manage every unit in one place',
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall
                      ?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text(
                  'List properties, manage rooms and flats, track tenants, rent, expenses, and maintenance.'),
              const SizedBox(height: 24),
              TextFormField(
                  controller: _business,
                  decoration: const InputDecoration(
                      labelText: 'Business or owner name',
                      prefixIcon: Icon(Icons.business_outlined)),
                  validator: _required),
              const SizedBox(height: 12),
              TextFormField(
                  controller: _phone,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                      labelText: 'Contact phone',
                      prefixIcon: Icon(Icons.phone_outlined))),
              const SizedBox(height: 12),
              TextFormField(
                  controller: _address,
                  decoration: const InputDecoration(
                      labelText: 'Business address',
                      prefixIcon: Icon(Icons.location_on_outlined))),
              const SizedBox(height: 24),
              SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _saving ? null : _submit,
                    icon: _saving
                        ? const SizedBox.square(
                            dimension: 18,
                            child: CircularProgressIndicator(strokeWidth: 2))
                        : const Icon(Icons.arrow_forward),
                    label: const Text('Start managing properties'),
                  )),
            ]),
          ),
        ),
      );

  String? _required(String? value) =>
      value == null || value.trim().isEmpty ? 'Required' : null;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      await ManagementApi.registerOwner(
          businessName: _business.text,
          phone: _phone.text,
          address: _address.text);
      await widget.onComplete();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Registration failed: $e')));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}

class PropertyEditorScreen extends StatefulWidget {
  const PropertyEditorScreen({super.key, this.propertyId});
  final String? propertyId;

  @override
  State<PropertyEditorScreen> createState() => _PropertyEditorScreenState();
}

class _PropertyEditorScreenState extends State<PropertyEditorScreen> {
  static const _provinces = [
    'Koshi',
    'Madhesh',
    'Bagmati',
    'Gandaki',
    'Lumbini',
    'Karnali',
    'Sudurpashchim',
  ];
  static const _amenities = [
    'WiFi',
    'Parking',
    'Hot Water',
    'CCTV',
    '24hr Security',
    'Backup Power',
    'Garden',
    'Balcony',
    'Rooftop',
    'Elevator',
    'Gym',
    'Laundry',
  ];

  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _description = TextEditingController();
  final _address = TextEditingController();
  final _city = TextEditingController();
  final _state = TextEditingController(text: 'Bagmati');
  final _areaSqft = TextEditingController();
  double? _latitude;
  double? _longitude;
  List<XFile> _selectedImages = const [];
  List<String> _existingImages = const [];
  final List<String> _removedImages = [];
  final Set<String> _selectedAmenities = {};
  List<Map<String, dynamic>> _areas = const [];
  String? _areaId;
  String _type = 'apartment';
  String _furnishing = 'unfurnished';
  bool _active = true;
  bool _loading = true;
  bool _saving = false;
  bool _locating = false;
  String? _locationError;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      _areas = await ManagementApi.getAreas();
      _areaId = _areas.isEmpty ? null : _areas.first['area_id'].toString();
      if (widget.propertyId != null) {
        final row = await ManagementApi.getProperty(widget.propertyId!);
        _title.text = row['title']?.toString() ?? '';
        _description.text = row['description']?.toString() ?? '';
        _address.text = row['address']?.toString() ?? '';
        _city.text = row['city']?.toString() ?? '';
        _state.text = row['state']?.toString() ?? '';
        _areaSqft.text = row['area_sqft']?.toString() ?? '';
        _latitude = _asDouble(row['latitude']);
        _longitude = _asDouble(row['longitude']);
        _areaId = row['area_id']?.toString();
        _type = row['property_type']?.toString() ?? _type;
        _furnishing = _normalizeFurnishing(
          row['furnishing_status']?.toString() ?? _furnishing,
        );
        _active = row['is_active'] as bool? ?? true;
        _existingImages = List<String>.from(row['images'] as List? ?? const []);
        _selectedAmenities
          ..clear()
          ..addAll(List<String>.from(row['attributes'] as List? ?? const []));
      } else {
        final position = await LocationService.getCurrentLocation();
        _latitude = position?.latitude;
        _longitude = position?.longitude;
        if (position == null) {
          _locationError = 'Turn on location and allow access, then try again.';
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Could not load form: $e')));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    for (final c in [
      _title,
      _description,
      _address,
      _city,
      _state,
      _areaSqft,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  String? _required(String? value) =>
      value == null || value.trim().isEmpty ? 'Required' : null;

  double? _asDouble(dynamic value) => value is num
      ? value.toDouble()
      : double.tryParse(value?.toString() ?? '');

  Future<bool> _captureLocation() async {
    if (_locating) return false;
    setState(() {
      _locating = true;
      _locationError = null;
    });
    final position =
        await LocationService.getCurrentLocation(forceRefresh: true);
    if (!mounted) return position != null;
    setState(() {
      _locating = false;
      _latitude = position?.latitude;
      _longitude = position?.longitude;
      if (position == null) {
        _locationError = 'Turn on location and allow access, then try again.';
      }
    });
    return position != null;
  }

  Widget _editorIntro() {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colors.primaryContainer.withValues(alpha: .55),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 25,
            backgroundColor: colors.primary,
            foregroundColor: colors.onPrimary,
            child: Icon(widget.propertyId == null
                ? Icons.add_home_work_outlined
                : Icons.edit_location_alt_outlined),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.propertyId == null
                      ? 'List a new property'
                      : 'Update property',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text(
                  'Add clear details and photos to help renters find the right place.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(IconData icon, String title) => Padding(
        padding: const EdgeInsets.only(left: 4, bottom: 10),
        child: Row(
          children: [
            Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 8),
            Text(
              title,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
          ],
        ),
      );

  Widget _formCard(List<Widget> children) => Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(children: children),
        ),
      );

  Widget _locationCard() {
    final colors = Theme.of(context).colorScheme;
    final hasLocation = _latitude != null && _longitude != null;
    final color = hasLocation ? colors.primary : colors.error;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .09),
        border: Border.all(color: color.withValues(alpha: .3)),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          _locating
              ? const SizedBox.square(
                  dimension: 24,
                  child: CircularProgressIndicator(strokeWidth: 2.5),
                )
              : Icon(
                  hasLocation
                      ? Icons.my_location_rounded
                      : Icons.location_off_outlined,
                  color: color,
                ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _locating
                      ? 'Getting device location…'
                      : hasLocation
                          ? 'Map location captured'
                          : 'Location is required',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 2),
                Text(
                  hasLocation
                      ? 'Automatically taken from this device'
                      : (_locationError ?? 'Allow location access to continue'),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          TextButton.icon(
            onPressed: _locating ? null : _captureLocation,
            icon: const Icon(Icons.refresh, size: 18),
            label: Text(hasLocation ? 'Refresh' : 'Retry'),
          ),
        ],
      ),
    );
  }

  String _normalizeFurnishing(String value) => switch (value) {
        'semi-furnished' => 'semi_furnished',
        'fully-furnished' => 'furnished',
        _ => value,
      };

  String _displayLabel(String value) => value
      .replaceAll('_', '-')
      .split('-')
      .map((part) =>
          part.isEmpty ? part : '${part[0].toUpperCase()}${part.substring(1)}')
      .join(' ');

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
            title: Text(
                widget.propertyId == null ? 'Add property' : 'Edit property')),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                  children: [
                    _editorIntro(),
                    const SizedBox(height: 20),
                    _sectionTitle(Icons.home_work_outlined, 'Property details'),
                    _formCard([
                      TextFormField(
                        controller: _title,
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(
                          labelText: 'Property name',
                          prefixIcon: Icon(Icons.apartment_outlined),
                        ),
                        validator: _required,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _description,
                        decoration: const InputDecoration(
                          labelText: 'Description',
                          hintText: 'Describe what makes this property special',
                          prefixIcon: Icon(Icons.notes_outlined),
                          alignLabelWithHint: true,
                        ),
                        minLines: 3,
                        maxLines: 5,
                        validator: _required,
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        initialValue: _type,
                        isExpanded: true,
                        decoration: const InputDecoration(
                          labelText: 'Property type',
                          prefixIcon: Icon(Icons.domain_outlined),
                        ),
                        items: const [
                          'apartment',
                          'house',
                          'room',
                          'pg',
                        ]
                            .map((e) => DropdownMenuItem(
                                  value: e,
                                  child: Text(
                                    _displayLabel(e),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ))
                            .toList(),
                        onChanged: (v) => setState(() => _type = v!),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        initialValue: _furnishing,
                        isExpanded: true,
                        decoration: const InputDecoration(
                          labelText: 'Furnishing',
                          prefixIcon: Icon(Icons.chair_outlined),
                        ),
                        items: const [
                          'unfurnished',
                          'semi_furnished',
                          'furnished'
                        ]
                            .map((e) => DropdownMenuItem(
                                  value: e,
                                  child: Text(
                                    _displayLabel(e),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ))
                            .toList(),
                        onChanged: (v) => setState(() => _furnishing = v!),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _areaSqft,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Area (sq ft)',
                          prefixIcon: Icon(Icons.square_foot_outlined),
                        ),
                      ),
                    ]),
                    const SizedBox(height: 20),
                    _sectionTitle(Icons.location_on_outlined, 'Address & map'),
                    _formCard([
                      TextFormField(
                        controller: _address,
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(
                          labelText: 'Street address',
                          prefixIcon: Icon(Icons.signpost_outlined),
                        ),
                        validator: _required,
                      ),
                      const SizedBox(height: 12),
                      Row(children: [
                        Expanded(
                          child: TextFormField(
                            controller: _city,
                            decoration: const InputDecoration(
                              labelText: 'City',
                              prefixIcon: Icon(Icons.location_city_outlined),
                            ),
                            validator: _required,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            initialValue: _provinces.contains(_state.text)
                                ? _state.text
                                : null,
                            isExpanded: true,
                            decoration: const InputDecoration(
                              labelText: 'Province',
                            ),
                            items: _provinces
                                .map((province) => DropdownMenuItem(
                                      value: province,
                                      child: Text(
                                        province,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ))
                                .toList(),
                            onChanged: (province) {
                              if (province != null) {
                                _state.text = province;
                              }
                            },
                            validator: (province) =>
                                province == null ? 'Select a province' : null,
                          ),
                        ),
                      ]),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        initialValue: _areas
                                .any((a) => a['area_id'].toString() == _areaId)
                            ? _areaId
                            : null,
                        decoration: const InputDecoration(
                          labelText: 'Marketplace area',
                          prefixIcon: Icon(Icons.map_outlined),
                        ),
                        items: _areas
                            .map((a) => DropdownMenuItem(
                                  value: a['area_id'].toString(),
                                  child: Text(a['name'].toString()),
                                ))
                            .toList(),
                        onChanged: (v) => setState(() => _areaId = v),
                        validator: (v) => v == null ? 'Select an area' : null,
                      ),
                      const SizedBox(height: 12),
                      _locationCard(),
                    ]),
                    const SizedBox(height: 20),
                    _sectionTitle(Icons.auto_awesome_outlined, 'What we offer'),
                    _formCard([
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Select every amenity available at this property.',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _amenities.map((amenity) {
                            final selected =
                                _selectedAmenities.contains(amenity);
                            return FilterChip(
                              selected: selected,
                              label: Text(amenity),
                              avatar: selected
                                  ? const Icon(Icons.check, size: 18)
                                  : null,
                              onSelected: (value) => setState(() {
                                if (value) {
                                  _selectedAmenities.add(amenity);
                                } else {
                                  _selectedAmenities.remove(amenity);
                                }
                              }),
                            );
                          }).toList(),
                        ),
                      ),
                    ]),
                    const SizedBox(height: 20),
                    _sectionTitle(Icons.photo_library_outlined, 'Photos'),
                    _formCard([
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
                    const SizedBox(height: 16),
                    Card(
                      child: SwitchListTile(
                        secondary: const Icon(Icons.visibility_outlined),
                        title: const Text('Visible in marketplace'),
                        subtitle: const Text(
                            'Renters can discover this property immediately'),
                        value: _active,
                        onChanged: (v) => setState(() => _active = v),
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      height: 52,
                      child: FilledButton.icon(
                        onPressed: _saving || _locating ? null : _save,
                        icon: _saving
                            ? const SizedBox.square(
                                dimension: 18,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.check_circle_outline),
                        label: Text(
                            _saving ? 'Saving property…' : 'Save property'),
                      ),
                    ),
                  ],
                ),
              ),
      );

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_latitude == null || _longitude == null) {
      final captured = await _captureLocation();
      if (!mounted) return;
      if (!captured) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Location is required. Enable location access and try again.'),
          ),
        );
        return;
      }
    }
    if (_existingImages.isEmpty && _selectedImages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add at least one property photo.')),
      );
      return;
    }
    setState(() => _saving = true);
    try {
      final propertyId = await ManagementApi.saveProperty(
          propertyId: widget.propertyId,
          values: {
            'title': _title.text.trim(),
            'description': _description.text.trim(),
            'address': _address.text.trim(),
            'city': _city.text.trim(),
            'state': _state.text.trim(),
            'latitude': _latitude,
            'longitude': _longitude,
            'property_type': _type,
            'furnishing_status': _furnishing,
            'area_sqft': int.tryParse(_areaSqft.text),
            'area_id': _areaId,
            'attributes': _selectedAmenities.toList(),
            'is_active': _active,
          });
      final uploaded = await ImageUploadService.uploadAsWebp(
        bucket: 'properties',
        entityId: propertyId,
        files: _selectedImages,
      );
      await ManagementApi.replacePropertyImages(
        propertyId,
        [..._existingImages, ...uploaded],
      );
      await ImageUploadService.deleteOwnedUrls(
        bucket: 'properties',
        urls: _removedImages,
      );
      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Could not save property: $e')));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}
