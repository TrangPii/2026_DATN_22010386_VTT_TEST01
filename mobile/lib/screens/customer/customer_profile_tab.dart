import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/provider_application.dart';
import '../../providers/auth_provider.dart';
import '../../services/provider_application_service.dart';
import 'provider_application_screen.dart';

class CustomerProfileTab extends StatefulWidget {
  const CustomerProfileTab({super.key});

  @override
  State<CustomerProfileTab> createState() => _CustomerProfileTabState();
}

class _CustomerProfileTabState extends State<CustomerProfileTab> {
  final ProviderApplicationService _applicationService =
      ProviderApplicationService();

  bool _isOpeningApplication = false;

  Future<void> _openProviderApplication() async {
    if (_isOpeningApplication) {
      return;
    }

    setState(() {
      _isOpeningApplication = true;
    });

    try {
      final auth = context.read<AuthProvider>();

      ProviderApplication? application;

      if (auth.user?.hasProviderApplication == true) {
        application = await _applicationService.getApplication();
      }

      if (!mounted) {
        return;
      }

      final submitted = await Navigator.push<bool>(
        context,
        MaterialPageRoute(
          builder: (_) => ProviderApplicationScreen(application: application),
        ),
      );

      if (submitted == true && mounted) {
        await auth.refreshCurrentUser();
      }
    } on ProviderApplicationException catch (e) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.message)));
    } catch (_) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Không thể tải hồ sơ Nhà cung cấp.')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isOpeningApplication = false;
        });
      }
    }
  }

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
                subtitle: Text(
                  user?.phone?.isNotEmpty == true
                      ? user!.phone!
                      : 'Chưa cập nhật',
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        if (user != null) _buildProviderSection(context, auth),

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

  Widget _buildProviderSection(BuildContext context, AuthProvider auth) {
    final user = auth.user!;

    if (user.canUseProviderMode) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.verified_outlined),
                title: Text('Tài khoản Nhà cung cấp'),
                subtitle: Text('Hồ sơ của bạn đã được xác minh.'),
              ),

              const SizedBox(height: 8),

              FilledButton.icon(
                onPressed: () {
                  final success = auth.switchToProviderMode();

                  if (!success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Bạn chưa được cấp quyền Nhà cung cấp.'),
                      ),
                    );
                  }
                },
                icon: const Icon(Icons.storefront_outlined),
                label: const Text('Chuyển sang chế độ Nhà cung cấp'),
              ),
            ],
          ),
        ),
      );
    }

    if (user.isProviderPending) {
      return const Card(
        child: ListTile(
          leading: Icon(Icons.schedule_outlined),
          title: Text('Hồ sơ Nhà cung cấp đang chờ duyệt'),
          subtitle: Text(
            'Bạn vẫn có thể sử dụng đầy đủ chức năng Khách hàng trong thời gian chờ xét duyệt.',
          ),
        ),
      );
    }

    if (user.isProviderRejected) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.cancel_outlined),
                title: Text('Hồ sơ Nhà cung cấp bị từ chối'),
                subtitle: Text(
                  'Bạn có thể cập nhật thông tin và gửi lại hồ sơ.',
                ),
              ),

              const SizedBox(height: 8),

              FilledButton.tonalIcon(
                onPressed: _isOpeningApplication
                    ? null
                    : _openProviderApplication,
                icon: const Icon(Icons.edit_outlined),
                label: Text(
                  _isOpeningApplication ? 'Đang tải...' : 'Cập nhật và gửi lại',
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.storefront_outlined),
              title: Text('Trở thành Nhà cung cấp'),
              subtitle: Text(
                'Đăng ký để tạo dịch vụ và nhận đơn từ khách hàng.',
              ),
            ),

            const SizedBox(height: 8),

            FilledButton.icon(
              onPressed: _isOpeningApplication
                  ? null
                  : _openProviderApplication,
              icon: const Icon(Icons.assignment_outlined),
              label: Text(
                _isOpeningApplication
                    ? 'Đang tải...'
                    : 'Đăng ký trở thành Nhà cung cấp',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
