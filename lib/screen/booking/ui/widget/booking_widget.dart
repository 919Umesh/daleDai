import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:omspos/screen/booking/model/booking_model.dart';
import 'package:omspos/screen/booking/state/booking_state.dart';
import 'package:omspos/services/language/translation_extension.dart';
import 'package:provider/provider.dart';

class BookingWidget extends StatelessWidget {
  final BookingModel booking;

  const BookingWidget({super.key, required this.booking});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getPropertyTypeIcon(booking.propertyType),
                    color: Theme.of(context).primaryColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        booking.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        '${context.translate('room')} ${booking.roomNumber}',
                        style: TextStyle(
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),

                // Status Badge
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getStatusColor(booking.status),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    booking.status.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            Row(
              children: [
                _buildDetailItem(
                  icon: Icons.location_on,
                  value: booking.address,
                  context: context,
                ),
                const SizedBox(width: 16),
                _buildDetailItem(
                  icon: Icons.area_chart,
                  value: '${booking.areaSqft} sqft',
                  context: context,
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Booking Details
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildBookingDetail(
                    title: context.translate('move_in'),
                    value:
                        DateFormat('MMM dd, yyyy').format(booking.moveInDate),
                    context: context,
                  ),
                  Container(
                    width: 1,
                    height: 30,
                    color: Colors.grey[300],
                  ),
                  _buildBookingDetail(
                    title: context.translate('monthly_rent'),
                    value: '₹${booking.monthlyRent}',
                    context: context,
                  ),
                  Container(
                    width: 1,
                    height: 30,
                    color: Colors.grey[300],
                  ),
                  _buildBookingDetail(
                    title: context.translate('deposit'),
                    value: '₹${booking.securityDeposit}',
                    context: context,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (booking.profession.isNotEmpty)
                  _buildChip(
                    '${booking.peoples} ${booking.peoples == 1 ? context.translate('person') : context.translate('people')}',
                    Icons.people,
                  ),
                if (booking.profession.isNotEmpty)
                  _buildChip(booking.profession, Icons.work),
                if (booking.furnishingStatus.isNotEmpty)
                  _buildChip(booking.furnishingStatus, Icons.chair),
                ...booking.attributes.take(2).map(
                      (attr) => _buildChip(attr, Icons.check_circle),
                    ),
              ],
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.only(left: 8, right: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      InkWell(
                          onTap: () {
                            final state = Provider.of<BookingState>(context,
                                listen: false);
                            state.generatePdf(booking);
                          },
                          child: Icon(Icons.remove_red_eye_outlined))
                    ],
                  ),
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 14,
                        color: Colors.grey[500],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Booked on ${DateFormat('MMM dd, yyyy').format(booking.bookingDate)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem({
    required IconData icon,
    required String value,
    required BuildContext context,
  }) {
    return Expanded(
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: Theme.of(context).primaryColor,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[700],
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingDetail({
    required String title,
    required String value,
    required BuildContext context,
  }) {
    return Column(
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            color: Theme.of(context).primaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildChip(String text, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 12,
          ),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'cancelled':
        return Colors.red;
      case 'completed':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  IconData _getPropertyTypeIcon(String propertyType) {
    switch (propertyType.toLowerCase()) {
      case 'apartment':
        return Icons.apartment;
      case 'house':
        return Icons.house;
      case 'villa':
        return Icons.villa;

      default:
        return Icons.home;
    }
  }
}
