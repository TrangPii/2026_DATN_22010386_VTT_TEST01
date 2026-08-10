import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/ui/app_responsive.dart';
import '../../core/ui/app_theme.dart';
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

      if (!mounted) return;

      setState(() {
        _profile = profile;
      });
    } catch (e) {
      if (!mounted) return;

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

    if (profile == null) return;

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

  Color _verificationColor(String status) {
    switch (status) {
      case 'APPROVED':
        return AppColors.success;

      case 'PENDING':
        return AppColors.warning;

      case 'REJECTED':
        return AppColors.error;

      default:
        return AppColors.textSecondary;
    }
  }

  IconData _verificationIcon(String status) {
    switch (status) {
      case 'APPROVED':
        return Icons.verified_rounded;

      case 'PENDING':
        return Icons.schedule_rounded;

      case 'REJECTED':
        return Icons.cancel_outlined;

      default:
        return Icons.info_outline_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null || _profile == null) {
      return _ProfileError(
        message: _error ?? 'Không thể tải hồ sơ.',
        onRetry: _loadProfile,
        onCustomerMode: auth.switchToCustomerMode,
      );
    }

    final profile = _profile!;
    final user = profile.user;

    return RefreshIndicator(
      onRefresh: _loadProfile,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: AppResponsive.pagePadding(context, top: 22, bottom: 32),
        children: [
          Text(
            'Tài khoản',
            style: TextStyle(
              fontSize: 28.rf(context),
              fontWeight: FontWeight.w700,
            ),
          ),

          SizedBox(height: 20.rw(context)),

          // HEADER PROFILE
          Container(
            padding: EdgeInsets.all(20.rw(context)),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(20.rr(context)),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: [
                _ProviderAvatar(imageUrl: user?.avatar, name: user?.name),

                SizedBox(height: 14.rw(context)),

                Text(
                  profile.businessName,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 23.rf(context),
                    fontWeight: FontWeight.w700,
                    height: 1.25,
                  ),
                ),

                SizedBox(height: 5.rw(context)),

                Text(
                  user?.email ?? auth.user?.email ?? '',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13.5.rf(context),
                    color: AppColors.textSecondary,
                  ),
                ),

                SizedBox(height: 14.rw(context)),

                _VerificationBadge(
                  icon: _verificationIcon(profile.verificationStatus),
                  text: _verificationText(profile.verificationStatus),
                  color: _verificationColor(profile.verificationStatus),
                ),
              ],
            ),
          ),

          SizedBox(height: 16.rw(context)),

          // STATS
          LayoutBuilder(
            builder: (context, constraints) {
              final gap = 10.rw(context);

              final cardWidth = (constraints.maxWidth - gap * 2) / 3;

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: cardWidth,
                    child: _StatCard(
                      icon: Icons.star_rounded,
                      title: 'Đánh giá',
                      value: profile.averageRating.toStringAsFixed(1),
                    ),
                  ),

                  SizedBox(width: gap),

                  SizedBox(
                    width: cardWidth,
                    child: _StatCard(
                      icon: Icons.reviews_outlined,
                      title: 'Đánh giá',
                      value: profile.totalReviews.toString(),
                    ),
                  ),

                  SizedBox(width: gap),

                  SizedBox(
                    width: cardWidth,
                    child: _StatCard(
                      icon: Icons.work_outline,
                      title: 'Kinh nghiệm',
                      value: '${profile.experienceYears}',
                      suffix: 'năm',
                    ),
                  ),
                ],
              );
            },
          ),

          SizedBox(height: 18.rw(context)),

          // PROFILE INFO
          Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(17.rr(context)),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: [
                _ProfileRow(
                  icon: Icons.business_outlined,
                  title: 'Tên nhà cung cấp',
                  value: profile.businessName,
                ),

                const Divider(height: 1),

                _ProfileRow(
                  icon: Icons.location_on_outlined,
                  title: 'Địa chỉ',
                  value: profile.address?.trim().isNotEmpty == true
                      ? profile.address!
                      : 'Chưa cập nhật',
                ),

                const Divider(height: 1),

                _ProfileRow(
                  icon: Icons.phone_outlined,
                  title: 'Số điện thoại',
                  value: user?.phone?.trim().isNotEmpty == true
                      ? user!.phone!
                      : 'Chưa cập nhật',
                ),
              ],
            ),
          ),

          SizedBox(height: 18.rw(context)),

          // DESCRIPTION
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(18.rw(context)),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(17.rr(context)),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Giới thiệu',
                  style: TextStyle(
                    fontSize: 18.rf(context),
                    fontWeight: FontWeight.w700,
                  ),
                ),

                SizedBox(height: 9.rw(context)),

                Text(
                  profile.description?.trim().isNotEmpty == true
                      ? profile.description!
                      : 'Chưa có thông tin giới thiệu.',
                  style: TextStyle(
                    fontSize: 13.5.rf(context),
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 20.rw(context)),

          FilledButton.icon(
            onPressed: _editProfile,
            icon: const Icon(Icons.edit_outlined),
            label: const Text('Chỉnh sửa hồ sơ'),
          ),

          SizedBox(height: 12.rw(context)),

          OutlinedButton.icon(
            onPressed: auth.switchToCustomerMode,
            icon: const Icon(Icons.swap_horiz_rounded),
            label: const Text('Chuyển sang chế độ Khách hàng'),
          ),

          SizedBox(height: 12.rw(context)),

          OutlinedButton.icon(
            onPressed: auth.isLoading
                ? null
                : () async {
                    await auth.logout();
                  },
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.error,
              side: const BorderSide(color: AppColors.error),
            ),
            icon: const Icon(Icons.logout_rounded),
            label: const Text('Đăng xuất'),
          ),
        ],
      ),
    );
  }
}

