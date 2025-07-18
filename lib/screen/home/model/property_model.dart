class PropertyModel {
  final String propertyId;
  final String landlordId;
  final String title;
  final String description;
  final String address;
  final String city;
  final String state;
  final String pincode;
  final double latitude;
  final double longitude;
  final String propertyType;
  final String furnishingStatus;
  final int areaSqft;
  final DateTime? availableFrom;
  final bool isActive;
  final DateTime updatedAt;
  final DateTime createdAt;
  final String areaId;

  PropertyModel({
    required this.propertyId,
    required this.landlordId,
    required this.title,
    required this.description,
    required this.address,
    required this.city,
    required this.state,
    required this.pincode,
    required this.latitude,
    required this.longitude,
    required this.propertyType,
    required this.furnishingStatus,
    required this.areaSqft,
    this.availableFrom,
    required this.isActive,
    required this.updatedAt,
    required this.createdAt,
    required this.areaId,
  });

  factory PropertyModel.fromJson(Map<String, dynamic> json) {
    return PropertyModel(
      propertyId: json['property_id'] as String,
      landlordId: json['landlord_id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      address: json['address'] as String,
      city: json['city'] as String,
      state: json['state'] as String,
      pincode: json['pincode'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      propertyType: json['property_type'] as String,
      furnishingStatus: json['furnishing_status'] as String,
      areaSqft: json['area_sqft'] as int,
      availableFrom: json['available_from'] != null 
          ? DateTime.parse(json['available_from'] as String) 
          : null,
      isActive: json['is_active'] as bool,
      updatedAt: DateTime.parse(json['updated_at'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
      areaId: json['area_id'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'property_id': propertyId,
      'landlord_id': landlordId,
      'title': title,
      'description': description,
      'address': address,
      'city': city,
      'state': state,
      'pincode': pincode,
      'latitude': latitude,
      'longitude': longitude,
      'property_type': propertyType,
      'furnishing_status': furnishingStatus,
      'area_sqft': areaSqft,
      'available_from': availableFrom?.toIso8601String(),
      'is_active': isActive,
      'updated_at': updatedAt.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'area_id': areaId,
    };
  }
}