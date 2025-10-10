class LocationView {
  final String propertyId;
  final String title;
  final String address;
  final String city;
  final double latitude;
  final double longitude;
  final bool isActive;

  LocationView({
    required this.propertyId,
    required this.title,
    required this.address,
    required this.city,
    required this.latitude,
    required this.longitude,
    required this.isActive,
  });

  factory LocationView.fromJson(Map<String, dynamic> json) {
    return LocationView(
      propertyId: json['property_id'] as String,
      title: json['title'] as String,
      address: json['address'] as String,
      city: json['city'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      isActive: json['is_active'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'property_id': propertyId,
      'title': title,
      'address': address,
      'city': city,
      'latitude': latitude,
      'longitude': longitude,
      'is_active': isActive,
    };
  }
}
