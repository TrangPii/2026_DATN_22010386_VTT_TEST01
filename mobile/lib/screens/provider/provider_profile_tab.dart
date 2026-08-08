import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';

class ProviderProfileTab extends StatelessWidget {
  const ProviderProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    final user = auth.user;

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const SizedBox(height: 20),

        CircleAvatar(
          radius: 46,
          child: Text(
            user?.name.isNotEmpty == true ? user!.name[0].toUpperCase() : 'P',
            style: const TextStyle(fontSize: 32),
          ),
        ),

        const SizedBox(height: 16),

        Text(
          user?.name ?? '',
          textAlign: TextAlign.center,
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 6),

        Text(user?.email ?? '', textAlign: TextAlign.center),

        const SizedBox(height: 32),

        OutlinedButton.icon(
          onPressed: auth.isLoading ? null : auth.logout,
          icon: const Icon(Icons.logout),
          label: const Text('Đăng xuất'),
        ),
      ],
    );
  }
}
