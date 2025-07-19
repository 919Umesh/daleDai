import 'package:flutter/material.dart';
import 'package:omspos/screen/properties/state/properties_state.dart';
import 'package:omspos/widgets/no_data_widget.dart';
import 'package:provider/provider.dart';
import 'package:omspos/screen/home/model/property_model.dart';
import 'package:omspos/utils/loading_indicator.dart';

class PropertiesScreen extends StatefulWidget {
  final String? areaId;

  const PropertiesScreen({super.key, this.areaId});

  @override
  State<PropertiesScreen> createState() => _PropertiesScreenState();
}

class _PropertiesScreenState extends State<PropertiesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = Provider.of<PropertiesState>(context, listen: false);
      if (widget.areaId != null) {
        state.loadPropertiesByArea(widget.areaId!);
      } else {
        state.loadAllProperties();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.areaId != null ? 'Properties in Area' : 'All Properties'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => Provider.of<PropertiesState>(context, listen: false)
                .refreshProperties(),
          ),
        ],
      ),
      body: Consumer<PropertiesState>(
        builder: (context, state, child) {
          if (state.isLoading && state.properties.isEmpty) {
            return Center(child: CircularProgressIndicator(),);
          }

          if (state.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error: ${state.errorMessage}'),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => state.refreshProperties(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state.properties.isEmpty) {
            return const NoDataWidget();
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: state.properties.length,
            itemBuilder: (context, index) {
              final property = state.properties[index];
              return _PropertyCard(property: property);
            },
          );
        },
      ),
    );
  }
}

class _PropertyCard extends StatelessWidget {
  final PropertyModel property;

  const _PropertyCard({required this.property});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              property.title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              property.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.location_on,
                  size: 16,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    '${property.address}, ${property.city}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                _PropertyChip(
                  icon: Icons.type_specimen,
                  label: property.propertyType.toUpperCase(),
                ),
                _PropertyChip(
                  icon: Icons.space_dashboard,
                  label: '${property.areaSqft} sqft',
                ),
                _PropertyChip(
                  icon: Icons.calendar_today,
                  label: property.availableFrom != null
                      ? 'Available ${property.availableFrom!.toLocal().toString().split(' ')[0]}'
                      : 'Available Now',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PropertyChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _PropertyChip({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: Icon(
        icon,
        size: 16,
        color: Theme.of(context).primaryColor,
      ),
      label: Text(label),
      backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      labelPadding: const EdgeInsets.symmetric(horizontal: 4),
    );
  }
}