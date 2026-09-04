import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/ui/app_responsive.dart';
import '../../core/ui/app_theme.dart';
import '../../models/app_notification.dart';
import '../../services/notification_service.dart';
import '../customer/booking_detail_screen.dart';
import '../customer/provider_application_screen.dart';
import '../provider/provider_booking_detail_screen.dart';

class NotificationScreen extends StatefulWidget {
  final String audience;

  const NotificationScreen({super.key, required this.audience});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final NotificationService _notificationService = NotificationService();

  List<AppNotification> _notifications = [];

  bool _isLoading = true;

  int _unreadCount = 0;

  @override
  void initState() {
    super.initState();

    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    try {
      final result = await _notificationService.getNotifications(
        audience: widget.audience,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _notifications = result.notifications;

        _unreadCount = result.unreadCount;
      });
    } on NotificationServiceException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.message)));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Future<void> _markAsRead(AppNotification notification) async {
  //   if (notification.isRead) {
  //     return;
  //   }

  //   try {
  //     await _notificationService.markAsRead(notification.id);

  //     await _loadNotifications();
  //   } on NotificationServiceException catch (e) {
  //     if (mounted) {
  //       ScaffoldMessenger.of(
  //         context,
  //       ).showSnackBar(SnackBar(content: Text(e.message)));
  //     }
  //   }
  // }

  Future<void> _markAllAsRead() async {
    try {
      await _notificationService.markAllAsRead(audience: widget.audience);

      await _loadNotifications();
    } on NotificationServiceException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.message)));
      }
    }
  }

  Future<void> _openNotification(AppNotification notification) async {
    try {
      if (!notification.isRead) {
        await _notificationService.markAsRead(notification.id);
      }

      if (!mounted) {
        return;
      }

      await _navigateToTarget(notification);

      if (mounted) {
        await _loadNotifications();
      }
    } on NotificationServiceException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.message)));
      }
    }
  }

  Future<void> _navigateToTarget(AppNotification notification) async {
    switch (notification.target) {
      case 'CUSTOMER_BOOKING_DETAIL':
        if (notification.bookingId == null) {
          return;
        }

        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                BookingDetailScreen(bookingId: notification.bookingId!),
          ),
        );

        break;

      case 'PROVIDER_BOOKING_DETAIL':
        if (notification.bookingId == null) {
          return;
        }

        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                ProviderBookingDetailScreen(bookingId: notification.bookingId!),
          ),
        );

        break;

      case 'PROVIDER_APPLICATION':
        await _openProviderApplication();
        break;

      default:
        break;
    }
  }

  Future<void> _openProviderApplication() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ProviderApplicationScreen()),
    );
  }

  IconData _iconFor(String? type) {
    switch (type) {
      case 'BOOKING_CREATED':
        return Icons.receipt_long_outlined;

      case 'BOOKING_STATUS_CHANGED':
        return Icons.event_available_outlined;

      case 'PROVIDER_APPLICATION_APPROVED':
        return Icons.verified_outlined;

      case 'PROVIDER_APPLICATION_REJECTED':
        return Icons.cancel_outlined;

      case 'BOOKING_CANCELLED_BY_CUSTOMER':
        return Icons.cancel_outlined;

      case 'BOOKING_REMINDER':
        return Icons.schedule_outlined;

      default:
        return Icons.notifications_outlined;
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) {
      return '';
    }

    return DateFormat('HH:mm - dd/MM/yyyy').format(date.toLocal());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: AppBar(
        title: const Text('Thông báo'),

        actions: [
          if (_unreadCount > 0)
            TextButton(
              onPressed: _markAllAsRead,

              child: const Text('Đọc tất cả'),
            ),
        ],
      ),

      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadNotifications,

              child: _notifications.isEmpty
                  ? ListView(
                      padding: AppResponsive.pagePadding(context),
                      children: [
                        SizedBox(height: 160.rw(context)),

                        Icon(
                          Icons.notifications_none_rounded,
                          size: 58.ri(context),
                          color: AppColors.textSecondary,
                        ),

                        SizedBox(height: 14.rw(context)),

                        Text(
                          'Chưa có thông báo',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 18.rf(context),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    )
                  : ListView.separated(
                      padding: AppResponsive.pagePadding(
                        context,
                        top: 12,
                        bottom: 30,
                      ),

                      itemCount: _notifications.length,

                      separatorBuilder: (_, __) =>
                          SizedBox(height: 10.rw(context)),

                      itemBuilder: (context, index) {
                        final item = _notifications[index];

                        return Material(
                          color: item.isRead
                              ? AppColors.surface
                              : AppColors.softBlue,

                          borderRadius: BorderRadius.circular(16.rr(context)),

                          child: InkWell(
                            onTap: () => _openNotification(item),

                            borderRadius: BorderRadius.circular(16.rr(context)),

                            child: Padding(
                              padding: EdgeInsets.all(16.rw(context)),

                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,

                                children: [
                                  Container(
                                    width: 44.rw(context),
                                    height: 44.rw(context),
                                    decoration: BoxDecoration(
                                      color: AppColors.surface,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      _iconFor(item.type),
                                      color: AppColors.primary,
                                    ),
                                  ),

                                  SizedBox(width: 12.rw(context)),

                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,

                                      children: [
                                        Text(
                                          item.title,
                                          style: TextStyle(
                                            fontSize: 15.rf(context),
                                            fontWeight: item.isRead
                                                ? FontWeight.w600
                                                : FontWeight.w700,
                                            color: AppColors.textPrimary,
                                          ),
                                        ),

                                        SizedBox(height: 5.rw(context)),

                                        Text(
                                          item.message,
                                          style: TextStyle(
                                            fontSize: 13.rf(context),
                                            height: 1.4,
                                            color: AppColors.textSecondary,
                                          ),
                                        ),

                                        SizedBox(height: 7.rw(context)),

                                        Text(
                                          _formatDate(item.createdAt),
                                          style: TextStyle(
                                            fontSize: 11.5.rf(context),
                                            color: AppColors.textSecondary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  if (!item.isRead)
                                    Padding(
                                      padding: EdgeInsets.only(
                                        left: 8.rw(context),
                                        top: 5.rw(context),
                                      ),
                                      child: Container(
                                        width: 8.rw(context),
                                        height: 8.rw(context),
                                        decoration: const BoxDecoration(
                                          color: AppColors.primary,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
    );
  }
}
