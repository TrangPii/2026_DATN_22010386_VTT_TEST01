import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/ui/app_responsive.dart';
import '../../core/ui/app_theme.dart';
import '../../models/booking.dart';
import '../../services/booking_service.dart';
import 'review_screen.dart';

class BookingDetailScreen extends StatefulWidget {
  final int bookingId;

  const BookingDetailScreen({super.key, required this.bookingId});

  @override
  State<BookingDetailScreen> createState() => _BookingDetailScreenState();
}

class _BookingDetailScreenState extends State<BookingDetailScreen> {
  final BookingService _bookingService = BookingService();

  Booking? _booking;
  bool _isLoading = true;
  bool _isCancelling = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadBooking();
  }

  Future<void> _loadBooking() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final booking = await _bookingService.getBooking(widget.bookingId);

      if (!mounted) return;

      setState(() {
        _booking = booking;
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

  Future<void> _cancelBooking() async {
    final reason = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _CancelReasonSheet(),
    );

    if (reason == null || reason.trim().length < 5) {
      return;
    }

    setState(() {
      _isCancelling = true;
    });

    try {
      await _bookingService.cancelBooking(
        bookingId: widget.bookingId,
        reason: reason.trim(),
      );

      await _loadBooking();

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Hủy đơn thành công.')));
      }
    } on BookingException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.message)));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isCancelling = false;
        });
      }
    }
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
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_error != null || _booking == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Chi tiết đơn hàng')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              _error ?? 'Không tìm thấy đơn hàng.',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    final booking = _booking!;
    final status = _statusVisual(booking.status);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Chi tiết đơn hàng')),

      body: RefreshIndicator(
        onRefresh: _loadBooking,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: AppResponsive.pagePadding(
            context,
            top: 20,
            bottom: booking.canCancel || booking.canReview ? 120 : 28,
          ),
          children: [
            // HEADER
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Mã đơn hàng',
                        style: TextStyle(
                          fontSize: 13.rf(context),
                          color: AppColors.textSecondary,
                        ),
                      ),
                      SizedBox(height: 4.rw(context)),
                      Text(
                        booking.bookingCode,
                        style: TextStyle(
                          fontSize: 27.rf(context),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),

                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 11.rw(context),
                    vertical: 6.rw(context),
                  ),
                  decoration: BoxDecoration(
                    color: status.background,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    _statusLabel(booking.status),
                    style: TextStyle(
                      fontSize: 12.5.rf(context),
                      fontWeight: FontWeight.w600,
                      color: status.foreground,
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 24.rw(context)),

            // TIMELINE
            _SectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Trạng thái đơn hàng',
                    style: TextStyle(
                      fontSize: 19.rf(context),
                      fontWeight: FontWeight.w700,
                    ),
                  ),

                  SizedBox(height: 20.rw(context)),

                  _BookingTimeline(
                    status: booking.status,
                    acceptedAt: booking.acceptedAt,
                    startedAt: booking.startedAt,
                    completedAt: booking.completedAt,
                  ),
                ],
              ),
            ),

            SizedBox(height: 16.rw(context)),

            // SERVICE
            _SectionCard(
              child: Row(
                children: [
                  _ServiceImage(imageUrl: booking.service?.image),

                  SizedBox(width: 14.rw(context)),

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
                          '${_money(booking.unitPrice)} / đơn vị',
                          style: TextStyle(
                            fontSize: 14.rf(context),
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 16.rw(context)),

            // PROVIDER
            if (booking.provider != null)
              _SectionCard(
                child: Row(
                  children: [
                    Container(
                      width: 52.rw(context),
                      height: 52.rw(context),
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                        color: AppColors.softBlue,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        booking.provider!.name.isNotEmpty
                            ? booking.provider!.name[0].toUpperCase()
                            : 'P',
                        style: TextStyle(
                          fontSize: 18.rf(context),
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    ),

                    SizedBox(width: 13.rw(context)),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            booking.provider!.businessName ??
                                booking.provider!.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 16.5.rf(context),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(height: 4.rw(context)),
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
                  ],
                ),
              ),

            if (booking.provider != null) SizedBox(height: 16.rw(context)),

            // BOOKING INFO
            _SectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Thông tin đặt lịch',
                    style: TextStyle(
                      fontSize: 19.rf(context),
                      fontWeight: FontWeight.w700,
                    ),
                  ),

                  SizedBox(height: 18.rw(context)),

                  _DetailRow(
                    icon: Icons.calendar_month_outlined,
                    label: 'Ngày thực hiện',
                    value: booking.bookingDate,
                  ),

                  _DetailRow(
                    icon: Icons.schedule_outlined,
                    label: 'Thời gian',
                    value: booking.bookingTime,
                  ),

                  _DetailRow(
                    icon: Icons.location_on_outlined,
                    label: 'Địa chỉ',
                    value: booking.serviceAddress,
                  ),

                  _DetailRow(
                    icon: Icons.person_outline_rounded,
                    label: 'Người nhận',
                    value: booking.customerName,
                  ),

                  _DetailRow(
                    icon: Icons.phone_outlined,
                    label: 'Số điện thoại',
                    value: booking.customerPhone,
                  ),

                  if (booking.note?.trim().isNotEmpty == true)
                    _DetailRow(
                      icon: Icons.notes_outlined,
                      label: 'Ghi chú',
                      value: booking.note!,
                    ),
                ],
              ),
            ),

            // CANCEL/REJECT REASON
            if (booking.cancellationReason != null ||
                booking.rejectionReason != null) ...[
              SizedBox(height: 16.rw(context)),

              Container(
                padding: EdgeInsets.all(16.rw(context)),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF2F2),
                  borderRadius: BorderRadius.circular(16.rr(context)),
                  border: Border.all(color: const Color(0xFFFECACA)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.info_outline_rounded,
                          color: AppColors.error,
                        ),
                        SizedBox(width: 8.rw(context)),
                        Text(
                          booking.rejectionReason != null
                              ? 'Lý do từ chối'
                              : 'Lý do hủy',
                          style: TextStyle(
                            fontSize: 16.rf(context),
                            fontWeight: FontWeight.w700,
                            color: AppColors.error,
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 10.rw(context)),

                    Text(
                      booking.rejectionReason ??
                          booking.cancellationReason ??
                          '',
                      style: TextStyle(fontSize: 14.rf(context), height: 1.45),
                    ),
                  ],
                ),
              ),
            ],

            SizedBox(height: 16.rw(context)),

            // PAYMENT
            _SectionCard(
              child: Column(
                children: [
                  _PriceRow(label: 'Đơn giá', value: _money(booking.unitPrice)),
                  _PriceRow(label: 'Số lượng', value: '${booking.quantity}'),
                  const Divider(height: 26),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Tổng thanh toán',
                          style: TextStyle(
                            fontSize: 17.rf(context),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Text(
                        _money(booking.totalAmount),
                        style: TextStyle(
                          fontSize: 23.rf(context),
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // EXISTING REVIEW
            if (booking.review != null) ...[
              SizedBox(height: 16.rw(context)),

              _SectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Đánh giá của bạn',
                      style: TextStyle(
                        fontSize: 18.rf(context),
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    SizedBox(height: 12.rw(context)),

                    Row(
                      children: List.generate(
                        5,
                        (index) => Icon(
                          index < booking.review!.rating
                              ? Icons.star_rounded
                              : Icons.star_border_rounded,
                          color: AppColors.warning,
                          size: 22.ri(context),
                        ),
                      ),
                    ),

                    if (booking.review!.comment?.trim().isNotEmpty == true) ...[
                      SizedBox(height: 10.rw(context)),
                      Text(
                        booking.review!.comment!,
                        style: TextStyle(
                          fontSize: 14.rf(context),
                          color: AppColors.textSecondary,
                          height: 1.45,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ],
        ),
      ),

      bottomNavigationBar: booking.canCancel || booking.canReview
          ? SafeArea(
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
                child: booking.canReview
                    ? FilledButton.icon(
                        onPressed: () async {
                          final created = await Navigator.push<bool>(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ReviewScreen(
                                bookingId: booking.id,
                                serviceName: booking.serviceName,
                              ),
                            ),
                          );

                          if (created == true) {
                            _loadBooking();
                          }
                        },
                        icon: const Icon(Icons.star_outline_rounded),
                        label: const Text('Đánh giá dịch vụ'),
                      )
                    : OutlinedButton.icon(
                        onPressed: _isCancelling ? null : _cancelBooking,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.error,
                          side: const BorderSide(color: AppColors.error),
                        ),
                        icon: _isCancelling
                            ? SizedBox(
                                width: 18.rw(context),
                                height: 18.rw(context),
                                child: const CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.cancel_outlined),
                        label: Text(_isCancelling ? 'Đang hủy...' : 'Hủy đơn'),
                      ),
              ),
            )
          : null,
    );
  }
}

class _SectionCard extends StatelessWidget {
  final Widget child;

  const _SectionCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(17.rw(context)),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16.rr(context)),
        border: Border.all(color: AppColors.border),
      ),
      child: child,
    );
  }
}

