class PropertyImageModel {
  final String imagesId;
  final String propertyId;
  final String imageUrl;
  final bool isPrimary;
  final DateTime? createdAt;

  PropertyImageModel({
    required this.imagesId,
    required this.propertyId,
    required this.imageUrl,
    required this.isPrimary,
    this.createdAt,
  });

  factory PropertyImageModel.fromJson(Map<String, dynamic> json) {
    return PropertyImageModel(
      imagesId: json['images_id'] as String,
      propertyId: json['property_id'] as String,
      imageUrl: json['image_url'] as String,
      isPrimary: json['is_primary'] as bool,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'images_id': imagesId,
      'property_id': propertyId,
      'image_url': imageUrl,
      'is_primary': isPrimary,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}
