class ReviewUser {
  final String reviewId;
  final String propertyId;
  final String userId;
  final int rating;
  final String comment;
  final DateTime createdAt;
  final String name;
  final String profileImage;

  ReviewUser({
    required this.reviewId,
    required this.propertyId,
    required this.userId,
    required this.rating,
    required this.comment,
    required this.createdAt,
    required this.name,
    required this.profileImage,
  });

  factory ReviewUser.fromJson(Map<String, dynamic> json) {
    return ReviewUser(
      reviewId: json['review_id'] as String,
      propertyId: json['property_id'] as String,
      userId: json['user_id'] as String,
      rating: json['rating'] as int,
      comment: json['comment'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      name: json['name'] as String,
      profileImage: json['profile_image'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'review_id': reviewId,
      'property_id': propertyId,
      'user_id': userId,
      'rating': rating,
      'comment': comment,
      'created_at': createdAt.toIso8601String(),
      'name': name,
      'profile_image': profileImage,
    };
  }
}