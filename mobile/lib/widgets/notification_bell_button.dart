import 'package:flutter/material.dart';

import '../core/ui/app_responsive.dart';
import '../core/ui/app_theme.dart';
import '../screens/common/notification_screen.dart';
import '../services/notification_service.dart';

class NotificationBellButton extends StatefulWidget {
  final String audience;

  const NotificationBellButton({super.key, required this.audience});

  @override
  State<NotificationBellButton> createState() => _NotificationBellButtonState();
}

class _NotificationBellButtonState extends State<NotificationBellButton> {
  final NotificationService _notificationService = NotificationService();

  int _unreadCount = 0;

  @override
  void initState() {
    super.initState();

    _loadUnreadCount();
  }

  Future<void> _loadUnreadCount() async {
    try {
      final count = await _notificationService.getUnreadCount(
        audience: widget.audience,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _unreadCount = count;
      });
    } catch (_) {}
  }

  Future<void> _openNotifications() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => NotificationScreen(audience: widget.audience),
      ),
    );

    await _loadUnreadCount();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        IconButton(
          tooltip: 'Thông báo',

          onPressed: _openNotifications,

          icon: const Icon(Icons.notifications_none_rounded),
        ),

        if (_unreadCount > 0)
          Positioned(
            right: 2.rw(context),
            top: 1.rw(context),
            child: Container(
              constraints: BoxConstraints(
                minWidth: 17.rw(context),
                minHeight: 17.rw(context),
              ),
              padding: EdgeInsets.symmetric(horizontal: 4.rw(context)),
              decoration: const BoxDecoration(
                color: AppColors.error,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                _unreadCount > 9 ? '9+' : '$_unreadCount',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 9.rf(context),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
