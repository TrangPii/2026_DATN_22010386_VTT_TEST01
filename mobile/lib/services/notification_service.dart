import 'dart:convert';

import '../core/constants/api_constants.dart';
import '../core/network/api_client.dart';
import '../models/app_notification.dart';

class NotificationServiceException implements Exception {
  final String message;

  const NotificationServiceException(this.message);

  @override
  String toString() => message;
}

class NotificationResult {
  final List<AppNotification> notifications;

  final int unreadCount;

  const NotificationResult({
    required this.notifications,
    required this.unreadCount,
  });
}

class NotificationService {
  Future<NotificationResult> getNotifications({
    required String audience,
  }) async {
    final endpoint =
        '${ApiConstants.notifications}'
        '?audience=$audience';

    final response = await ApiClient.get(endpoint, authenticated: true);

    final data = jsonDecode(response.body);

    if (response.statusCode != 200) {
      throw NotificationServiceException(_extractMessage(data));
    }

    final rawList = data['data']['notifications'] as List<dynamic>? ?? [];

    return NotificationResult(
      notifications: rawList
          .map(
            (item) => AppNotification.fromJson(
              Map<String, dynamic>.from(item as Map),
            ),
          )
          .toList(),

      unreadCount:
          int.tryParse(data['data']['unread_count']?.toString() ?? '0') ?? 0,
    );
  }

  Future<int> getUnreadCount({required String audience}) async {
    final response = await ApiClient.get(
      '${ApiConstants.notifications}'
      '/unread-count'
      '?audience=$audience',
      authenticated: true,
    );

    final data = jsonDecode(response.body);

    if (response.statusCode != 200) {
      throw NotificationServiceException(_extractMessage(data));
    }

    return int.tryParse(data['data']['unread_count']?.toString() ?? '0') ?? 0;
  }

  Future<void> markAsRead(String id) async {
    final response = await ApiClient.patch(
      '${ApiConstants.notifications}/$id/read',
      authenticated: true,
    );

    if (response.statusCode != 200) {
      final data = jsonDecode(response.body);

      throw NotificationServiceException(_extractMessage(data));
    }
  }

  Future<void> markAllAsRead({required String audience}) async {
    final response = await ApiClient.patch(
      '${ApiConstants.notifications}/read-all',
      authenticated: true,
      body: {'audience': audience},
    );

    if (response.statusCode != 200) {
      final data = jsonDecode(response.body);

      throw NotificationServiceException(_extractMessage(data));
    }
  }

  String _extractMessage(dynamic data) {
    if (data is Map<String, dynamic> && data['message'] != null) {
      return data['message'].toString();
    }

    return 'Đã xảy ra lỗi. Vui lòng thử lại.';
  }
}
