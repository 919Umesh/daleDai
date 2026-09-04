import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:omspos/screen/room/model/room_model_images.dart';
import 'package:omspos/screen/room/ui/booking_bottom_sheet.dart';
import 'package:omspos/services/language/translation_extension.dart';

class RoomDetailsContainer extends StatefulWidget {
  final RoomModelImage room;

  const RoomDetailsContainer({super.key, required this.room});

  @override
  State<RoomDetailsContainer> createState() => _RoomDetailsContainerState();
}

class _RoomDetailsContainerState extends State<RoomDetailsContainer> {
  bool _isExpanded = false;

  String _money(double value) =>
      NumberFormat.decimalPattern('en_IN').format(value.round());

  String get _availability {
    final room = widget.room;
    if (room.isOccupied) return 'Currently occupied';
    if (room.availableFrom == null ||
        !room.availableFrom!.isAfter(DateTime.now())) {
      return 'Available now';
    }
    return 'Available ${DateFormat('MMM d, yyyy').format(room.availableFrom!)}';
  }

  @override
  Widget build(BuildContext context) {
    final room = widget.room;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${_unitLabel(room.unitKind)} ${room.roomNumber}',
                    style: theme.textTheme.headlineSmall
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    room.roomType.replaceAll('-', ' ').toUpperCase(),
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: scheme.primary,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
            ),
            _AvailabilityBadge(isOccupied: room.isOccupied),
          ],
        ),
        const SizedBox(height: 18),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: scheme.primaryContainer.withValues(alpha: 0.55),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Row(
            children: [
              Expanded(
                child: _PriceItem(
                  label: 'Monthly rent',
                  value: 'NPR ${_money(room.rentAmount)}',
                  icon: Icons.calendar_month_outlined,
                ),
              ),
              SizedBox(
                height: 48,
                child: VerticalDivider(color: scheme.outlineVariant),
              ),
              Expanded(
                child: _PriceItem(
                  label: 'Security deposit',
                  value: 'NPR ${_money(room.securityDeposit)}',
                  icon: Icons.account_balance_wallet_outlined,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 22),
        const _SectionTitle(
          icon: Icons.info_outline,
          title: 'About this room',
        ),
        const SizedBox(height: 8),
        Text(
          room.description.trim().isEmpty
              ? 'No description has been provided for this room.'
              : room.description.trim(),
          style: theme.textTheme.bodyMedium?.copyWith(height: 1.55),
          maxLines: _isExpanded ? null : 4,
          overflow: _isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
        ),
        if (room.description.trim().length > 160)
          TextButton(
            onPressed: () => setState(() => _isExpanded = !_isExpanded),
            child: Text(
              _isExpanded
                  ? context.translate('see_less')
                  : context.translate('see_more'),
            ),
          ),
        const SizedBox(height: 18),
        const _SectionTitle(
          icon: Icons.grid_view_rounded,
          title: 'Room at a glance',
        ),
        const SizedBox(height: 10),
        LayoutBuilder(
          builder: (context, constraints) {
            final width = (constraints.maxWidth - 10) / 2;
            return Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _FactTile(
                  width: width,
                  icon: Icons.people_outline,
                  label: 'Capacity',
                  value:
                      '${room.maxOccupants} ${room.maxOccupants == 1 ? 'person' : 'people'}',
                ),
                _FactTile(
                  width: width,
                  icon: Icons.event_available_outlined,
                  label: 'Availability',
                  value: _availability,
                ),
                if (room.areaSqft != null)
                  _FactTile(
                    width: width,
                    icon: Icons.square_foot_outlined,
                    label: 'Room area',
                    value: '${room.areaSqft} sq ft',
                  ),
                if (room.floorNumber != null)
                  _FactTile(
                    width: width,
                    icon: Icons.stairs_outlined,
                    label: 'Floor',
                    value: _ordinalFloor(room.floorNumber!),
                  ),
                if ((room.furnishingStatus ?? '').isNotEmpty)
                  _FactTile(
                    width: width,
                    icon: Icons.chair_outlined,
                    label: 'Furnishing',
                    value: room.furnishingStatus!,
                  ),
                _FactTile(
                  width: width,
                  icon: Icons.bathtub_outlined,
                  label: 'Bathroom',
                  value: room.hasAttachedBathroom
                      ? 'Attached${_bathroomSuffix(room.bathroomType)}'
                      : (room.bathroomType?.isNotEmpty ?? false)
                          ? room.bathroomType!
                          : 'Shared',
                ),
              ],
            );
          },
        ),
        if (room.attributes.isNotEmpty) ...[
          const SizedBox(height: 22),
          _SectionTitle(
            icon: Icons.auto_awesome_outlined,
            title: context.translate('what_we_offer'),
          ),
          const SizedBox(height: 10),
          _ChipList(values: room.attributes),
        ],
        const SizedBox(height: 22),
        const _SectionTitle(
          icon: Icons.article_outlined,
          title: 'Rental details',
        ),
        const SizedBox(height: 8),
        Card(
          elevation: 0,
          color: scheme.surfaceContainerLow,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            child: Column(
              children: [
                _DetailRow(label: 'Status', value: _availability),
                _DetailRow(
                  label: 'Minimum stay',
                  value:
                      '${room.minimumStayMonths} ${room.minimumStayMonths == 1 ? 'month' : 'months'}',
                ),
                _DetailRow(
                  label: 'Rent due',
                  value: 'Day ${room.rentDueDay} of every month',
                ),
                _DetailRow(
                  label: 'Grace period',
                  value: '${room.gracePeriodDays} days',
                ),
                if ((room.preferredTenant ?? '').isNotEmpty)
                  _DetailRow(
                    label: 'Preferred tenant',
                    value: room.preferredTenant!,
                  ),
                _DetailRow(
                  label: 'Move-in total',
                  value:
                      'NPR ${_money(room.rentAmount + room.securityDeposit)}',
                  isLast: true,
                ),
              ],
            ),
          ),
        ),
        if (room.utilitiesIncluded.isNotEmpty) ...[
          const SizedBox(height: 22),
          const _SectionTitle(
            icon: Icons.lightbulb_outline,
            title: 'Utilities included',
          ),
          const SizedBox(height: 10),
          _ChipList(values: room.utilitiesIncluded, leadingCheck: true),
        ],
        if (room.houseRules.isNotEmpty) ...[
          const SizedBox(height: 22),
          const _SectionTitle(icon: Icons.rule_outlined, title: 'House rules'),
          const SizedBox(height: 8),
          ...room.houseRules.map(
            (rule) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    size: 18,
                    color: scheme.primary,
                  ),
                  const SizedBox(width: 9),
                  Expanded(
                    child: Text(rule, style: theme.textTheme.bodyMedium),
                  ),
                ],
              ),
            ),
          ),
        ],
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: room.isOccupied
                ? null
                : () => showModalBottomSheet<void>(
                      context: context,
                      isScrollControlled: true,
                      useSafeArea: true,
                      builder: (_) => BookingBottomSheet(room: room),
                    ),
            icon: Icon(room.isOccupied ? Icons.block : Icons.event_available),
            label: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Text(
                room.isOccupied
                    ? 'Currently occupied'
                    : 'Check availability & book',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _unitLabel(String value) {
    if (value.isEmpty) return 'Room';
    return '${value[0].toUpperCase()}${value.substring(1)}';
  }

  String _bathroomSuffix(String? type) =>
      type == null || type.trim().isEmpty ? '' : ' · ${type.trim()}';

  String _ordinalFloor(int floor) {
    if (floor == 0) return 'Ground floor';
    final mod100 = floor % 100;
    final suffix = mod100 >= 11 && mod100 <= 13
        ? 'th'
        : switch (floor % 10) {
            1 => 'st',
            2 => 'nd',
            3 => 'rd',
            _ => 'th',
          };
    return '$floor$suffix floor';
  }
}

