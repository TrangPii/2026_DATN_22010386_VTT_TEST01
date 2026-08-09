import 'dart:convert';

import '../core/constants/api_constants.dart';
import '../core/network/api_client.dart';
import '../models/provider_application.dart';

class ProviderApplicationException implements Exception {
  final String message;

  const ProviderApplicationException(this.message);

  @override
  String toString() => message;
}

class ProviderApplicationService {
  Future<ProviderApplication?> getApplication() async {
    final response = await ApiClient.get(
      ApiConstants.providerApplication,
      authenticated: true,
    );

    final data = _decodeResponse(response.body);

    if (response.statusCode != 200) {
      throw ProviderApplicationException(_extractMessage(data));
    }

    final responseData = data['data'];

    if (responseData is! Map) {
      return null;
    }

    final application = responseData['application'];

    if (application == null) {
      return null;
    }

    if (application is! Map) {
      throw const ProviderApplicationException('Dữ liệu hồ sơ không hợp lệ.');
    }

    return ProviderApplication.fromJson(Map<String, dynamic>.from(application));
  }

  Future<ProviderApplication> submit({
    required String businessName,
    String? description,
    required String address,
    required String identityNumber,
    required int experienceYears,
  }) async {
    final response = await ApiClient.post(
      ApiConstants.providerApplication,
      authenticated: true,
      body: {
        'business_name': businessName.trim(),
        'description': description?.trim().isEmpty == true
            ? null
            : description?.trim(),
        'address': address.trim(),
        'identity_number': identityNumber.trim(),
        'experience_years': experienceYears,
      },
    );

    final data = _decodeResponse(response.body);

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw ProviderApplicationException(_extractMessage(data));
    }

    final responseData = data['data'];

    if (responseData is! Map) {
      throw const ProviderApplicationException('Không tìm thấy dữ liệu hồ sơ.');
    }

    final application = responseData['application'];

    if (application is! Map) {
      throw const ProviderApplicationException('Dữ liệu hồ sơ không hợp lệ.');
    }

    return ProviderApplication.fromJson(Map<String, dynamic>.from(application));
  }

  Map<String, dynamic> _decodeResponse(String body) {
    if (body.trim().isEmpty) {
      return <String, dynamic>{};
    }

    try {
      final decoded = jsonDecode(body);

      if (decoded is Map<String, dynamic>) {
        return decoded;
      }

      if (decoded is Map) {
        return Map<String, dynamic>.from(decoded);
      }

      return <String, dynamic>{};
    } catch (_) {
      return <String, dynamic>{};
    }
  }

  String _extractMessage(Map<String, dynamic> data) {
    final message = data['message'];

    if (message is String && message.isNotEmpty) {
      return message;
    }

    final errors = data['errors'];

    if (errors is Map) {
      for (final value in errors.values) {
        if (value is List && value.isNotEmpty) {
          return value.first.toString();
        }

        if (value is String && value.isNotEmpty) {
          return value;
        }
      }
    }

    return 'Có lỗi xảy ra. Vui lòng thử lại.';
  }
}
