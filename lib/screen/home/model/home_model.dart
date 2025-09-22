class AreaModel {
  final String areaId;
  final String name;
  final String? areaImage;
  final DateTime? createdAt;

  AreaModel({
    required this.areaId,
    required this.name,
    this.areaImage,
    this.createdAt,
  });

  factory AreaModel.fromJson(Map<String, dynamic> json) {
    return AreaModel(
      areaId: json['area_id'] as String,
      name: json['name'] as String,
      areaImage: json['area_image'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'area_id': areaId,
      'name': name,
      'area_image': areaImage,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}