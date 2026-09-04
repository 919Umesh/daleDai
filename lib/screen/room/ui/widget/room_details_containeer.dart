// removed unused cached_network_image import
import 'package:flutter/material.dart';
import 'package:omspos/screen/room/model/room_model_images.dart';
import 'package:omspos/screen/room/ui/booking_bottom_sheet.dart';
// kept minimal for room details container
import 'package:omspos/services/language/translation_extension.dart';
import 'package:omspos/themes/fonts_style.dart';

class RoomDetailsContainer extends StatefulWidget {
  final RoomModelImage room;
  const RoomDetailsContainer({super.key, required this.room});

  @override
  State<RoomDetailsContainer> createState() => _RoomDetailsContainerState();
}

class _RoomDetailsContainerState extends State<RoomDetailsContainer> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final room = widget.room;
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 5),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  room.roomNumber,
                  style: titleListTextStyle.copyWith(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  height: 40,
                  width: 100,
                  decoration: BoxDecoration(
                    color: room.isOccupied ? Colors.red : Theme.of(context).primaryColor,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Center(
                      child: Text(
                        room.isOccupied ? 'Occupied' : 'Available',
                    style: priceTitleTextStyle,
                  )),
                )
              ],
            ),
            const SizedBox(height: 12),

            // Description with See More (only shown when text actually overflows)
            Builder(builder: (context) {
              final description = room.description.isNotEmpty
                  ? room.description
                  : "No description available";
              final descriptionStyle = subTitleTextStyle.copyWith(height: 1.4);
              return LayoutBuilder(builder: (context, constraints) {
                final painter = TextPainter(
                  text: TextSpan(text: description, style: descriptionStyle),
                  maxLines: 3,
                  textDirection: Directionality.of(context),
                )..layout(maxWidth: constraints.maxWidth);
                final isOverflowing = painter.didExceedMaxLines;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      description,
                      style: descriptionStyle,
                      maxLines: _isExpanded ? null : 3,
                      overflow: _isExpanded
                          ? TextOverflow.visible
                          : TextOverflow.ellipsis,
                    ),
                    if (isOverflowing)
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () =>
                              setState(() => _isExpanded = !_isExpanded),
                          child: Text(_isExpanded
                              ? context.translate('see_less')
                              : context.translate('see_more')),
                        ),
                      ),
                  ],
                );
              });
            }),
            SizedBox(
              height: 2,
            ),
            Text(context.translate('what_we_offer'), style: titleListTextStyle),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (var value in room.attributes)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      value,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),
              ],
            ),

            SizedBox(
              height: 5,
            ),

            // Details
            Text(context.translate('details'), style: titleListTextStyle),
            const SizedBox(height: 5),
            _buildDetailRow(context, "Room Type", room.roomType),
            _buildDetailRow(context, "Rent Amount", "Rs. ${room.rentAmount}"),
            _buildDetailRow(
              context, "Security Deposit", "Rs. ${room.securityDeposit}"),

            SizedBox(
              height: 12,
            ),
           
            // Book Now Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: () {
                  debugPrint('Book');
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    builder: (context) => BookingBottomSheet(room: room,),
                  );
                },
                child: Text(
                  "Book Now",
                  style: titleListTextStyle.copyWith(color: Colors.white),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Text("$label: ", style: reviewTitleTextStyle),
          Expanded(
            child: Text(value ?? "-", style: priceTitleTextStyle),
          )
        ],
      ),
    );
  }
}
