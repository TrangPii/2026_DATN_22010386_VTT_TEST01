class ServiceCategory {
  final int id;
  final String name;
  final String slug;
  final String? description;
  final String? image;
  final String status;
  final int displayOrder;
  final int servicesCount;

  const ServiceCategory({
    required this.id,
    required this.name,
    required this.slug,
    this.description,
    this.image,
    required this.status,
    required this.displayOrder,
    required this.servicesCount,
  });

  factory ServiceCategory.fromJson(Map<String, dynamic> json) {
    return ServiceCategory(
      id: json['id'] as int,
      name: json['name']?.toString() ?? '',
      slug: json['slug']?.toString() ?? '',
      description: json['description']?.toString(),
      image: json['image']?.toString(),
      status: json['status']?.toString() ?? '',
      displayOrder: int.tryParse(json['display_order']?.toString() ?? '0') ?? 0,
      servicesCount:
          int.tryParse(json['services_count']?.toString() ?? '0') ?? 0,
    );
  }
}
