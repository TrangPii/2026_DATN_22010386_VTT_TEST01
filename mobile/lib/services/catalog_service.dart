import 'dart:convert';

import '../core/constants/api_constants.dart';
import '../core/network/api_client.dart';
import '../models/service.dart';
import '../models/service_category.dart';

class CatalogException implements Exception {
  final String message;

  const CatalogException(this.message);

  @override
  String toString() => message;
}

class CatalogService {
  Future<List<ServiceCategory>> getCategories() async {
    final response = await ApiClient.get(ApiConstants.categories);

    if (response.statusCode != 200) {
      throw const CatalogException('Không thể tải danh mục dịch vụ.');
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;

    final data = json['data'] as Map<String, dynamic>;

    final categories = data['categories'] as List<dynamic>;

    return categories
        .map(
          (item) =>
              ServiceCategory.fromJson(Map<String, dynamic>.from(item as Map)),
        )
        .toList();
  }

  Future<List<Service>> getServices({int? categoryId, String? search}) async {
    final parameters = <String, String>{};

    if (categoryId != null) {
      parameters['category_id'] = categoryId.toString();
    }

    if (search != null && search.trim().isNotEmpty) {
      parameters['search'] = search.trim();
    }

    var endpoint = ApiConstants.services;

    if (parameters.isNotEmpty) {
      endpoint = '$endpoint?${Uri(queryParameters: parameters).query}';
    }

    final response = await ApiClient.get(endpoint);

    if (response.statusCode != 200) {
      throw const CatalogException('Không thể tải danh sách dịch vụ.');
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;

    final data = json['data'] as Map<String, dynamic>;

    final services = data['services'] as List<dynamic>;

    return services
        .map((item) => Service.fromJson(Map<String, dynamic>.from(item as Map)))
        .toList();
  }

  Future<Service> getServiceDetail(int id) async {
    final response = await ApiClient.get('${ApiConstants.services}/$id');

    if (response.statusCode != 200) {
      throw const CatalogException('Không thể tải thông tin dịch vụ.');
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;

    final data = json['data'] as Map<String, dynamic>;

    return Service.fromJson(Map<String, dynamic>.from(data['service'] as Map));
  }
}
