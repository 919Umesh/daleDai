enum BookingStatus { pending, confirmed, completed }

extension BookingStatusExtension on BookingStatus {
  String get value {
    switch (this) {
      case BookingStatus.pending:
        return 'pending';
      case BookingStatus.confirmed:
        return 'confirmed';
      case BookingStatus.completed:
        return 'completed';
    }
  }
}

class BookingModel {
  final String bookingId;
  final String roomId;
  final String tenantId;
  final String landlordId;
  final DateTime bookingDate;
  final DateTime moveInDate;
  final DateTime? moveOutDate;
  final int monthlyRent;
  final int securityDeposit;
  final BookingStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;

  BookingModel({
    required this.bookingId,
    required this.roomId,
    required this.tenantId,
    required this.landlordId,
    required this.bookingDate,
    required this.moveInDate,
    this.moveOutDate,
    required this.monthlyRent,
    required this.securityDeposit,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      bookingId: json['booking_id'] as String,
      roomId: json['room_id'] as String,
      tenantId: json['tenant_id'] as String,
      landlordId: json['landlord_id'] as String,
      bookingDate: DateTime.parse(json['booking_date'] as String),
      moveInDate: DateTime.parse(json['move_in_date'] as String),
      moveOutDate: json['move_out_date'] != null
          ? DateTime.parse(json['move_out_date'] as String)
          : null,
      monthlyRent: json['monthly_rent'] as int,
      securityDeposit: json['security_deposit'] as int,
      status: _parseStatus(json['status'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  static BookingStatus _parseStatus(String status) {
    switch (status) {
      case 'pending':
        return BookingStatus.pending;
      case 'confirmed':
        return BookingStatus.confirmed;
      case 'completed':
        return BookingStatus.completed;
      default:
        return BookingStatus.pending;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'booking_id': bookingId,
      'room_id': roomId,
      'tenant_id': tenantId,
      'landlord_id': landlordId,
      'booking_date': bookingDate.toIso8601String(),
      'move_in_date': moveInDate.toIso8601String(),
      'move_out_date': moveOutDate?.toIso8601String(),
      'monthly_rent': monthlyRent,
      'security_deposit': securityDeposit,
      'status': status.value,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
