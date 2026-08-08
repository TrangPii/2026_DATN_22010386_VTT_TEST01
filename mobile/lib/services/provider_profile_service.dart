import 'dart:convert';

import '../core/constants/api_constants.dart';
import '../core/network/api_client.dart';
import '../models/provider_profile.dart';

class ProviderProfileException implements Exception {
  final String message;

  const ProviderProfileException(this.message);

  @override
  String toString() => message;
}

class ProviderProfileService {
  Future<ProviderProfile> getProfile() async {
    final response = await ApiClient.get(
      ApiConstants.providerProfile,
      authenticated: true,
    );

    final data = jsonDecode(response.body);

    if (response.statusCode != 200) {
      throw ProviderProfileException(_extractMessage(data));
    }

    return ProviderProfile.fromJson(
      Map<String, dynamic>.from(data['data']['profile'] as Map),
    );
  }

  Future<ProviderProfile> updateProfile({
    required String businessName,
    String? description,
    String? address,
    required int experienceYears,
  }) async {
    final response = await ApiClient.put(
      ApiConstants.providerProfile,
      authenticated: true,
      body: {
        'business_name': businessName.trim(),
        'description': description?.trim(),
        'address': address?.trim(),
        'experience_years': experienceYears,
      },
    );

    final data = jsonDecode(response.body);

    if (response.statusCode != 200) {
      throw ProviderProfileException(_extractMessage(data));
    }

    return ProviderProfile.fromJson(
      Map<String, dynamic>.from(data['data']['profile'] as Map),
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
