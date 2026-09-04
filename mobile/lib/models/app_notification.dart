class AppNotification {
  final String id;
  final String? type;
  final String title;
  final String message;
  final String? audience;
  final String? target;
  final int? bookingId;
  final String? bookingCode;
  final String? status;
  final DateTime? readAt;
  final DateTime? createdAt;

  const AppNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    required this.audience,
    required this.target,
    required this.bookingId,
    required this.bookingCode,
    required this.status,
    required this.readAt,
    required this.createdAt,
  });

  bool get isRead => readAt != null;

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'].toString(),

      type: json['type']?.toString(),

      title: json['title']?.toString() ?? '',

      message: json['message']?.toString() ?? '',

      audience: json['audience']?.toString(),

      target: json['target']?.toString(),

      bookingId: json['booking_id'] == null
          ? null
          : int.tryParse(json['booking_id'].toString()),

      bookingCode: json['booking_code']?.toString(),

      status: json['status']?.toString(),

      readAt: DateTime.tryParse(json['read_at']?.toString() ?? ''),

      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? ''),
    );
  }
}
