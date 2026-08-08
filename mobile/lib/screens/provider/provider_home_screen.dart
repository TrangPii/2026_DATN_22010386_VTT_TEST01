import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';

class ProviderHomeScreen extends StatelessWidget {
  const ProviderHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Provider'),
        actions: [
          IconButton(onPressed: auth.logout, icon: const Icon(Icons.logout)),
        ],
      ),
      body: Center(
        child: Text(
          'Xin chào ${auth.user?.name}\nProvider Home',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
