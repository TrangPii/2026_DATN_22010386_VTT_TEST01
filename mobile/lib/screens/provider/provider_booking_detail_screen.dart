import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/ui/app_responsive.dart';
import '../../core/ui/app_theme.dart';
import '../../models/booking.dart';
import '../../services/provider_booking_service.dart';

class ProviderBookingDetailScreen extends StatefulWidget {
  final int bookingId;

  const ProviderBookingDetailScreen({super.key, required this.bookingId});

  @override
  State<ProviderBookingDetailScreen> createState() =>
      _ProviderBookingDetailScreenState();
}

class _ProviderBookingDetailScreenState
    extends State<ProviderBookingDetailScreen> {
  final ProviderBookingService _bookingService = ProviderBookingService();

  Booking? _booking;

  bool _isLoading = true;
  bool _isProcessing = false;

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

  Future<void> _accept() async {
    final confirmed = await _confirmAction(
      title: 'Xác nhận đơn hàng?',
      message: 'Bạn có chắc chắn muốn nhận đơn dịch vụ này?',
      confirmText: 'Xác nhận đơn',
    );

    if (!confirmed) return;

    await _executeAction(
      () => _bookingService.accept(widget.bookingId),
      'Đã xác nhận đơn hàng.',
    );
  }

  Future<void> _start() async {
    final confirmed = await _confirmAction(
      title: 'Bắt đầu thực hiện?',
      message: 'Xác nhận rằng bạn đang bắt đầu thực hiện dịch vụ này.',
      confirmText: 'Bắt đầu',
    );

    if (!confirmed) return;

    await _executeAction(
      () => _bookingService.start(widget.bookingId),
      'Đã bắt đầu thực hiện dịch vụ.',
    );
  }

  Future<void> _complete() async {
    final confirmed = await _confirmAction(
      title: 'Hoàn thành dịch vụ?',
      message: 'Xác nhận rằng dịch vụ đã được thực hiện hoàn tất.',
      confirmText: 'Hoàn thành',
    );

    if (!confirmed) return;

    await _executeAction(
      () => _bookingService.complete(widget.bookingId),
      'Đã hoàn thành dịch vụ.',
    );
  }

  Future<void> _reject() async {
    final reason = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _RejectReasonSheet(),
    );

    if (reason == null || reason.trim().length < 5) {
      return;
    }

    await _executeAction(
      () => _bookingService.reject(id: widget.bookingId, reason: reason.trim()),
      'Đã từ chối đơn hàng.',
    );
  }

  Future<void> _executeAction(
    Future<Booking> Function() action,
    String successMessage,
  ) async {
    if (_isProcessing) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      final booking = await action();

      if (!mounted) return;

      setState(() {
        _booking = booking;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(successMessage)));
    } on ProviderBookingException catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.message)));
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  Future<bool> _confirmAction({
    required String title,
    required String message,
    required String confirmText,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Quay lại'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(confirmText),
          ),
        ],
      ),
    );

    return result ?? false;
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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _error ?? 'Không tìm thấy đơn hàng.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: _loadBooking,
                child: const Text('Thử lại'),
              ),
            ],
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
            top: 18,
            bottom: _hasAction(booking.status) ? 120 : 30,
          ),
          children: [
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

            _Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Khách hàng',
                    style: TextStyle(
                      fontSize: 19.rf(context),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 16.rw(context)),
                  Row(
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
                          booking.customerName.isNotEmpty
                              ? booking.customerName[0].toUpperCase()
                              : 'K',
                          style: TextStyle(
                            fontSize: 19.rf(context),
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
                              booking.customerName,
                              style: TextStyle(
                                fontSize: 17.rf(context),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            SizedBox(height: 4.rw(context)),
                            Text(
                              booking.customerPhone,
                              style: TextStyle(
                                fontSize: 13.5.rf(context),
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        tooltip: 'Gọi điện',
                        onPressed: null,
                        icon: const Icon(Icons.phone_outlined),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            SizedBox(height: 16.rw(context)),

            _Card(
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
                        SizedBox(height: 6.rw(context)),
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

            _Card(
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
                    icon: Icons.numbers_rounded,
                    label: 'Số lượng',
                    value: '${booking.quantity}',
                  ),
                  if (booking.note?.trim().isNotEmpty == true)
                    _DetailRow(
                      icon: Icons.notes_outlined,
                      label: 'Ghi chú từ khách hàng',
                      value: booking.note!,
                    ),
                ],
              ),
            ),

            if (booking.rejectionReason != null ||
                booking.cancellationReason != null) ...[
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
                    Text(
                      booking.rejectionReason != null
                          ? 'Lý do từ chối'
                          : 'Lý do khách hủy',
                      style: TextStyle(
                        fontSize: 16.rf(context),
                        fontWeight: FontWeight.w700,
                        color: AppColors.error,
                      ),
                    ),
                    SizedBox(height: 8.rw(context)),
                    Text(
                      booking.rejectionReason ??
                          booking.cancellationReason ??
                          '',
                      style: TextStyle(fontSize: 14.rf(context), height: 1.4),
                    ),
                  ],
                ),
              ),
            ],

            SizedBox(height: 16.rw(context)),

            _Card(
              child: Column(
                children: [
                  _PriceRow(label: 'Đơn giá', value: _money(booking.unitPrice)),
                  _PriceRow(label: 'Số lượng', value: '${booking.quantity}'),
                  const Divider(height: 28),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Tổng giá trị đơn',
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
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomAction(booking),
    );
  }

  bool _hasAction(String status) {
    return status == 'PENDING' ||
        status == 'ACCEPTED' ||
        status == 'IN_PROGRESS';
  }

  Widget? _buildBottomAction(Booking booking) {
    if (!_hasAction(booking.status)) {
      return null;
    }

    return SafeArea(
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
        child: _isProcessing
            ? const Center(child: CircularProgressIndicator())
            : switch (booking.status) {
                'PENDING' => Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _reject,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.error,
                          side: const BorderSide(color: AppColors.error),
                        ),
                        child: const Text('Từ chối'),
                      ),
                    ),
                    SizedBox(width: 12.rw(context)),
                    Expanded(
                      child: FilledButton(
                        onPressed: _accept,
                        child: const Text('Xác nhận đơn'),
                      ),
                    ),
                  ],
                ),
                'ACCEPTED' => FilledButton.icon(
                  onPressed: _start,
                  icon: const Icon(Icons.play_arrow_rounded),
                  label: const Text('Bắt đầu thực hiện'),
                ),
                'IN_PROGRESS' => FilledButton.icon(
                  onPressed: _complete,
                  icon: const Icon(Icons.task_alt_rounded),
                  label: const Text('Hoàn thành dịch vụ'),
                ),
                _ => const SizedBox.shrink(),
              },
      ),
    );
  }
}

class _Card extends StatelessWidget {
  final Widget child;

  const _Card({required this.child});

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
    final size = 76.rw(context);

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

class _RejectReasonSheet extends StatefulWidget {
  const _RejectReasonSheet();

  @override
  State<_RejectReasonSheet> createState() => _RejectReasonSheetState();
}

class _RejectReasonSheetState extends State<_RejectReasonSheet> {
  final _controller = TextEditingController();

  String? _error;

  final _quickReasons = const [
    'Không thể sắp xếp thời gian',
    'Ngoài khu vực phục vụ',
    'Không đủ điều kiện thực hiện',
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
        _error = 'Lý do từ chối phải có ít nhất 5 ký tự';
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
              'Từ chối đơn hàng',
              style: TextStyle(
                fontSize: 21.rf(context),
                fontWeight: FontWeight.w700,
              ),
            ),

            SizedBox(height: 6.rw(context)),

            Text(
              'Vui lòng cho khách hàng biết lý do bạn không thể nhận đơn này.',
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
                labelText: 'Lý do từ chối',
                hintText: 'Nhập lý do từ chối đơn...',
                errorText: _error,
                alignLabelWithHint: true,
              ),
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
                    child: const Text('Xác nhận từ chối'),
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
