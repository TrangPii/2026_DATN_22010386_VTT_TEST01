import 'dart:convert';

import '../core/constants/api_constants.dart';
import '../core/network/api_client.dart';
import '../models/service.dart';

class ProviderServiceException implements Exception {
  final String message;

  const ProviderServiceException(this.message);

  @override
  String toString() => message;
}

class ProviderServiceApi {
  Future<List<Service>> getServices({
    String? status,
    int? categoryId,
    String? search,
  }) async {
    final params = <String, String>{};

    if (status != null && status.isNotEmpty) {
      params['status'] = status;
    }

    if (categoryId != null) {
      params['category_id'] = categoryId.toString();
    }

    if (search != null && search.trim().isNotEmpty) {
      params['search'] = search.trim();
    }

    var endpoint = ApiConstants.providerServices;

    if (params.isNotEmpty) {
      endpoint += '?${Uri(queryParameters: params).query}';
    }

    final response = await ApiClient.get(endpoint, authenticated: true);

    final data = jsonDecode(response.body);

    if (response.statusCode != 200) {
      throw ProviderServiceException(_extractMessage(data));
    }

    final services = data['data']['services'] as List<dynamic>;

    return services
        .map((item) => Service.fromJson(Map<String, dynamic>.from(item as Map)))
        .toList();
  }

  Future<Service> getService(int id) async {
    final response = await ApiClient.get(
      '${ApiConstants.providerServices}/$id',
      authenticated: true,
    );

    final data = jsonDecode(response.body);

    if (response.statusCode != 200) {
      throw ProviderServiceException(_extractMessage(data));
    }

    return Service.fromJson(
      Map<String, dynamic>.from(data['data']['service'] as Map),
    );
  }

  Future<Service> createService({
    required int categoryId,
    required String name,
    String? description,
    required double price,
    required String priceUnit,
    int? estimatedDurationMinutes,
    String? image,
  }) async {
    final response = await ApiClient.post(
      ApiConstants.providerServices,
      authenticated: true,
      body: {
        'category_id': categoryId,
        'name': name.trim(),
        'description': description?.trim(),
        'price': price,
        'price_unit': priceUnit.trim(),
        'estimated_duration_minutes': estimatedDurationMinutes,
        'image': image?.trim(),
      },
    );

    final data = jsonDecode(response.body);

    if (response.statusCode != 201) {
      throw ProviderServiceException(_extractMessage(data));
    }

    return Service.fromJson(
      Map<String, dynamic>.from(data['data']['service'] as Map),
    );
  }

  Future<Service> updateService({
    required int id,
    required int categoryId,
    required String name,
    String? description,
    required double price,
    required String priceUnit,
    int? estimatedDurationMinutes,
    String? image,
  }) async {
    final response = await ApiClient.put(
      '${ApiConstants.providerServices}/$id',
      authenticated: true,
      body: {
        'category_id': categoryId,
        'name': name.trim(),
        'description': description?.trim(),
        'price': price,
        'price_unit': priceUnit.trim(),
        'estimated_duration_minutes': estimatedDurationMinutes,
        'image': image?.trim(),
      },
    );

    final data = jsonDecode(response.body);

    if (response.statusCode != 200) {
      throw ProviderServiceException(_extractMessage(data));
    }

    return Service.fromJson(
      Map<String, dynamic>.from(data['data']['service'] as Map),
    );
  }

  Future<Service> updateStatus({
    required int id,
    required String status,
  }) async {
    final response = await ApiClient.patch(
      '${ApiConstants.providerServices}/$id/status',
      authenticated: true,
      body: {'status': status},
    );

    final data = jsonDecode(response.body);

    if (response.statusCode != 200) {
      throw ProviderServiceException(_extractMessage(data));
    }

    return Service.fromJson(
      Map<String, dynamic>.from(data['data']['service'] as Map),
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
