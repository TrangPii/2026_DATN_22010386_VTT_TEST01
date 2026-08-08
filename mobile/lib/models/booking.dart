class Booking {
  final int id;
  final String bookingCode;
  final String serviceName;

  final double unitPrice;
  final int quantity;
  final double totalAmount;

  final String bookingDate;
  final String bookingTime;

  final String customerName;
  final String customerPhone;
  final String serviceAddress;

  final String? note;
  final String status;

  final String? rejectionReason;
  final String? cancellationReason;

  final DateTime? acceptedAt;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final DateTime? cancelledAt;

  final BookingProvider? provider;
  final BookingServiceInfo? service;
  final BookingReview? review;

  const Booking({
    required this.id,
    required this.bookingCode,
    required this.serviceName,
    required this.unitPrice,
    required this.quantity,
    required this.totalAmount,
    required this.bookingDate,
    required this.bookingTime,
    required this.customerName,
    required this.customerPhone,
    required this.serviceAddress,
    this.note,
    required this.status,
    this.rejectionReason,
    this.cancellationReason,
    this.acceptedAt,
    this.startedAt,
    this.completedAt,
    this.cancelledAt,
    this.provider,
    this.service,
    this.review,
  });

  bool get canCancel => status == 'PENDING' || status == 'ACCEPTED';

  bool get canReview => status == 'COMPLETED' && review == null;

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'] as int,
      bookingCode: json['booking_code']?.toString() ?? '',
      serviceName: json['service_name']?.toString() ?? '',

      unitPrice: double.tryParse(json['unit_price']?.toString() ?? '0') ?? 0,

      quantity: int.tryParse(json['quantity']?.toString() ?? '1') ?? 1,

      totalAmount:
          double.tryParse(json['total_amount']?.toString() ?? '0') ?? 0,

      bookingDate: json['booking_date']?.toString() ?? '',
      bookingTime: json['booking_time']?.toString() ?? '',

      customerName: json['customer_name']?.toString() ?? '',
      customerPhone: json['customer_phone']?.toString() ?? '',
      serviceAddress: json['service_address']?.toString() ?? '',

      note: json['note']?.toString(),
      status: json['status']?.toString() ?? '',

      rejectionReason: json['rejection_reason']?.toString(),
      cancellationReason: json['cancellation_reason']?.toString(),

      acceptedAt: _date(json['accepted_at']),
      startedAt: _date(json['started_at']),
      completedAt: _date(json['completed_at']),
      cancelledAt: _date(json['cancelled_at']),

      provider: json['provider'] is Map
          ? BookingProvider.fromJson(
              Map<String, dynamic>.from(json['provider'] as Map),
            )
          : null,

      service: json['service'] is Map
          ? BookingServiceInfo.fromJson(
              Map<String, dynamic>.from(json['service'] as Map),
            )
          : null,

      review: json['review'] is Map
          ? BookingReview.fromJson(
              Map<String, dynamic>.from(json['review'] as Map),
            )
          : null,
    );
  }

  static DateTime? _date(dynamic value) {
    if (value == null) return null;
    return DateTime.tryParse(value.toString());
  }
}

class BookingProvider {
  final int id;
  final String name;
  final String? businessName;

  const BookingProvider({
    required this.id,
    required this.name,
    this.businessName,
  });

  factory BookingProvider.fromJson(Map<String, dynamic> json) {
    return BookingProvider(
      id: json['id'] as int,
      name: json['name']?.toString() ?? '',
      businessName: json['business_name']?.toString(),
    );
  }
}

class BookingServiceInfo {
  final int id;
  final String name;
  final String? image;

  const BookingServiceInfo({required this.id, required this.name, this.image});

  factory BookingServiceInfo.fromJson(Map<String, dynamic> json) {
    return BookingServiceInfo(
      id: json['id'] as int,
      name: json['name']?.toString() ?? '',
      image: json['image']?.toString(),
    );
  }
}

class BookingReview {
  final int id;
  final int rating;
  final String? comment;

  const BookingReview({required this.id, required this.rating, this.comment});

  factory BookingReview.fromJson(Map<String, dynamic> json) {
    return BookingReview(
      id: json['id'] as int,
      rating: int.tryParse(json['rating']?.toString() ?? '0') ?? 0,
      comment: json['comment']?.toString(),
    );
  }
}
