class RoomModelImage {
  final String roomId;
  final String propertyId;
  final String roomNumber;
  final double rentAmount;
  final double securityDeposit;
  final String roomType;
  final bool isOccupied;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<String> images;
  final List<String> attributes;
  final String description;
  final int maxOccupants;
  final int? floorNumber;
  final int? areaSqft;
  final String? furnishingStatus;
  final String? bathroomType;
  final bool hasAttachedBathroom;
  final DateTime? availableFrom;
  final int minimumStayMonths;
  final List<String> utilitiesIncluded;
  final List<String> houseRules;
  final String? preferredTenant;
  final String unitKind;
  final int rentDueDay;
  final int gracePeriodDays;

  RoomModelImage({
    required this.roomId,
    required this.propertyId,
    required this.roomNumber,
    required this.rentAmount,
    required this.securityDeposit,
    required this.roomType,
    required this.isOccupied,
    required this.createdAt,
    required this.updatedAt,
    required this.images,
    required this.attributes,
    required this.description,
    this.maxOccupants = 1,
    this.floorNumber,
    this.areaSqft,
    this.furnishingStatus,
    this.bathroomType,
    this.hasAttachedBathroom = false,
    this.availableFrom,
    this.minimumStayMonths = 1,
    this.utilitiesIncluded = const [],
    this.houseRules = const [],
    this.preferredTenant,
    this.unitKind = 'room',
    this.rentDueDay = 1,
    this.gracePeriodDays = 5,
  });

  factory RoomModelImage.fromJson(Map<String, dynamic> json) {
    return RoomModelImage(
      roomId: json['room_id'] as String,
      propertyId: json['property_id'] as String,
      roomNumber: json['room_number'] as String,
      rentAmount: (json['rent_amount'] as num).toDouble(),
      securityDeposit: (json['security_deposit'] as num).toDouble(),
      roomType: json['room_type'] as String,
      isOccupied: json['is_occupied'] as bool,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      images: List<String>.from(json['images'] as List? ?? []),
      attributes: List<String>.from(json['attributes'] as List? ?? []),
      description: json['description'] as String,
      maxOccupants: (json['max_occupants'] as num?)?.toInt() ?? 1,
      floorNumber: (json['floor_number'] as num?)?.toInt(),
      areaSqft: (json['area_sqft'] as num?)?.toInt(),
      furnishingStatus: json['furnishing_status'] as String?,
      bathroomType: json['bathroom_type'] as String?,
      hasAttachedBathroom: json['has_attached_bathroom'] as bool? ?? false,
      availableFrom: json['available_from'] == null
          ? null
          : DateTime.tryParse(json['available_from'].toString()),
      minimumStayMonths: (json['minimum_stay_months'] as num?)?.toInt() ?? 1,
      utilitiesIncluded:
          List<String>.from(json['utilities_included'] as List? ?? const []),
      houseRules: List<String>.from(json['house_rules'] as List? ?? const []),
      preferredTenant: json['preferred_tenant'] as String?,
      unitKind: json['unit_kind'] as String? ?? 'room',
      rentDueDay: (json['rent_due_day'] as num?)?.toInt() ?? 1,
      gracePeriodDays: (json['grace_period_days'] as num?)?.toInt() ?? 5,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'room_id': roomId,
      'property_id': propertyId,
      'room_number': roomNumber,
      'rent_amount': rentAmount,
      'security_deposit': securityDeposit,
      'room_type': roomType,
      'is_occupied': isOccupied,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'images': images,
      'attributes': attributes,
      'description': description,
      'max_occupants': maxOccupants,
      'floor_number': floorNumber,
      'area_sqft': areaSqft,
      'furnishing_status': furnishingStatus,
      'bathroom_type': bathroomType,
      'has_attached_bathroom': hasAttachedBathroom,
      'available_from': availableFrom?.toIso8601String(),
      'minimum_stay_months': minimumStayMonths,
      'utilities_included': utilitiesIncluded,
      'house_rules': houseRules,
      'preferred_tenant': preferredTenant,
      'unit_kind': unitKind,
      'rent_due_day': rentDueDay,
      'grace_period_days': gracePeriodDays,
    };
  }
}
