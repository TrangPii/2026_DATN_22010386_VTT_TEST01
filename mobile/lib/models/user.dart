class User {
  final int id;
  final String name;
  final String email;
  final String? phone;
  final String? avatar;
  final String role;
  final String status;

  const User({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.avatar,
    required this.role,
    required this.status,
  });

  bool get isCustomer => role == 'CUSTOMER';

  bool get isProvider => role == 'PROVIDER';

  bool get isAdmin => role == 'ADMIN';

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int,
      name: json['name'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String?,
      avatar: json['avatar'] as String?,
      role: json['role'] as String,
      status: json['status'] as String,
    );
  }
}
