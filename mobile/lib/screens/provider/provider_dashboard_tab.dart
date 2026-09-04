import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/ui/app_responsive.dart';
import '../../core/ui/app_theme.dart';
import '../../models/booking.dart';
import '../../models/service.dart';
import '../../providers/auth_provider.dart';
import '../../services/provider_booking_service.dart';
import '../../services/provider_service_api.dart';
import 'provider_booking_detail_screen.dart';
import '../../widgets/notification_bell_button.dart';

class ProviderDashboardTab extends StatefulWidget {
  const ProviderDashboardTab({super.key});

  @override
  State<ProviderDashboardTab> createState() => _ProviderDashboardTabState();
}

class _ProviderDashboardTabState extends State<ProviderDashboardTab> {
  final ProviderBookingService _bookingService = ProviderBookingService();

  final ProviderServiceApi _serviceApi = ProviderServiceApi();

  List<Booking> _bookings = [];
  List<Service> _services = [];

  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadDashboard();
  }

  Future<void> _loadDashboard() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final results = await Future.wait([
        _bookingService.getBookings(),
        _serviceApi.getServices(),
      ]);

      if (!mounted) return;

      setState(() {
        _bookings = results[0] as List<Booking>;
        _services = results[1] as List<Service>;
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

  int _countStatus(String status) {
    return _bookings.where((booking) => booking.status == status).length;
  }

  int get _activeServices {
    return _services.where((service) => service.status == 'ACTIVE').length;
  }

  List<Booking> get _pendingBookings {
    return _bookings
        .where((booking) => booking.status == 'PENDING')
        .take(2)
        .toList();
  }

  List<Booking> get _upcomingBookings {
    return _bookings
        .where((booking) => booking.status == 'ACCEPTED')
        .take(3)
        .toList();
  }

  String _money(double value) {
    return NumberFormat.currency(
      locale: 'vi_VN',
      symbol: 'đ',
      decimalDigits: 0,
    ).format(value);
  }

  Future<void> _openBooking(Booking booking) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProviderBookingDetailScreen(bookingId: booking.id),
      ),
    );

    _loadDashboard();
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;

    return RefreshIndicator(
      onRefresh: _loadDashboard,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverPadding(
            padding: EdgeInsets.fromLTRB(
              AppResponsive.horizontalPadding(context),
              20.rw(context),
              AppResponsive.horizontalPadding(context),
              20.rw(context),
            ),
            sliver: SliverToBoxAdapter(
              child: Row(
                children: [
                  _ProviderAvatar(imageUrl: user?.avatar, name: user?.name),

                  SizedBox(width: 12.rw(context)),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                'Xin chào, ${user?.name ?? 'Provider'}',
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 15.rf(context),
                                  fontWeight: FontWeight.w700,
                                  height: 1.2,
                                ),
                              ),
                            ),

                            SizedBox(width: 8.rw(context)),

                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 9.rw(context),
                                vertical: 4.rw(context),
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.softBlue,
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                'Provider',
                                style: TextStyle(
                                  fontSize: 11.5.rf(context),
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 4.rw(context)),

                        Text(
                          'Cùng xem hoạt động dịch vụ hôm nay',
                          style: TextStyle(
                            fontSize: 13.rf(context),
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 6.rw(context)),

                  const NotificationBellButton(audience: 'PROVIDER'),
                ],
              ),
            ),
          ),

          if (_isLoading)
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 80.rw(context)),
                child: const Center(child: CircularProgressIndicator()),
              ),
            )
          else if (_error != null)
            SliverPadding(
              padding: AppResponsive.pagePadding(context),
              sliver: SliverToBoxAdapter(
                child: _DashboardError(
                  message: _error!,
                  onRetry: _loadDashboard,
                ),
              ),
            )
          else ...[
            // STAT CARDS
            SliverPadding(
              padding: EdgeInsets.symmetric(
                horizontal: AppResponsive.horizontalPadding(context),
              ),
              sliver: SliverToBoxAdapter(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final gap = 12.rw(context);

                    final width = (constraints.maxWidth - gap) / 2;

                    return Wrap(
                      spacing: gap,
                      runSpacing: gap,
                      children: [
                        SizedBox(
                          width: width,
                          child: _StatCard(
                            icon: Icons.pending_actions_outlined,
                            value: '${_countStatus('PENDING')}',
                            label: 'Đơn chờ xác nhận',
                            iconColor: AppColors.warning,
                          ),
                        ),
                        SizedBox(
                          width: width,
                          child: _StatCard(
                            icon: Icons.handyman_outlined,
                            value: '${_countStatus('IN_PROGRESS')}',
                            label: 'Đang thực hiện',
                            iconColor: AppColors.primary,
                          ),
                        ),
                        SizedBox(
                          width: width,
                          child: _StatCard(
                            icon: Icons.check_circle_outline_rounded,
                            value: '${_countStatus('COMPLETED')}',
                            label: 'Đã hoàn thành',
                            iconColor: AppColors.success,
                          ),
                        ),
                        SizedBox(
                          width: width,
                          child: _StatCard(
                            icon: Icons.home_repair_service_outlined,
                            value: '$_activeServices',
                            label: 'Dịch vụ đang hoạt động',
                            iconColor: AppColors.primary,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),

            // PENDING
            SliverPadding(
              padding: EdgeInsets.fromLTRB(
                AppResponsive.horizontalPadding(context),
                28.rw(context),
                AppResponsive.horizontalPadding(context),
                12.rw(context),
              ),
              sliver: SliverToBoxAdapter(
                child: Text(
                  'Cần xử lý',
                  style: TextStyle(
                    fontSize: 23.rf(context),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),

            if (_pendingBookings.isEmpty)
              SliverPadding(
                padding: EdgeInsets.symmetric(
                  horizontal: AppResponsive.horizontalPadding(context),
                ),
                sliver: SliverToBoxAdapter(
                  child: _SimpleEmpty(
                    icon: Icons.check_circle_outline,
                    text: 'Không có đơn cần xử lý',
                  ),
                ),
              )
            else
              SliverPadding(
                padding: EdgeInsets.symmetric(
                  horizontal: AppResponsive.horizontalPadding(context),
                ),
                sliver: SliverList.separated(
                  itemCount: _pendingBookings.length,
                  separatorBuilder: (_, _) => SizedBox(height: 12.rw(context)),
                  itemBuilder: (context, index) {
                    final booking = _pendingBookings[index];

                    return _DashboardBookingCard(
                      booking: booking,
                      priceText: _money(booking.totalAmount),
                      pending: true,
                      onTap: () => _openBooking(booking),
                    );
                  },
                ),
              ),

            // UPCOMING
            SliverPadding(
              padding: EdgeInsets.fromLTRB(
                AppResponsive.horizontalPadding(context),
                28.rw(context),
                AppResponsive.horizontalPadding(context),
                12.rw(context),
              ),
              sliver: SliverToBoxAdapter(
                child: Text(
                  'Lịch sắp tới',
                  style: TextStyle(
                    fontSize: 23.rf(context),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),

            if (_upcomingBookings.isEmpty)
              SliverPadding(
                padding: EdgeInsets.fromLTRB(
                  AppResponsive.horizontalPadding(context),
                  0,
                  AppResponsive.horizontalPadding(context),
                  32.rw(context),
                ),
                sliver: SliverToBoxAdapter(
                  child: _SimpleEmpty(
                    icon: Icons.event_available_outlined,
                    text: 'Chưa có lịch sắp tới',
                  ),
                ),
              )
            else
              SliverPadding(
                padding: EdgeInsets.fromLTRB(
                  AppResponsive.horizontalPadding(context),
                  0,
                  AppResponsive.horizontalPadding(context),
                  32.rw(context),
                ),
                sliver: SliverList.separated(
                  itemCount: _upcomingBookings.length,
                  separatorBuilder: (_, _) => SizedBox(height: 12.rw(context)),
                  itemBuilder: (context, index) {
                    final booking = _upcomingBookings[index];

                    return _DashboardBookingCard(
                      booking: booking,
                      priceText: _money(booking.totalAmount),
                      pending: false,
                      onTap: () => _openBooking(booking),
                    );
                  },
                ),
              ),
          ],
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
          fontSize: 20.rf(context),
          fontWeight: FontWeight.w700,
          color: AppColors.primary,
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color iconColor;

  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(minHeight: 128.rw(context)),
      padding: EdgeInsets.all(16.rw(context)),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(17.rr(context)),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 24.ri(context), color: iconColor),
              SizedBox(width: 8.rw(context)),
              Text(
                value,
                style: TextStyle(
                  fontSize: 22.rf(context),
                  fontWeight: FontWeight.w700,
                  color: iconColor,
                ),
              ),
            ],
          ),
          SizedBox(height: 20.rw(context)),
          Text(
            label,
            style: TextStyle(
              fontSize: 13.5.rf(context),
              color: AppColors.textSecondary,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}

class _DashboardBookingCard extends StatelessWidget {
  final Booking booking;
  final String priceText;
  final bool pending;
  final VoidCallback onTap;

  const _DashboardBookingCard({
    required this.booking,
    required this.priceText,
    required this.pending,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(16.rr(context)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16.rr(context)),
        child: Container(
          padding: EdgeInsets.all(16.rw(context)),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.rr(context)),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      booking.serviceName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 17.rf(context),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  SizedBox(width: 8.rw(context)),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 9.rw(context),
                      vertical: 5.rw(context),
                    ),
                    decoration: BoxDecoration(
                      color: pending
                          ? const Color(0xFFFFF7ED)
                          : AppColors.softBlue,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      pending ? 'Chờ xác nhận' : 'Đã xác nhận',
                      style: TextStyle(
                        fontSize: 11.5.rf(context),
                        fontWeight: FontWeight.w600,
                        color: pending
                            ? const Color(0xFFD97706)
                            : AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 10.rw(context)),

              Row(
                children: [
                  Icon(
                    Icons.person_outline,
                    size: 18.ri(context),
                    color: AppColors.textSecondary,
                  ),
                  SizedBox(width: 6.rw(context)),
                  Expanded(
                    child: Text(
                      booking.customerName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13.5.rf(context),
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 10.rw(context)),

              Row(
                children: [
                  Icon(
                    Icons.calendar_month_outlined,
                    size: 18.ri(context),
                    color: AppColors.textSecondary,
                  ),
                  SizedBox(width: 6.rw(context)),
                  Expanded(
                    child: Text(
                      '${booking.bookingDate} • ${booking.bookingTime}',
                      style: TextStyle(
                        fontSize: 13.rf(context),
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),

              if (pending) ...[
                SizedBox(height: 12.rw(context)),
                const Divider(height: 1),
                SizedBox(height: 12.rw(context)),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        priceText,
                        style: TextStyle(
                          fontSize: 19.rf(context),
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.rw(context),
                        vertical: 8.rw(context),
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.softBlue,
                        borderRadius: BorderRadius.circular(10.rr(context)),
                      ),
                      child: const Text(
                        'Xem đơn',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _SimpleEmpty extends StatelessWidget {
  final IconData icon;
  final String text;

  const _SimpleEmpty({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20.rw(context)),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16.rr(context)),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.textSecondary),
          SizedBox(width: 10.rw(context)),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }
}

class _DashboardError extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _DashboardError({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Icon(Icons.error_outline, color: AppColors.error, size: 44),
        SizedBox(height: 12.rw(context)),
        Text(message, textAlign: TextAlign.center),
        SizedBox(height: 14.rw(context)),
        OutlinedButton(onPressed: onRetry, child: const Text('Thử lại')),
      ],
    );
  }
}
