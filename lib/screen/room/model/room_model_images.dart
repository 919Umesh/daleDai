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
    };
  }
}
