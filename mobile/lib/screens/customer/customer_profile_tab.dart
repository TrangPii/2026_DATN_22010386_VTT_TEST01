import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';

class CustomerProfileTab extends StatelessWidget {
  const CustomerProfileTab({super.key});

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
            user?.name.isNotEmpty == true ? user!.name[0].toUpperCase() : 'U',
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

        Card(
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.email_outlined),
                title: const Text('Email'),
                subtitle: Text(user?.email ?? ''),
              ),

              const Divider(height: 1),

              ListTile(
                leading: const Icon(Icons.phone_outlined),
                title: const Text('Số điện thoại'),
                subtitle: Text(user?.phone ?? 'Chưa cập nhật'),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        OutlinedButton.icon(
          onPressed: auth.isLoading
              ? null
              : () async {
                  await auth.logout();
                },
          icon: const Icon(Icons.logout),
          label: const Text('Đăng xuất'),
        ),
      ],
    );
  }
}
