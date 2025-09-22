class UserModel {
  final String userId;
  final String name;
  final String email;
  final String phone;
  final String? profileImage;
  final bool isVerified;
  final String? documentUrl;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String userType;

  UserModel({
    required this.userId,
    required this.name,
    required this.email,
    required this.phone,
    this.profileImage,
    required this.isVerified,
    this.documentUrl,
    this.createdAt,
    this.updatedAt,
    required this.userType,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      userId: json['user_id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String,
      profileImage: json['profile_image'] as String?,
      isVerified: json['is_verified'] as bool? ?? false,
      documentUrl: json['document_url'] as String?,
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at'] as String) 
          : null,
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at'] as String) 
          : null,
      userType: json['user_type'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'name': name,
      'email': email,
      'phone': phone,
      'profile_image': profileImage,
      'is_verified': isVerified,
      'document_url': documentUrl,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'user_type': userType,
    };
  }
}