class User {
  final int id;

  final String name;
  final String email;
  final String? phone;
  final String? avatar;

  final String role;

  // User account status: ACTIVE / LOCKED
  final String status;

  // Provider verification: PENDING / APPROVED / REJECTED / null
  final String? providerStatus;

  // Provider operational status: ACTIVE / LOCKED / null
  final String? providerOperationalStatus;

  final bool canUseProviderMode;

  const User({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.avatar,
    required this.role,
    required this.status,
    required this.providerStatus,
    required this.providerOperationalStatus,
    required this.canUseProviderMode,
  });

  bool get isCustomer => role == 'CUSTOMER';

  bool get hasProviderApplication => providerStatus != null;

  bool get isProviderPending => providerStatus == 'PENDING';

  bool get isProviderApproved => providerStatus == 'APPROVED';

  bool get isProviderRejected => providerStatus == 'REJECTED';

  bool get isActive => status == 'ACTIVE';

  bool get isProviderOperational => providerOperationalStatus == 'ACTIVE';

  bool get isProviderLocked => providerOperationalStatus == 'LOCKED';

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int,

      name: json['name']?.toString() ?? '',

      email: json['email']?.toString() ?? '',

      phone: json['phone']?.toString(),

      avatar: json['avatar']?.toString(),

      role: json['role']?.toString() ?? 'CUSTOMER',

      status: json['status']?.toString() ?? 'ACTIVE',

      providerStatus: json['provider_verification_status']?.toString(),

      providerOperationalStatus: json['provider_status']?.toString(),

      canUseProviderMode: json['can_use_provider_mode'] == true,
    );
  }
}
