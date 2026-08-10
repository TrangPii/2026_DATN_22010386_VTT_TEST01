import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/ui/app_responsive.dart';
import '../../core/ui/app_theme.dart';
import '../../models/booking.dart';
import '../../services/booking_service.dart';
import 'booking_detail_screen.dart';

class CustomerBookingsTab extends StatefulWidget {
  const CustomerBookingsTab({super.key});

  @override
  State<CustomerBookingsTab> createState() => _CustomerBookingsTabState();
}

class _CustomerBookingsTabState extends State<CustomerBookingsTab> {
  final BookingService _bookingService = BookingService();

  List<Booking> _bookings = [];

  bool _isLoading = true;
  String? _error;
  String? _status;

  final List<String> _statuses = [
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
      final result = await _bookingService.getBookings(status: _status);

      if (!mounted) return;

      setState(() {
        _bookings = result;
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
    if (_status == status) return;

    setState(() {
      _status = status;
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
                'Đơn hàng của tôi',
                style: TextStyle(
                  fontSize: 28.rf(context),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),

          // FILTER
          SliverToBoxAdapter(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.only(
                left: AppResponsive.horizontalPadding(context),
                right: AppResponsive.horizontalPadding(context),
              ),
              child: Row(
                children: [
                  _StatusFilter(
                    label: 'Tất cả',
                    selected: _status == null,
                    onTap: () => _changeStatus(null),
                  ),

                  ..._statuses.map(
                    (status) => Padding(
                      padding: EdgeInsets.only(left: 9.rw(context)),
                      child: _StatusFilter(
                        label: bookingStatusLabel(status),
                        selected: _status == status,
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
            SliverToBoxAdapter(
              child: Padding(
                padding: AppResponsive.pagePadding(context),
                child: Center(
                  child: Text(_error!, textAlign: TextAlign.center),
                ),
              ),
            )
          else if (_bookings.isEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: AppResponsive.pagePadding(context),
                child: _BookingEmptyState(onRefresh: _loadBookings),
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
                itemCount: _bookings.length,
                separatorBuilder: (_, _) => SizedBox(height: 14.rw(context)),
                itemBuilder: (context, index) {
                  final booking = _bookings[index];

                  return _BookingCard(
                    booking: booking,
                    priceText: _money(booking.totalAmount),
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              BookingDetailScreen(bookingId: booking.id),
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

class _StatusFilter extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _StatusFilter({
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

class _BookingCard extends StatelessWidget {
  final Booking booking;
  final String priceText;
  final VoidCallback onTap;

  const _BookingCard({
    required this.booking,
    required this.priceText,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final status = bookingStatusStyle(booking.status);

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
                  _BookingServiceImage(imageUrl: booking.service?.image),

                  SizedBox(width: 13.rw(context)),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          booking.serviceName,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 17.rf(context),
                            fontWeight: FontWeight.w700,
                          ),
                        ),

                        SizedBox(height: 5.rw(context)),

                        Text(
                          booking.provider?.businessName ??
                              booking.provider?.name ??
                              'Nhà cung cấp',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13.rf(context),
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(width: 8.rw(context)),

                  _StatusBadge(
                    text: bookingStatusLabel(booking.status),
                    foreground: status.foreground,
                    background: status.background,
                  ),
                ],
              ),

              SizedBox(height: 16.rw(context)),

              Row(
                children: [
                  Icon(
                    Icons.calendar_month_outlined,
                    size: 18.ri(context),
                    color: AppColors.textSecondary,
                  ),
                  SizedBox(width: 7.rw(context)),
                  Text(
                    '${booking.bookingDate} • ${booking.bookingTime}',
                    style: TextStyle(
                      fontSize: 13.5.rf(context),
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),

              SizedBox(height: 10.rw(context)),

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

                  Icon(
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

class _BookingServiceImage extends StatelessWidget {
  final String? imageUrl;

  const _BookingServiceImage({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    final size = 64.rw(context);

    return ClipRRect(
      borderRadius: BorderRadius.circular(12.rr(context)),
      child: SizedBox(
        width: size,
        height: size,
        child: imageUrl != null && imageUrl!.trim().isNotEmpty
            ? Image.network(
                imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => _fallback(),
              )
            : _fallback(),
      ),
    );
  }

  Widget _fallback() {
    return Container(
      color: AppColors.softBlue,
      alignment: Alignment.center,
      child: const Icon(
        Icons.home_repair_service_rounded,
        color: AppColors.primary,
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String text;
  final Color foreground;
  final Color background;

  const _StatusBadge({
    required this.text,
    required this.foreground,
    required this.background,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 9.rw(context),
        vertical: 5.rw(context),
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11.5.rf(context),
          fontWeight: FontWeight.w600,
          color: foreground,
        ),
      ),
    );
  }
}

class _BookingEmptyState extends StatelessWidget {
  final VoidCallback onRefresh;

  const _BookingEmptyState({required this.onRefresh});

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
          'Các dịch vụ bạn đặt sẽ xuất hiện tại đây.',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColors.textSecondary),
        ),
        SizedBox(height: 12.rw(context)),
        TextButton(onPressed: onRefresh, child: const Text('Tải lại')),
      ],
    );
  }
}

String bookingStatusLabel(String status) {
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
      return 'Đã hủy';
    default:
      return status;
  }
}

BookingStatusVisual bookingStatusStyle(String status) {
  switch (status) {
    case 'PENDING':
      return const BookingStatusVisual(
        foreground: Color(0xFFD97706),
        background: Color(0xFFFFF7ED),
      );

    case 'ACCEPTED':
      return const BookingStatusVisual(
        foreground: AppColors.primary,
        background: AppColors.softBlue,
      );

    case 'IN_PROGRESS':
      return const BookingStatusVisual(
        foreground: Color(0xFF4338CA),
        background: Color(0xFFEEF2FF),
      );

    case 'COMPLETED':
      return const BookingStatusVisual(
        foreground: AppColors.success,
        background: Color(0xFFF0FDF4),
      );

    case 'REJECTED':
    case 'CANCELLED':
      return const BookingStatusVisual(
        foreground: AppColors.error,
        background: Color(0xFFFEF2F2),
      );

    default:
      return const BookingStatusVisual(
        foreground: AppColors.textSecondary,
        background: AppColors.softGray,
      );
  }
}

class BookingStatusVisual {
  final Color foreground;
  final Color background;

  const BookingStatusVisual({
    required this.foreground,
    required this.background,
  });
}
