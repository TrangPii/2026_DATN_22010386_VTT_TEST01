import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/ui/app_responsive.dart';
import '../../core/ui/app_theme.dart';
import '../../models/service.dart';
import 'create_booking_screen.dart';

class ServiceDetailScreen extends StatelessWidget {
  final Service service;

  const ServiceDetailScreen({super.key, required this.service});

  String _formatPrice(double value) {
    return NumberFormat.currency(
      locale: 'vi_VN',
      symbol: 'đ',
      decimalDigits: 0,
    ).format(value);
  }

  @override
  Widget build(BuildContext context) {
    final provider = service.provider;

    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: AppBar(title: const Text('Chi tiết dịch vụ')),

      body: ListView(
        padding: EdgeInsets.only(bottom: 28.rw(context)),
        children: [
          // HERO IMAGE
          AspectRatio(
            aspectRatio: 16 / 10,
            child: _ServiceHeroImage(imageUrl: service.image),
          ),

          Transform.translate(
            offset: Offset(0, -28.rw(context)),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: AppResponsive.horizontalPadding(context),
              ),
              child: Column(
                children: [
                  // MAIN SERVICE CARD
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(18.rw(context)),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(18.rr(context)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 16,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (service.category != null)
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 11.rw(context),
                              vertical: 5.rw(context),
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.softBlue,
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              service.category!.name,
                              style: TextStyle(
                                fontSize: 12.5.rf(context),
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary,
                              ),
                            ),
                          ),

                        SizedBox(height: 14.rw(context)),

                        Text(
                          service.name,
                          style: TextStyle(
                            fontSize: 25.rf(context),
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                            height: 1.22,
                          ),
                        ),

                        SizedBox(height: 14.rw(context)),

                        Row(
                          children: [
                            Icon(
                              Icons.star_rounded,
                              size: 20.ri(context),
                              color: AppColors.warning,
                            ),
                            SizedBox(width: 5.rw(context)),
                            Text(
                              provider != null && provider.averageRating > 0
                                  ? provider.averageRating.toStringAsFixed(1)
                                  : 'Mới',
                              style: TextStyle(
                                fontSize: 15.rf(context),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            if (provider != null &&
                                provider.totalReviews > 0) ...[
                              SizedBox(width: 6.rw(context)),
                              Text(
                                '(${provider.totalReviews} đánh giá)',
                                style: TextStyle(
                                  fontSize: 14.rf(context),
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ],
                        ),

                        SizedBox(height: 20.rw(context)),

                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Flexible(
                              child: Text(
                                _formatPrice(service.price),
                                style: TextStyle(
                                  fontSize: 26.rf(context),
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(bottom: 3.rw(context)),
                              child: Text(
                                '/${service.priceUnit}',
                                style: TextStyle(
                                  fontSize: 14.rf(context),
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                          ],
                        ),

                        if (service.estimatedDurationMinutes != null) ...[
                          SizedBox(height: 12.rw(context)),
                          Row(
                            children: [
                              Icon(
                                Icons.schedule_outlined,
                                size: 18.ri(context),
                                color: AppColors.textSecondary,
                              ),
                              SizedBox(width: 7.rw(context)),
                              Text(
                                'Thời gian dự kiến: '
                                '${service.estimatedDurationMinutes} phút',
                                style: TextStyle(
                                  fontSize: 13.5.rf(context),
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),

                  SizedBox(height: 18.rw(context)),

                  // PROVIDER CARD
                  Container(
                    padding: EdgeInsets.all(16.rw(context)),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16.rr(context)),
                    ),
                    child: Row(
                      children: [
                        _ProviderAvatar(
                          imageUrl: provider?.avatar,
                          name: provider?.name,
                        ),

                        SizedBox(width: 14.rw(context)),

                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                provider?.businessName ??
                                    provider?.name ??
                                    'Nhà cung cấp',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 17.rf(context),
                                  fontWeight: FontWeight.w700,
                                ),
                              ),

                              SizedBox(height: 3.rw(context)),

                              Text(
                                'Nhà cung cấp dịch vụ',
                                style: TextStyle(
                                  fontSize: 12.5.rf(context),
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),

                        if (provider != null)
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 10.rw(context),
                              vertical: 7.rw(context),
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF5F3FF),
                              borderRadius: BorderRadius.circular(
                                9.rr(context),
                              ),
                            ),
                            child: Row(
                              children: [
                                Text(
                                  provider.averageRating > 0
                                      ? provider.averageRating.toStringAsFixed(
                                          1,
                                        )
                                      : 'Mới',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                SizedBox(width: 3.rw(context)),
                                const Icon(
                                  Icons.star_rounded,
                                  size: 17,
                                  color: AppColors.warning,
                                ),
                              ],
                            ),
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
                      borderRadius: BorderRadius.circular(16.rr(context)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Mô tả dịch vụ',
                          style: TextStyle(
                            fontSize: 19.rf(context),
                            fontWeight: FontWeight.w700,
                          ),
                        ),

                        SizedBox(height: 12.rw(context)),

                        Text(
                          service.description?.trim().isNotEmpty == true
                              ? service.description!
                              : 'Nhà cung cấp chưa cập nhật mô tả cho dịch vụ này.',
                          style: TextStyle(
                            fontSize: 14.rf(context),
                            color: AppColors.textSecondary,
                            height: 1.55,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),

      // STICKY BOTTOM ACTION
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          padding: EdgeInsets.fromLTRB(
            AppResponsive.horizontalPadding(context),
            12.rw(context),
            AppResponsive.horizontalPadding(context),
            12.rw(context),
          ),
          decoration: const BoxDecoration(
            color: AppColors.surface,
            border: Border(top: BorderSide(color: AppColors.border)),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Giá dịch vụ',
                      style: TextStyle(
                        fontSize: 12.rf(context),
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      '${_formatPrice(service.price)}/${service.priceUnit}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 19.rf(context),
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(width: 14.rw(context)),

              SizedBox(
                width: 140.rw(context),
                child: FilledButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CreateBookingScreen(service: service),
                      ),
                    );
                  },
                  child: const Text('Đặt dịch vụ'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ServiceHeroImage extends StatelessWidget {
  final String? imageUrl;

  const _ServiceHeroImage({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    if (imageUrl == null || imageUrl!.trim().isEmpty) {
      return Container(
        color: AppColors.softGray,
        child: Icon(
          Icons.home_repair_service_rounded,
          size: 72.ri(context),
          color: AppColors.textSecondary,
        ),
      );
    }

    return Image.network(
      imageUrl!,
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) => Container(
        color: AppColors.softGray,
        child: Icon(
          Icons.home_repair_service_rounded,
          size: 72.ri(context),
          color: AppColors.textSecondary,
        ),
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
    final size = 54.rw(context);

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
        : 'P';

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
          fontSize: 20.rf(context),
          fontWeight: FontWeight.w700,
          color: AppColors.primary,
        ),
      ),
    );
  }
}
