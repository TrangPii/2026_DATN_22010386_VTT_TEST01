import 'dart:convert';

import '../core/constants/api_constants.dart';
import '../core/network/api_client.dart';
import '../models/booking.dart';

class BookingException implements Exception {
  final String message;

  const BookingException(this.message);

  @override
  String toString() => message;
}

class BookingService {
  Future<Booking> createBooking({
    required int serviceId,
    required String bookingDate,
    required String bookingTime,
    required int quantity,
    required String customerName,
    required String customerPhone,
    required String serviceAddress,
    String? note,
  }) async {
    final response = await ApiClient.post(
      ApiConstants.bookings,
      authenticated: true,
      body: {
        'service_id': serviceId,
        'booking_date': bookingDate,
        'booking_time': bookingTime,
        'quantity': quantity,
        'customer_name': customerName.trim(),
        'customer_phone': customerPhone.trim(),
        'service_address': serviceAddress.trim(),
        'note': note?.trim(),
      },
    );

    final data = jsonDecode(response.body);

    if (response.statusCode != 201) {
      throw BookingException(_extractMessage(data));
    }

    return Booking.fromJson(
      Map<String, dynamic>.from(data['data']['booking'] as Map),
    );
  }

  Future<List<Booking>> getBookings({String? status}) async {
    var endpoint = ApiConstants.bookings;

    if (status != null && status.isNotEmpty) {
      endpoint += '?status=$status';
    }

    final response = await ApiClient.get(endpoint, authenticated: true);

    final data = jsonDecode(response.body);

    if (response.statusCode != 200) {
      throw BookingException(_extractMessage(data));
    }

    final list = data['data']['bookings'] as List<dynamic>;

    return list
        .map((item) => Booking.fromJson(Map<String, dynamic>.from(item as Map)))
        .toList();
  }

  Future<Booking> getBooking(int id) async {
    final response = await ApiClient.get(
      '${ApiConstants.bookings}/$id',
      authenticated: true,
    );

    final data = jsonDecode(response.body);

    if (response.statusCode != 200) {
      throw BookingException(_extractMessage(data));
    }

    return Booking.fromJson(
      Map<String, dynamic>.from(data['data']['booking'] as Map),
    );
  }

  Future<Booking> cancelBooking({
    required int bookingId,
    required String reason,
  }) async {
    final response = await ApiClient.post(
      '${ApiConstants.bookings}/$bookingId/cancel',
      authenticated: true,
      body: {'reason': reason.trim()},
    );

    final data = jsonDecode(response.body);

    if (response.statusCode != 200) {
      throw BookingException(_extractMessage(data));
    }

    return Booking.fromJson(
      Map<String, dynamic>.from(data['data']['booking'] as Map),
    );
  }

  Future<void> createReview({
    required int bookingId,
    required int rating,
    String? comment,
  }) async {
    final response = await ApiClient.post(
      '${ApiConstants.bookings}/$bookingId/review',
      authenticated: true,
      body: {'rating': rating, 'comment': comment?.trim()},
    );

    final data = jsonDecode(response.body);

    if (response.statusCode != 201) {
      throw BookingException(_extractMessage(data));
    }
  }

  String _extractMessage(dynamic data) {
    if (data is Map<String, dynamic>) {
      final errors = data['errors'];

      if (errors is Map && errors.isNotEmpty) {
        final first = errors.values.first;

        if (first is List && first.isNotEmpty) {
          return first.first.toString();
        }
      }

      if (data['message'] != null) {
        return data['message'].toString();
      }
    }

    return 'Đã xảy ra lỗi. Vui lòng thử lại.';
  }
}
