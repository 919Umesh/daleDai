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
  final String status;
  final DateTime updatedAt;
  final DateTime createdAt;
  final String profession;
  final int peoples;
  final String propertyId;
  final String title;
  final String description;
  final String address;
  final String propertyType;
  final double latitude;
  final double longitude;
  final String furnishingStatus;
  final int areaSqft;
  final String roomNumber;
  final int rentAmount;
  final List<String> attributes;

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
    required this.updatedAt,
    required this.createdAt,
    required this.profession,
    required this.peoples,
    required this.propertyId,
    required this.title,
    required this.description,
    required this.address,
    required this.propertyType,
    required this.latitude,
    required this.longitude,
    required this.furnishingStatus,
    required this.areaSqft,
    required this.roomNumber,
    required this.rentAmount,
    required this.attributes,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      bookingId: json['booking_id'] as String? ?? '',
      roomId: json['room_id'] as String? ?? '',
      tenantId: json['tenant_id'] as String? ?? '',
      landlordId: json['landlord_id'] as String? ?? '',
      bookingDate: json['booking_date'] != null
          ? (DateTime.tryParse(json['booking_date'] as String) ?? DateTime.now())
          : DateTime.now(),
      moveInDate: json['move_in_date'] != null
          ? (DateTime.tryParse(json['move_in_date'] as String) ?? DateTime.now())
          : DateTime.now(),
      moveOutDate: json['move_out_date'] != null
          ? DateTime.tryParse(json['move_out_date'] as String)
          : null,
      monthlyRent: (json['monthly_rent'] as num?)?.toInt() ?? 0,
      securityDeposit: (json['security_deposit'] as num?)?.toInt() ?? 0,
      status: json['status'] as String? ?? 'pending',
      updatedAt: json['updated_at'] != null
          ? (DateTime.tryParse(json['updated_at'] as String) ?? DateTime.now())
          : DateTime.now(),
      createdAt: json['created_at'] != null
          ? (DateTime.tryParse(json['created_at'] as String) ?? DateTime.now())
          : DateTime.now(),
      profession: json['profession'] as String? ?? '',
      peoples: (json['peoples'] as num?)?.toInt() ?? 1,
      propertyId: json['property_id'] as String? ?? '',
      title: json['title'] as String? ?? 'Booking',
      description: json['description'] as String? ?? '',
      address: json['address'] as String? ?? '',
      propertyType: json['property_type'] as String? ?? '',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      furnishingStatus: json['furnishing_status'] as String? ?? '',
      areaSqft: (json['area_sqft'] as num?)?.toInt() ?? 0,
      roomNumber: json['room_number'] as String? ?? 'N/A',
      rentAmount: (json['rent_amount'] as num?)?.toInt() ?? 0,
      attributes: List<String>.from(json['attributes'] as List? ?? []),
    );
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
      'status': status,
      'updated_at': updatedAt.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'profession': profession,
      'peoples': peoples,
      'property_id': propertyId,
      'title': title,
      'description': description,
      'address': address,
      'property_type': propertyType,
      'latitude': latitude,
      'longitude': longitude,
      'furnishing_status': furnishingStatus,
      'area_sqft': areaSqft,
      'room_number': roomNumber,
      'rent_amount': rentAmount,
      'attributes': attributes,
    };
  }
}
