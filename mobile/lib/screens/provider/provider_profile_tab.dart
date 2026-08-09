import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/provider_profile.dart';
import '../../providers/auth_provider.dart';
import '../../services/provider_profile_service.dart';
import 'provider_profile_edit_screen.dart';

class ProviderProfileTab extends StatefulWidget {
  const ProviderProfileTab({super.key});

  @override
  State<ProviderProfileTab> createState() => _ProviderProfileTabState();
}

class _ProviderProfileTabState extends State<ProviderProfileTab> {
  final ProviderProfileService _profileService = ProviderProfileService();

  ProviderProfile? _profile;

  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();

    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final profile = await _profileService.getProfile();

      if (!mounted) {
        return;
      }

      setState(() {
        _profile = profile;
      });
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        _error = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _editProfile() async {
    final profile = _profile;

    if (profile == null) {
      return;
    }

    final updated = await Navigator.push<ProviderProfile>(
      context,
      MaterialPageRoute(
        builder: (_) => ProviderProfileEditScreen(profile: profile),
      ),
    );

    if (updated != null && mounted) {
      setState(() {
        _profile = updated;
      });
    }
  }

  String _verificationText(String status) {
    switch (status) {
      case 'APPROVED':
        return 'Đã xác minh';

      case 'PENDING':
        return 'Đang chờ xác minh';

      case 'REJECTED':
        return 'Bị từ chối';

      default:
        return status;
    }
  }

  IconData _verificationIcon(String status) {
    switch (status) {
      case 'APPROVED':
        return Icons.verified;

      case 'PENDING':
        return Icons.schedule;

      case 'REJECTED':
        return Icons.cancel_outlined;

      default:
        return Icons.info_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null || _profile == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48),

              const SizedBox(height: 12),

              Text(
                _error ?? 'Không thể tải hồ sơ.',
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 12),

              OutlinedButton(
                onPressed: _loadProfile,
                child: const Text('Thử lại'),
              ),

              const SizedBox(height: 12),

              // Trong trường hợp Provider permission đã bị Admin thu hồi trong khi app vẫn đang ở Provider Mode
              TextButton.icon(
                onPressed: auth.switchToCustomerMode,
                icon: const Icon(Icons.person_outline),
                label: const Text('Quay lại chế độ Khách hàng'),
              ),
            ],
          ),
        ),
      );
    }

    final profile = _profile!;
    final user = profile.user;

    return RefreshIndicator(
      onRefresh: _loadProfile,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const SizedBox(height: 8),

          Center(
            child: CircleAvatar(
              radius: 48,
              child: Text(
                user?.name.isNotEmpty == true
                    ? user!.name[0].toUpperCase()
                    : 'P',
                style: const TextStyle(fontSize: 32),
              ),
            ),
          ),

          const SizedBox(height: 16),

          Text(
            profile.businessName,
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 6),

          Text(
            user?.email ?? auth.user?.email ?? '',
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 20),

          Center(
            child: Chip(
              avatar: Icon(_verificationIcon(profile.verificationStatus)),
              label: Text(_verificationText(profile.verificationStatus)),
            ),
          ),

          const SizedBox(height: 24),

          Row(
            children: [
              Expanded(
                child: _StatCard(
                  icon: Icons.star,
                  title: 'Đánh giá',
                  value: profile.averageRating.toStringAsFixed(1),
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: _StatCard(
                  icon: Icons.reviews_outlined,
                  title: 'Lượt đánh giá',
                  value: profile.totalReviews.toString(),
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: _StatCard(
                  icon: Icons.work_outline,
                  title: 'Kinh nghiệm',
                  value: '${profile.experienceYears} năm',
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.business_outlined),
                  title: const Text('Tên nhà cung cấp'),
                  subtitle: Text(profile.businessName),
                ),

                const Divider(height: 1),

                ListTile(
                  leading: const Icon(Icons.location_on_outlined),
                  title: const Text('Địa chỉ'),
                  subtitle: Text(
                    profile.address?.isNotEmpty == true
                        ? profile.address!
                        : 'Chưa cập nhật',
                  ),
                ),

                const Divider(height: 1),

                ListTile(
                  leading: const Icon(Icons.description_outlined),
                  title: const Text('Giới thiệu'),
                  subtitle: Text(
                    profile.description?.isNotEmpty == true
                        ? profile.description!
                        : 'Chưa cập nhật',
                  ),
                ),

                if (user?.phone?.isNotEmpty == true) ...[
                  const Divider(height: 1),

                  ListTile(
                    leading: const Icon(Icons.phone_outlined),
                    title: const Text('Số điện thoại'),
                    subtitle: Text(user!.phone!),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 20),

          FilledButton.icon(
            onPressed: _editProfile,
            icon: const Icon(Icons.edit_outlined),
            label: const Text('Cập nhật hồ sơ'),
          ),

          const SizedBox(height: 12),

          FilledButton.tonalIcon(
            onPressed: auth.switchToCustomerMode,
            icon: const Icon(Icons.swap_horiz),
            label: const Text('Chuyển sang chế độ Khách hàng'),
          ),

          const SizedBox(height: 12),

          OutlinedButton.icon(
            onPressed: auth.isLoading
                ? null
                : () async {
                    await auth.logout();
                  },
            icon: const Icon(Icons.logout),
            label: const Text('Đăng xuất'),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _StatCard({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        child: Column(
          children: [
            Icon(icon),

            const SizedBox(height: 8),

            Text(
              value,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 4),

            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
