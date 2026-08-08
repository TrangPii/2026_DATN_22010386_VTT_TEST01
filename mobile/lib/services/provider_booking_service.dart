import 'dart:convert';

import '../core/constants/api_constants.dart';
import '../core/network/api_client.dart';
import '../models/booking.dart';

class ProviderBookingException implements Exception {
  final String message;

  const ProviderBookingException(this.message);

  @override
  String toString() => message;
}

class ProviderBookingService {
  Future<List<Booking>> getBookings({String? status}) async {
    var endpoint = ApiConstants.providerBookings;

    if (status != null && status.isNotEmpty) {
      endpoint += '?status=${Uri.encodeQueryComponent(status)}';
    }

    final response = await ApiClient.get(endpoint, authenticated: true);

    final data = jsonDecode(response.body);

    if (response.statusCode != 200) {
      throw ProviderBookingException(_extractMessage(data));
    }

    final bookings = data['data']['bookings'] as List<dynamic>;

    return bookings
        .map((item) => Booking.fromJson(Map<String, dynamic>.from(item as Map)))
        .toList();
  }

  Future<Booking> getBooking(int id) async {
    final response = await ApiClient.get(
      '${ApiConstants.providerBookings}/$id',
      authenticated: true,
    );

    final data = jsonDecode(response.body);

    if (response.statusCode != 200) {
      throw ProviderBookingException(_extractMessage(data));
    }

    return Booking.fromJson(
      Map<String, dynamic>.from(data['data']['booking'] as Map),
    );
  }

  Future<Booking> accept(int id) async {
    return _postStatusAction('$id/accept');
  }

  Future<Booking> start(int id) async {
    return _postStatusAction('$id/start');
  }

  Future<Booking> complete(int id) async {
    return _postStatusAction('$id/complete');
  }

  Future<Booking> reject({required int id, required String reason}) async {
    final response = await ApiClient.post(
      '${ApiConstants.providerBookings}/$id/reject',
      authenticated: true,
      body: {'reason': reason.trim()},
    );

    final data = jsonDecode(response.body);

    if (response.statusCode != 200) {
      throw ProviderBookingException(_extractMessage(data));
    }

    return Booking.fromJson(
      Map<String, dynamic>.from(data['data']['booking'] as Map),
    );
  }

  Future<Booking> _postStatusAction(String path) async {
    final response = await ApiClient.post(
      '${ApiConstants.providerBookings}/$path',
      authenticated: true,
    );

    final data = jsonDecode(response.body);

    if (response.statusCode != 200) {
      throw ProviderBookingException(_extractMessage(data));
    }

    return Booking.fromJson(
      Map<String, dynamic>.from(data['data']['booking'] as Map),
    );
  }

  String _extractMessage(dynamic data) {
    if (data is Map<String, dynamic>) {
      final errors = data['errors'];

      if (errors is Map && errors.isNotEmpty) {
        final firstError = errors.values.first;

        if (firstError is List && firstError.isNotEmpty) {
          return firstError.first.toString();
        }
      }

      if (data['message'] != null) {
        return data['message'].toString();
      }
    }

    return 'Đã xảy ra lỗi. Vui lòng thử lại.';
  }
}
