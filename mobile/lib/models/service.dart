class Service {
  final int id;
  final String name;
  final String slug;
  final String? description;

  final double price;
  final String priceUnit;

  final int? estimatedDurationMinutes;
  final String? image;
  final String status;

  final ServiceCategoryInfo? category;
  final ServiceProviderInfo? provider;

  const Service({
    required this.id,
    required this.name,
    required this.slug,
    this.description,
    required this.price,
    required this.priceUnit,
    this.estimatedDurationMinutes,
    this.image,
    required this.status,
    this.category,
    this.provider,
  });

  factory Service.fromJson(Map<String, dynamic> json) {
    return Service(
      id: json['id'] as int,
      name: json['name']?.toString() ?? '',
      slug: json['slug']?.toString() ?? '',
      description: json['description']?.toString(),

      price: double.tryParse(json['price']?.toString() ?? '0') ?? 0,

      priceUnit: json['price_unit']?.toString() ?? 'lần',

      estimatedDurationMinutes: json['estimated_duration_minutes'] == null
          ? null
          : int.tryParse(json['estimated_duration_minutes'].toString()),

      image: json['image']?.toString(),

      status: json['status']?.toString() ?? '',

      category: json['category'] is Map
          ? ServiceCategoryInfo.fromJson(
              Map<String, dynamic>.from(json['category'] as Map),
            )
          : null,

      provider: json['provider'] is Map
          ? ServiceProviderInfo.fromJson(
              Map<String, dynamic>.from(json['provider'] as Map),
            )
          : null,
    );
  }
}

class ServiceCategoryInfo {
  final int id;
  final String name;
  final String slug;

  const ServiceCategoryInfo({
    required this.id,
    required this.name,
    required this.slug,
  });

  factory ServiceCategoryInfo.fromJson(Map<String, dynamic> json) {
    return ServiceCategoryInfo(
      id: json['id'] as int,
      name: json['name']?.toString() ?? '',
      slug: json['slug']?.toString() ?? '',
    );
  }
}

class ServiceProviderInfo {
  final int id;
  final String name;
  final String? avatar;
  final String? businessName;
  final double averageRating;
  final int totalReviews;
  final String? verificationStatus;

  const ServiceProviderInfo({
    required this.id,
    required this.name,
    this.avatar,
    this.businessName,
    required this.averageRating,
    required this.totalReviews,
    this.verificationStatus,
  });

  factory ServiceProviderInfo.fromJson(Map<String, dynamic> json) {
    final profile = json['provider_profile'];

    Map<String, dynamic>? profileMap;

    if (profile is Map) {
      profileMap = Map<String, dynamic>.from(profile);
    }

    return ServiceProviderInfo(
      id: json['id'] as int,
      name: json['name']?.toString() ?? '',
      avatar: json['avatar']?.toString(),

      businessName: profileMap?['business_name']?.toString(),

      averageRating:
          double.tryParse(profileMap?['average_rating']?.toString() ?? '0') ??
          0,

      totalReviews:
          int.tryParse(profileMap?['total_reviews']?.toString() ?? '0') ?? 0,

      verificationStatus: profileMap?['verification_status']?.toString(),
    );
  }
}
