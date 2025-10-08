class ImageModel {
  final String imagesId;
  final String propertyId;
  final List<String> images;
  final DateTime createdAt;

  ImageModel({
    required this.imagesId,
    required this.propertyId,
    required this.images,
    required this.createdAt,
  });

  factory ImageModel.fromJson(Map<String, dynamic> json) {
    return ImageModel(
      imagesId: json['images_id'] as String,
      propertyId: json['property_id'] as String,
      images: List<String>.from(json['image_url'] as List? ?? []),
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'images_id': imagesId,
      'property_id': propertyId,
      'image_url': images,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
