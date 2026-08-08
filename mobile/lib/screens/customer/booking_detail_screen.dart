import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/booking.dart';
import '../../services/booking_service.dart';
import '../customer/review_screen.dart';

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
      if (mounted) {
        setState(() {
          _error = e.toString();
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _cancelBooking() async {
    final controller = TextEditingController();

    final reason = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hủy đơn'),
        content: TextField(
          controller: controller,
          maxLines: 3,
          decoration: const InputDecoration(hintText: 'Nhập lý do hủy...'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Không'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context, controller.text.trim());
            },
            child: const Text('Xác nhận'),
          ),
        ],
      ),
    );

    controller.dispose();

    if (reason == null || reason.length < 5) {
      return;
    }

    try {
      await _bookingService.cancelBooking(
        bookingId: widget.bookingId,
        reason: reason,
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
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_error != null || _booking == null) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(child: Text(_error ?? 'Không tìm thấy đơn.')),
      );
    }

    final booking = _booking!;

    return Scaffold(
      appBar: AppBar(title: Text(booking.bookingCode)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            booking.serviceName,
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 8),

          Chip(label: Text(_statusLabel(booking.status))),

          const SizedBox(height: 24),

          _Info(title: 'Ngày', value: booking.bookingDate),

          _Info(title: 'Giờ', value: booking.bookingTime),

          _Info(title: 'Người nhận', value: booking.customerName),

          _Info(title: 'Số điện thoại', value: booking.customerPhone),

          _Info(title: 'Địa chỉ', value: booking.serviceAddress),

          _Info(title: 'Số lượng', value: booking.quantity.toString()),

          _Info(
            title: 'Tổng tiền',
            value: NumberFormat.currency(
              locale: 'vi_VN',
              symbol: '₫',
              decimalDigits: 0,
            ).format(booking.totalAmount),
          ),

          if (booking.note?.isNotEmpty == true)
            _Info(title: 'Ghi chú', value: booking.note!),

          if (booking.cancellationReason != null)
            _Info(title: 'Lý do hủy', value: booking.cancellationReason!),

          if (booking.rejectionReason != null)
            _Info(title: 'Lý do từ chối', value: booking.rejectionReason!),

          const SizedBox(height: 28),

          if (booking.canCancel)
            OutlinedButton.icon(
              onPressed: _cancelBooking,
              icon: const Icon(Icons.cancel_outlined),
              label: const Text('Hủy đơn'),
            ),

          if (booking.canReview)
            FilledButton.icon(
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
              icon: const Icon(Icons.star_outline),
              label: const Text('Đánh giá dịch vụ'),
            ),

          if (booking.review != null) ...[
            const SizedBox(height: 20),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Đánh giá của bạn',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text('${booking.review!.rating}/5 sao'),
                    if (booking.review!.comment != null)
                      Text(booking.review!.comment!),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _Info extends StatelessWidget {
  final String title;
  final String value;

  const _Info({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(child: Text(value)),
        ],
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