class _AvailabilityBadge extends StatelessWidget {
  final bool isOccupied;

  const _AvailabilityBadge({required this.isOccupied});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final background =
        isOccupied ? scheme.errorContainer : scheme.primaryContainer;
    final foreground =
        isOccupied ? scheme.onErrorContainer : scheme.onPrimaryContainer;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        isOccupied ? 'Occupied' : 'Available',
        style: TextStyle(
          color: foreground,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _PriceItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _PriceItem({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: theme.colorScheme.primary, size: 20),
        const SizedBox(height: 8),
        Text(label, style: theme.textTheme.bodySmall),
        const SizedBox(height: 2),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(
            value,
            style: theme.textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final IconData icon;
  final String title;

  const _SectionTitle({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 21, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 9),
        Expanded(
          child: Text(
            title,
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
        ),
      ],
    );
  }
}

class _FactTile extends StatelessWidget {
  final double width;
  final IconData icon;
  final String label;
  final String value;

  const _FactTile({
    required this.width,
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: width,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Row(
        children: [
          Icon(icon, color: theme.colorScheme.primary, size: 21),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: theme.textTheme.labelSmall),
                const SizedBox(height: 2),
                Text(
                  value,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isLast;

  const _DetailRow({
    required this.label,
    required this.value,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 11),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : Border(
                bottom: BorderSide(color: theme.colorScheme.outlineVariant),
              ),
      ),
      child: Row(
        children: [
          Expanded(child: Text(label, style: theme.textTheme.bodyMedium)),
          const SizedBox(width: 16),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: theme.textTheme.bodyMedium
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChipList extends StatelessWidget {
  final List<String> values;
  final bool leadingCheck;

  const _ChipList({required this.values, this.leadingCheck = false});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: values
          .where((value) => value.trim().isNotEmpty)
          .map(
            (value) => Chip(
              avatar: leadingCheck
                  ? Icon(
                      Icons.check,
                      size: 16,
                      color: Theme.of(context).colorScheme.primary,
                    )
                  : null,
              label: Text(value.trim()),
            ),
          )
          .toList(),
    );
  }
}
