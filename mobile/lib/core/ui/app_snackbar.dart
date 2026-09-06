import 'package:flutter/material.dart';

class AppSnackBar {
  AppSnackBar._();

  static const Duration duration = Duration(seconds: 2);

  static void show(
    BuildContext context,
    String message, {
    SnackBarBehavior behavior = SnackBarBehavior.floating,
  }) {
    final messenger = ScaffoldMessenger.of(context);

    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          duration: duration,
          behavior: behavior,
        ),
      );
  }
}
