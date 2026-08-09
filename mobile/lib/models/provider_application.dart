class ProviderApplication {
  final int id;
  final int userId;

  final String businessName;
  final String? description;
  final String? address;
  final String? identityNumber;

  final int experienceYears;

  final String verificationStatus;

  final DateTime? verifiedAt;

  const ProviderApplication({
    required this.id,
    required this.userId,
    required this.businessName,
    this.description,
    this.address,
    this.identityNumber,
    required this.experienceYears,
    required this.verificationStatus,
    this.verifiedAt,
  });

  bool get isPending => verificationStatus == 'PENDING';

  bool get isApproved => verificationStatus == 'APPROVED';

  bool get isRejected => verificationStatus == 'REJECTED';

  factory ProviderApplication.fromJson(Map<String, dynamic> json) {
    return ProviderApplication(
      id: _parseInt(json['id']),
      userId: _parseInt(json['user_id']),

      businessName: json['business_name']?.toString() ?? '',

      description: json['description']?.toString(),

      address: json['address']?.toString(),

      identityNumber: json['identity_number']?.toString(),

      experienceYears: _parseInt(json['experience_years']),

      verificationStatus: json['verification_status']?.toString() ?? 'PENDING',

      verifiedAt: json['verified_at'] != null
          ? DateTime.tryParse(json['verified_at'].toString())
          : null,
    );
  }

  static int _parseInt(dynamic value) {
    if (value is int) {
      return value;
    }

    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}
