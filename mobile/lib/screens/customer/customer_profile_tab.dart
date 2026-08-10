import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/ui/app_responsive.dart';
import '../../core/ui/app_theme.dart';
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
    if (_isOpeningApplication) return;

    setState(() {
      _isOpeningApplication = true;
    });

    try {
      final auth = context.read<AuthProvider>();

      ProviderApplication? application;

      if (auth.user?.hasProviderApplication == true) {
        application = await _applicationService.getApplication();
      }

      if (!mounted) return;

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
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.message)));
    } catch (_) {
      if (!mounted) return;

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

        // PROFILE CARD
        Container(
          padding: EdgeInsets.all(22.rw(context)),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20.rr(context)),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: [
              _ProfileAvatar(imageUrl: user?.avatar, name: user?.name),

              SizedBox(height: 14.rw(context)),

              Text(
                user?.name ?? '',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 23.rf(context),
                  fontWeight: FontWeight.w700,
                ),
              ),

              SizedBox(height: 6.rw(context)),

              Text(
                user?.email ?? '',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13.5.rf(context),
                  color: AppColors.textSecondary,
                ),
              ),

              if (user?.phone?.isNotEmpty == true) ...[
                SizedBox(height: 4.rw(context)),
                Text(
                  user!.phone!,
                  style: TextStyle(
                    fontSize: 13.5.rf(context),
                    color: AppColors.textSecondary,
                  ),
                ),
              ],

              SizedBox(height: 18.rw(context)),

              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 12.rw(context)),
                decoration: BoxDecoration(
                  color: AppColors.softBlue,
                  borderRadius: BorderRadius.circular(12.rr(context)),
                ),
                alignment: Alignment.center,
                child: Text(
                  'Thông tin cá nhân',
                  style: TextStyle(
                    fontSize: 14.rf(context),
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
        ),

        SizedBox(height: 18.rw(context)),

        // ACCOUNT INFO
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16.rr(context)),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: [
              _ProfileRow(
                icon: Icons.person_outline_rounded,
                title: 'Họ và tên',
                value: user?.name ?? '',
              ),

              const Divider(height: 1),

              _ProfileRow(
                icon: Icons.email_outlined,
                title: 'Email',
                value: user?.email ?? '',
              ),

              const Divider(height: 1),

              _ProfileRow(
                icon: Icons.phone_outlined,
                title: 'Số điện thoại',
                value: user?.phone?.isNotEmpty == true
                    ? user!.phone!
                    : 'Chưa cập nhật',
              ),
            ],
          ),
        ),

        SizedBox(height: 20.rw(context)),

        if (user != null) _buildProviderSection(context, auth),

        SizedBox(height: 24.rw(context)),

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
    );
  }

  Widget _buildProviderSection(BuildContext context, AuthProvider auth) {
    final user = auth.user!;

    // APPROVED
    if (user.canUseProviderMode) {
      return _ProviderCard(
        icon: Icons.verified_rounded,
        iconColor: AppColors.success,
        title: 'Tài khoản Nhà cung cấp đã được phê duyệt',
        description:
            'Bạn có thể chuyển sang chế độ Provider để quản lý dịch vụ và đơn hàng.',
        statusText: 'Đã phê duyệt',
        statusColor: AppColors.success,
        buttonText: 'Chuyển sang chế độ Provider',
        buttonIcon: Icons.storefront_outlined,
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
      );
    }

    // PENDING
    if (user.isProviderPending) {
      return _ProviderCard(
        icon: Icons.schedule_rounded,
        iconColor: AppColors.warning,
        title: 'Hồ sơ đang chờ xét duyệt',
        description:
            'Bạn vẫn có thể sử dụng đầy đủ chức năng Khách hàng trong thời gian chờ Admin phê duyệt.',
        statusText: 'Đang chờ xét duyệt',
        statusColor: AppColors.warning,
      );
    }

    // REJECTED
    if (user.isProviderRejected) {
      return _ProviderCard(
        icon: Icons.cancel_outlined,
        iconColor: AppColors.error,
        title: 'Hồ sơ Nhà cung cấp bị từ chối',
        description:
            'Bạn có thể cập nhật thông tin và gửi lại hồ sơ để Admin xét duyệt.',
        statusText: 'Đã từ chối',
        statusColor: AppColors.error,
        buttonText: _isOpeningApplication
            ? 'Đang tải...'
            : 'Cập nhật và gửi lại',
        buttonIcon: Icons.edit_outlined,
        onPressed: _isOpeningApplication ? null : _openProviderApplication,
      );
    }

    // NOT APPLIED
    return _ProviderCard(
      icon: Icons.storefront_outlined,
      iconColor: AppColors.primary,
      title: 'Bạn muốn cung cấp dịch vụ?',
      description:
          'Đăng ký trở thành nhà cung cấp để tạo dịch vụ và nhận đơn từ khách hàng.',
      buttonText: _isOpeningApplication
          ? 'Đang tải...'
          : 'Đăng ký trở thành Provider',
      buttonIcon: Icons.assignment_outlined,
      onPressed: _isOpeningApplication ? null : _openProviderApplication,
    );
  }
}

class _ProfileAvatar extends StatelessWidget {
  final String? imageUrl;
  final String? name;

  const _ProfileAvatar({required this.imageUrl, required this.name});

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
    final letter = name?.trim().isNotEmpty == true
        ? name!.trim()[0].toUpperCase()
        : 'U';

    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        color: AppColors.softBlue,
        shape: BoxShape.circle,
      ),
      child: Text(
        letter,
        style: TextStyle(
          fontSize: 30.rf(context),
          fontWeight: FontWeight.w700,
          color: AppColors.primary,
        ),
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
        children: [
          Container(
            width: 40.rw(context),
            height: 40.rw(context),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.softBlue,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.primary, size: 20.ri(context)),
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
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14.5.rf(context),
                    fontWeight: FontWeight.w500,
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

class _ProviderCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String description;

  final String? statusText;
  final Color? statusColor;

  final String? buttonText;
  final IconData? buttonIcon;
  final VoidCallback? onPressed;

  const _ProviderCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.description,
    this.statusText,
    this.statusColor,
    this.buttonText,
    this.buttonIcon,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(18.rw(context)),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(17.rr(context)),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44.rw(context),
                height: 44.rw(context),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12.rr(context)),
                ),
                child: Icon(icon, color: iconColor),
              ),

              SizedBox(width: 12.rw(context)),

              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 17.rf(context),
                    fontWeight: FontWeight.w700,
                    height: 1.3,
                  ),
                ),
              ),

              if (statusText != null)
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 9.rw(context),
                    vertical: 5.rw(context),
                  ),
                  decoration: BoxDecoration(
                    color: statusColor!.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    statusText!,
                    style: TextStyle(
                      fontSize: 11.5.rf(context),
                      fontWeight: FontWeight.w600,
                      color: statusColor,
                    ),
                  ),
                ),
            ],
          ),

          SizedBox(height: 12.rw(context)),

          Text(
            description,
            style: TextStyle(
              fontSize: 13.5.rf(context),
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),

          if (buttonText != null) ...[
            SizedBox(height: 16.rw(context)),

            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: onPressed,
                icon: Icon(buttonIcon),
                label: Text(buttonText!),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