class _ServiceImage extends StatelessWidget {
  final String? imageUrl;

  const _ServiceImage({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    final size = 78.rw(context);

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
      color: AppColors.softGray,
      alignment: Alignment.center,
      child: const Icon(
        Icons.home_repair_service_rounded,
        color: AppColors.textSecondary,
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 15.rw(context)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38.rw(context),
            height: 38.rw(context),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.softBlue,
              borderRadius: BorderRadius.circular(10.rr(context)),
            ),
            child: Icon(icon, size: 20.ri(context), color: AppColors.primary),
          ),

          SizedBox(width: 12.rw(context)),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12.rf(context),
                    color: AppColors.textSecondary,
                  ),
                ),
                SizedBox(height: 3.rw(context)),
                Text(
                  value,
                  style: TextStyle(fontSize: 14.5.rf(context), height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PriceRow extends StatelessWidget {
  final String label;
  final String value;

  const _PriceRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10.rw(context)),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          ),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

class _BookingTimeline extends StatelessWidget {
  final String status;
  final DateTime? acceptedAt;
  final DateTime? startedAt;
  final DateTime? completedAt;

  const _BookingTimeline({
    required this.status,
    required this.acceptedAt,
    required this.startedAt,
    required this.completedAt,
  });

  int get _step {
    switch (status) {
      case 'PENDING':
        return 0;
      case 'ACCEPTED':
        return 1;
      case 'IN_PROGRESS':
        return 2;
      case 'COMPLETED':
        return 3;
      default:
        return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final steps = [
      ('Đã đặt', null),
      ('Đã xác nhận', acceptedAt),
      ('Đang thực hiện', startedAt),
      ('Hoàn thành', completedAt),
    ];

    return Column(
      children: List.generate(steps.length, (index) {
        final active =
            index <= _step && status != 'REJECTED' && status != 'CANCELLED';

        final current =
            index == _step && status != 'REJECTED' && status != 'CANCELLED';

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                Container(
                  width: 28.rw(context),
                  height: 28.rw(context),
                  decoration: BoxDecoration(
                    color: active
                        ? current
                              ? AppColors.primary
                              : const Color(0xFFE8F8EE)
                        : AppColors.softGray,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: active
                          ? current
                                ? AppColors.primary
                                : AppColors.success
                          : AppColors.border,
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    active ? Icons.check_rounded : Icons.circle_outlined,
                    size: 16.ri(context),
                    color: active
                        ? current
                              ? Colors.white
                              : AppColors.success
                        : AppColors.textSecondary,
                  ),
                ),

                if (index != steps.length - 1)
                  Container(
                    width: 2,
                    height: 42.rw(context),
                    color: index < _step ? AppColors.success : AppColors.border,
                  ),
              ],
            ),

            SizedBox(width: 13.rw(context)),

            Expanded(
              child: Padding(
                padding: EdgeInsets.only(top: 3.rw(context)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      steps[index].$1,
                      style: TextStyle(
                        fontSize: 15.rf(context),
                        fontWeight: current ? FontWeight.w700 : FontWeight.w500,
                        color: current
                            ? AppColors.primary
                            : active
                            ? AppColors.textPrimary
                            : AppColors.textSecondary,
                      ),
                    ),
                    if (steps[index].$2 != null)
                      Text(
                        DateFormat(
                          'dd/MM/yyyy • HH:mm',
                        ).format(steps[index].$2!),
                        style: TextStyle(
                          fontSize: 11.5.rf(context),
                          color: AppColors.textSecondary,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}

class _CancelReasonSheet extends StatefulWidget {
  const _CancelReasonSheet();

  @override
  State<_CancelReasonSheet> createState() => _CancelReasonSheetState();
}

class _CancelReasonSheetState extends State<_CancelReasonSheet> {
  final _controller = TextEditingController();
  String? _error;

  final _quickReasons = const [
    'Thay đổi kế hoạch',
    'Đặt nhầm thời gian',
    'Không còn nhu cầu',
    'Lý do khác',
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final reason = _controller.text.trim();

    if (reason.length < 5) {
      setState(() {
        _error = 'Lý do hủy phải có ít nhất 5 ký tự';
      });
      return;
    }

    Navigator.pop(context, reason);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        20.rw(context),
        12.rw(context),
        20.rw(context),
        20.rw(context) + MediaQuery.viewInsetsOf(context).bottom,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24.rr(context)),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40.rw(context),
                height: 4.rw(context),
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),

            SizedBox(height: 18.rw(context)),

            Text(
              'Hủy đơn hàng',
              style: TextStyle(
                fontSize: 21.rf(context),
                fontWeight: FontWeight.w700,
              ),
            ),

            SizedBox(height: 6.rw(context)),

            Text(
              'Vui lòng cho biết lý do bạn muốn hủy đơn hàng này.',
              style: TextStyle(
                fontSize: 13.5.rf(context),
                color: AppColors.textSecondary,
              ),
            ),

            SizedBox(height: 16.rw(context)),

            Wrap(
              spacing: 8.rw(context),
              runSpacing: 8.rw(context),
              children: _quickReasons
                  .map(
                    (reason) => ActionChip(
                      label: Text(reason),
                      onPressed: () {
                        _controller.text = reason == 'Lý do khác' ? '' : reason;
                        setState(() {
                          _error = null;
                        });
                      },
                    ),
                  )
                  .toList(),
            ),

            SizedBox(height: 16.rw(context)),

            TextField(
              controller: _controller,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Lý do hủy',
                hintText: 'Nhập lý do hủy đơn...',
                errorText: _error,
                alignLabelWithHint: true,
              ),
              onChanged: (_) {
                if (_error != null) {
                  setState(() {
                    _error = null;
                  });
                }
              },
            ),

            SizedBox(height: 18.rw(context)),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Quay lại'),
                  ),
                ),
                SizedBox(width: 12.rw(context)),
                Expanded(
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.error,
                    ),
                    onPressed: _submit,
                    child: const Text('Xác nhận hủy'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

String _statusLabel(String status) {
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
