import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:omspos/screen/management/api/management_api.dart';

class TenantMaintenanceScreen extends StatefulWidget {
  const TenantMaintenanceScreen({super.key});

  @override
  State<TenantMaintenanceScreen> createState() =>
      _TenantMaintenanceScreenState();
}

class _TenantMaintenanceScreenState extends State<TenantMaintenanceScreen> {
  bool _loading = true;
  String? _error;
  List<Map<String, dynamic>> _tenancies = const [];
  List<Map<String, dynamic>> _requests = const [];

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
        ManagementApi.getTenantTenancies(),
        ManagementApi.getTenantMaintenance(),
      ]);
      if (!mounted) return;
      setState(() {
        _tenancies = result[0];
        _requests = result[1];
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error.toString();
        _loading = false;
      });
    }
  }

  String _label(String value) => value
      .replaceAll('_', ' ')
      .split(' ')
      .map((part) => part.isEmpty
          ? part
          : '${part[0].toUpperCase()}${part.substring(1)}')
      .join(' ');

  Color _statusColor(String status) => switch (status) {
        'resolved' => Colors.green,
        'in_progress' => Colors.blue,
        'cancelled' => Colors.grey,
        _ => Colors.orange,
      };

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('Maintenance'),
          actions: [
            IconButton(onPressed: _load, icon: const Icon(Icons.refresh)),
          ],
        ),
        floatingActionButton: _tenancies.isEmpty
            ? null
            : FloatingActionButton.extended(
                onPressed: _createRequest,
                icon: const Icon(Icons.add),
                label: const Text('New request'),
              ),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(mainAxisSize: MainAxisSize.min, children: [
                        const Icon(Icons.error_outline, size: 44),
                        const SizedBox(height: 12),
                        Text(_error!, textAlign: TextAlign.center),
                        const SizedBox(height: 16),
                        FilledButton(onPressed: _load, child: const Text('Retry')),
                      ]),
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _load,
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
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
                          child: const Row(children: [
                            CircleAvatar(child: Icon(Icons.home_repair_service)),
                            SizedBox(width: 14),
                            Expanded(
                              child: Text(
                                'Report an issue in your rented unit and follow its progress here.',
                              ),
                            ),
                          ]),
                        ),
                        const SizedBox(height: 20),
                        if (_tenancies.isEmpty)
                          const Card(
                            child: Padding(
                              padding: EdgeInsets.all(24),
                              child: Column(children: [
                                Icon(Icons.link_off_outlined, size: 46),
                                SizedBox(height: 10),
                                Text('No active rental is linked to this account.'),
                                SizedBox(height: 6),
                                Text(
                                  'Ask your owner to assign the unit using the email address on this account.',
                                  textAlign: TextAlign.center,
                                ),
                              ]),
                            ),
                          )
                        else if (_requests.isEmpty)
                          const Card(
                            child: Padding(
                              padding: EdgeInsets.all(24),
                              child: Column(children: [
                                Icon(Icons.task_alt, size: 46, color: Colors.green),
                                SizedBox(height: 10),
                                Text('No maintenance requests yet.'),
                              ]),
                            ),
                          )
                        else
                          ..._requests.map(_requestCard),
                      ],
                    ),
                  ),
      );

  Widget _requestCard(Map<String, dynamic> request) {
    final status = request['status']?.toString() ?? 'open';
    final color = _statusColor(status);
    final property = request['properties'] as Map<String, dynamic>?;
    final room = request['rooms'] as Map<String, dynamic>?;
    final reported =
        DateTime.tryParse(request['reported_at']?.toString() ?? '');
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            CircleAvatar(
              backgroundColor: color.withValues(alpha: .14),
              child: Icon(Icons.build_outlined, color: color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(request['title']?.toString() ?? 'Maintenance issue',
                  style: const TextStyle(fontWeight: FontWeight.w700)),
            ),
            Chip(
              label: Text(_label(status)),
              side: BorderSide.none,
              backgroundColor: color.withValues(alpha: .14),
            ),
          ]),
          if (request['description']?.toString().isNotEmpty == true) ...[
            const SizedBox(height: 10),
            Text(request['description'].toString()),
          ],
          const SizedBox(height: 10),
          Text([
            property?['title']?.toString(),
            if (room != null) 'Unit ${room['room_number']}',
            '${_label(request['priority']?.toString() ?? 'normal')} priority',
            if (reported != null) DateFormat.yMMMd().format(reported),
          ].whereType<String>().join(' • '),
              style: Theme.of(context).textTheme.bodySmall),
        ]),
      ),
    );
  }

  Future<void> _createRequest() async {
    final formKey = GlobalKey<FormState>();
    final title = TextEditingController();
    final description = TextEditingController();
    Map<String, dynamic> tenancy = _tenancies.first;
    String priority = 'normal';
    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (sheetContext) => StatefulBuilder(
        builder: (context, setLocal) => Padding(
          padding: EdgeInsets.fromLTRB(
              20, 16, 20, MediaQuery.viewInsetsOf(context).bottom + 20),
          child: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Text('New maintenance request',
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 18),
                DropdownButtonFormField<Map<String, dynamic>>(
                  value: tenancy,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'Rental unit',
                    prefixIcon: Icon(Icons.meeting_room_outlined),
                  ),
                  items: _tenancies
                      .map((item) => DropdownMenuItem(
                            value: item,
                            child: Text(
                              '${(item['properties'] as Map?)?['title'] ?? 'Property'} • Unit ${(item['rooms'] as Map?)?['room_number'] ?? ''}',
                              overflow: TextOverflow.ellipsis,
                            ),
                          ))
                      .toList(),
                  onChanged: (value) =>
                      setLocal(() => tenancy = value ?? tenancy),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: title,
                  decoration: const InputDecoration(
                    labelText: 'Issue title',
                    prefixIcon: Icon(Icons.report_problem_outlined),
                  ),
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'Enter an issue title'
                      : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: description,
                  minLines: 3,
                  maxLines: 5,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    hintText: 'Explain what is wrong and where it is located',
                    prefixIcon: Icon(Icons.notes_outlined),
                    alignLabelWithHint: true,
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: priority,
                  decoration: const InputDecoration(
                    labelText: 'Priority',
                    prefixIcon: Icon(Icons.priority_high),
                  ),
                  items: const ['low', 'normal', 'high', 'urgent']
                      .map((value) => DropdownMenuItem(
                            value: value,
                            child: Text(_label(value)),
                          ))
                      .toList(),
                  onChanged: (value) =>
                      setLocal(() => priority = value ?? priority),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: FilledButton.icon(
                    onPressed: () {
                      if (formKey.currentState!.validate()) {
                        Navigator.pop(sheetContext, true);
                      }
                    },
                    icon: const Icon(Icons.send_outlined),
                    label: const Text('Submit request'),
                  ),
                ),
              ]),
            ),
          ),
        ),
      ),
    );
    if (saved == true) {
      await ManagementApi.addMaintenance(
        tenancy: tenancy,
        title: title.text.trim(),
        description: description.text.trim(),
        priority: priority,
      );
      await _load();
    }
    title.dispose();
    description.dispose();
  }
}
