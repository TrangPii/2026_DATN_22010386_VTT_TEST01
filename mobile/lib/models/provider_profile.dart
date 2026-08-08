class ProviderProfile {
  final int id;
  final String businessName;
  final String? description;
  final String? address;
  final int experienceYears;

  final double averageRating;
  final int totalReviews;

  final String verificationStatus;
  final DateTime? verifiedAt;

  final ProviderProfileUser? user;

  const ProviderProfile({
    required this.id,
    required this.businessName,
    this.description,
    this.address,
    required this.experienceYears,
    required this.averageRating,
    required this.totalReviews,
    required this.verificationStatus,
    this.verifiedAt,
    this.user,
  });

  factory ProviderProfile.fromJson(Map<String, dynamic> json) {
    return ProviderProfile(
      id: json['id'] as int,

      businessName: json['business_name']?.toString() ?? '',

      description: json['description']?.toString(),

      address: json['address']?.toString(),

      experienceYears:
          int.tryParse(json['experience_years']?.toString() ?? '0') ?? 0,

      averageRating:
          double.tryParse(json['average_rating']?.toString() ?? '0') ?? 0,

      totalReviews: int.tryParse(json['total_reviews']?.toString() ?? '0') ?? 0,

      verificationStatus: json['verification_status']?.toString() ?? '',

      verifiedAt: json['verified_at'] == null
          ? null
          : DateTime.tryParse(json['verified_at'].toString()),

      user: json['user'] is Map
          ? ProviderProfileUser.fromJson(
              Map<String, dynamic>.from(json['user'] as Map),
            )
          : null,
    );
  }
}

class ProviderProfileUser {
  final int id;
  final String name;
  final String? email;
  final String? phone;
  final String? avatar;
  final String status;

  const ProviderProfileUser({
    required this.id,
    required this.name,
    this.email,
    this.phone,
    this.avatar,
    required this.status,
  });

  factory ProviderProfileUser.fromJson(Map<String, dynamic> json) {
    return ProviderProfileUser(
      id: json['id'] as int,
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString(),
      phone: json['phone']?.toString(),
      avatar: json['avatar']?.toString(),
      status: json['status']?.toString() ?? '',
    );
  }
}
