import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/ui/app_responsive.dart';
import '../../core/ui/app_theme.dart';
import '../../models/booking.dart';
import '../../services/provider_booking_service.dart';
import 'provider_booking_detail_screen.dart';

class ProviderBookingsTab extends StatefulWidget {
  const ProviderBookingsTab({super.key});

  @override
  State<ProviderBookingsTab> createState() => _ProviderBookingsTabState();
}

class _ProviderBookingsTabState extends State<ProviderBookingsTab> {
  final ProviderBookingService _bookingService = ProviderBookingService();

  List<Booking> _bookings = [];

  bool _isLoading = true;
  String? _error;

  String? _selectedStatus;

  static const List<String> _statuses = [
    'PENDING',
    'ACCEPTED',
    'IN_PROGRESS',
    'COMPLETED',
    'REJECTED',
    'CANCELLED',
  ];

  @override
  void initState() {
    super.initState();
    _loadBookings();
  }

  Future<void> _loadBookings() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final bookings = await _bookingService.getBookings(
        status: _selectedStatus,
      );

      if (!mounted) return;

      setState(() {
        _bookings = bookings;
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

  Future<void> _changeStatus(String? status) async {
    if (_selectedStatus == status) return;

    setState(() {
      _selectedStatus = status;
    });

    await _loadBookings();
  }

  String _money(double value) {
    return NumberFormat.currency(
      locale: 'vi_VN',
      symbol: 'đ',
      decimalDigits: 0,
    ).format(value);
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _loadBookings,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverPadding(
            padding: EdgeInsets.fromLTRB(
              AppResponsive.horizontalPadding(context),
              24.rw(context),
              AppResponsive.horizontalPadding(context),
              16.rw(context),
            ),
            sliver: SliverToBoxAdapter(
              child: Text(
                'Quản lý đơn hàng',
                style: TextStyle(
                  fontSize: 28.rf(context),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(
                horizontal: AppResponsive.horizontalPadding(context),
              ),
              child: Row(
                children: [
                  _Filter(
                    label: 'Tất cả',
                    selected: _selectedStatus == null,
                    onTap: () => _changeStatus(null),
                  ),

                  ..._statuses.map(
                    (status) => Padding(
                      padding: EdgeInsets.only(left: 9.rw(context)),
                      child: _Filter(
                        label: providerBookingStatusLabel(status),
                        selected: _selectedStatus == status,
                        onTap: () => _changeStatus(status),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          SliverToBoxAdapter(child: SizedBox(height: 22.rw(context))),

          if (_isLoading)
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 60.rw(context)),
                child: const Center(child: CircularProgressIndicator()),
              ),
            )
          else if (_error != null)
            SliverPadding(
              padding: AppResponsive.pagePadding(context),
              sliver: SliverToBoxAdapter(
                child: Column(
                  children: [
                    Text(_error!, textAlign: TextAlign.center),
                    SizedBox(height: 12.rw(context)),
                    OutlinedButton(
                      onPressed: _loadBookings,
                      child: const Text('Thử lại'),
                    ),
                  ],
                ),
              ),
            )
          else if (_bookings.isEmpty)
            SliverPadding(
              padding: AppResponsive.pagePadding(context),
              sliver: const SliverToBoxAdapter(child: _EmptyBookings()),
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
                itemCount: _bookings.length,
                separatorBuilder: (_, _) => SizedBox(height: 14.rw(context)),
                itemBuilder: (context, index) {
                  final booking = _bookings[index];

                  return _ProviderBookingCard(
                    booking: booking,
                    priceText: _money(booking.totalAmount),
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ProviderBookingDetailScreen(
                            bookingId: booking.id,
                          ),
                        ),
                      );

                      _loadBookings();
                    },
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

class _Filter extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _Filter({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.primary : AppColors.surface,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: 17.rw(context),
            vertical: 10.rw(context),
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: selected ? AppColors.primary : AppColors.border,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13.5.rf(context),
              fontWeight: FontWeight.w600,
              color: selected ? Colors.white : AppColors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }
}

class _ProviderBookingCard extends StatelessWidget {
  final Booking booking;
  final String priceText;
  final VoidCallback onTap;

  const _ProviderBookingCard({
    required this.booking,
    required this.priceText,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final visual = _statusVisual(booking.status);

    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(17.rr(context)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(17.rr(context)),
        child: Container(
          padding: EdgeInsets.all(16.rw(context)),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(17.rr(context)),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
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
                      color: visual.background,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      providerBookingStatusLabel(booking.status),
                      style: TextStyle(
                        fontSize: 11.5.rf(context),
                        fontWeight: FontWeight.w600,
                        color: visual.foreground,
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 14.rw(context)),

              _InfoLine(
                icon: Icons.person_outline_rounded,
                text: 'Khách hàng: ${booking.customerName}',
              ),

              SizedBox(height: 8.rw(context)),

              _InfoLine(
                icon: Icons.calendar_month_outlined,
                text: '${booking.bookingDate} • ${booking.bookingTime}',
              ),

              SizedBox(height: 8.rw(context)),

              _InfoLine(
                icon: Icons.location_on_outlined,
                text: booking.serviceAddress,
              ),

              SizedBox(height: 14.rw(context)),

              const Divider(height: 1),

              SizedBox(height: 13.rw(context)),

              Row(
                children: [
                  Expanded(
                    child: Text(
                      priceText,
                      style: TextStyle(
                        fontSize: 20.rf(context),
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ),

                  const Icon(
                    Icons.chevron_right_rounded,
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoLine extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoLine({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18.ri(context), color: AppColors.textSecondary),
        SizedBox(width: 7.rw(context)),
        Expanded(
          child: Text(
            text,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 13.5.rf(context),
              color: AppColors.textSecondary,
              height: 1.35,
            ),
          ),
        ),
      ],
    );
  }
}

class _EmptyBookings extends StatelessWidget {
  const _EmptyBookings();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(
          Icons.receipt_long_outlined,
          size: 52.ri(context),
          color: AppColors.textSecondary,
        ),
        SizedBox(height: 12.rw(context)),
        Text(
          'Chưa có đơn hàng',
          style: TextStyle(
            fontSize: 18.rf(context),
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(height: 5.rw(context)),
        const Text(
          'Khi khách hàng đặt dịch vụ của bạn, đơn hàng sẽ xuất hiện tại đây.',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColors.textSecondary),
        ),
      ],
    );
  }
}

String providerBookingStatusLabel(String status) {
  switch (status) {
    case 'PENDING':
      return 'Chờ xác nhận';
    case 'ACCEPTED':
      return 'Đã xác nhận';
    case 'IN_PROGRESS':
      return 'Đang thực hiện';
    case 'COMPLETED':
      return 'Hoàn thành';
    case 'REJECTED':
      return 'Đã từ chối';
    case 'CANCELLED':
      return 'Khách đã hủy';
    default:
      return status;
  }
}

_StatusVisual _statusVisual(String status) {
  switch (status) {
    case 'PENDING':
      return const _StatusVisual(Color(0xFFD97706), Color(0xFFFFF7ED));

    case 'ACCEPTED':
      return const _StatusVisual(AppColors.primary, AppColors.softBlue);

    case 'IN_PROGRESS':
      return const _StatusVisual(Color(0xFF4338CA), Color(0xFFEEF2FF));

    case 'COMPLETED':
      return const _StatusVisual(AppColors.success, Color(0xFFF0FDF4));

    case 'REJECTED':
    case 'CANCELLED':
      return const _StatusVisual(AppColors.error, Color(0xFFFEF2F2));

    default:
      return const _StatusVisual(AppColors.textSecondary, AppColors.softGray);
  }
}

class _StatusVisual {
  final Color foreground;
  final Color background;

  const _StatusVisual(this.foreground, this.background);
}