class _ProviderAvatar extends StatelessWidget {
  final String? imageUrl;
  final String? name;

  const _ProviderAvatar({required this.imageUrl, required this.name});

  @override
  Widget build(BuildContext context) {
    final size = 92.rw(context);

    if (imageUrl != null && imageUrl!.trim().isNotEmpty) {
      return ClipOval(
        child: Image.network(
          imageUrl!,
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => _fallback(context, size),
        ),
      );
    }

    return _fallback(context, size);
  }

  Widget _fallback(BuildContext context, double size) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        color: AppColors.softBlue,
        shape: BoxShape.circle,
      ),
      child: Text(
        name?.trim().isNotEmpty == true ? name!.trim()[0].toUpperCase() : 'P',
        style: TextStyle(
          fontSize: 30.rf(context),
          fontWeight: FontWeight.w700,
          color: AppColors.primary,
        ),
      ),
    );
  }
}

class _VerificationBadge extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;

  const _VerificationBadge({
    required this.icon,
    required this.text,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 11.rw(context),
        vertical: 6.rw(context),
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 17.ri(context), color: color),

          SizedBox(width: 5.rw(context)),

          Text(
            text,
            style: TextStyle(
              fontSize: 12.rf(context),
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final String? suffix;

  const _StatCard({
    required this.icon,
    required this.title,
    required this.value,
    this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(minHeight: 104.rw(context)),
      padding: EdgeInsets.symmetric(
        horizontal: 8.rw(context),
        vertical: 13.rw(context),
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(15.rr(context)),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 21.ri(context), color: AppColors.primary),

          SizedBox(height: 6.rw(context)),

          FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 18.rf(context),
                    fontWeight: FontWeight.w700,
                  ),
                ),

                if (suffix != null) ...[
                  SizedBox(width: 3.rw(context)),
                  Text(
                    suffix!,
                    style: TextStyle(
                      fontSize: 11.rf(context),
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),

          SizedBox(height: 4.rw(context)),

          Text(
            title,
            maxLines: 2,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 11.rf(context),
              color: AppColors.textSecondary,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _ProfileRow({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(15.rw(context)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40.rw(context),
            height: 40.rw(context),
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: AppColors.softBlue,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 20.ri(context), color: AppColors.primary),
          ),

          SizedBox(width: 12.rw(context)),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12.rf(context),
                    color: AppColors.textSecondary,
                  ),
                ),

                SizedBox(height: 3.rw(context)),

                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14.5.rf(context),
                    fontWeight: FontWeight.w500,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileError extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  final VoidCallback onCustomerMode;

  const _ProfileError({
    required this.message,
    required this.onRetry,
    required this.onCustomerMode,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: AppResponsive.pagePadding(context),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 48.ri(context),
              color: AppColors.error,
            ),

            SizedBox(height: 12.rw(context)),

            Text(message, textAlign: TextAlign.center),

            SizedBox(height: 16.rw(context)),

            OutlinedButton(onPressed: onRetry, child: const Text('Thử lại')),

            SizedBox(height: 8.rw(context)),

            TextButton.icon(
              onPressed: onCustomerMode,
              icon: const Icon(Icons.person_outline_rounded),
              label: const Text('Quay lại chế độ Khách hàng'),
            ),
          ],
        ),
      ),
    );
  }
}
