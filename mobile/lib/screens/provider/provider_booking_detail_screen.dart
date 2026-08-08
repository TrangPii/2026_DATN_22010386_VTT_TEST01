import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/booking.dart';
import '../../services/provider_booking_service.dart';
import 'provider_bookings_tab.dart';

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
    await _executeAction(
      () => _bookingService.accept(widget.bookingId),
      'Đã nhận đơn.',
    );
  }

  Future<void> _start() async {
    final confirmed = await _showConfirmDialog(
      title: 'Bắt đầu dịch vụ',
      message: 'Xác nhận bắt đầu thực hiện dịch vụ?',
      confirmText: 'Bắt đầu',
    );

    if (!confirmed) return;

    await _executeAction(
      () => _bookingService.start(widget.bookingId),
      'Đã bắt đầu thực hiện dịch vụ.',
    );
  }

  Future<void> _complete() async {
    final confirmed = await _showConfirmDialog(
      title: 'Hoàn thành dịch vụ',
      message: 'Xác nhận dịch vụ đã được hoàn thành?',
      confirmText: 'Hoàn thành',
    );

    if (!confirmed) return;

    await _executeAction(
      () => _bookingService.complete(widget.bookingId),
      'Đã hoàn thành dịch vụ.',
    );
  }

  Future<void> _reject() async {
    final controller = TextEditingController();

    final reason = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Từ chối đơn'),
          content: TextField(
            controller: controller,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Lý do từ chối',
              hintText: 'Nhập lý do từ chối...',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Đóng'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(context, controller.text.trim());
              },
              child: const Text('Từ chối'),
            ),
          ],
        );
      },
    );

    controller.dispose();

    if (reason == null || reason.length < 5) {
      return;
    }

    await _executeAction(
      () => _bookingService.reject(id: widget.bookingId, reason: reason),
      'Đã từ chối đơn.',
    );
  }

  Future<void> _executeAction(
    Future<Booking> Function() action,
    String successMessage,
  ) async {
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

  Future<bool> _showConfirmDialog({
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
            child: const Text('Hủy'),
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

  String _formatPrice(double value) {
    return NumberFormat.currency(
      locale: 'vi_VN',
      symbol: '₫',
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
        appBar: AppBar(),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_error ?? 'Không tìm thấy đơn.'),
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

          Align(
            alignment: Alignment.centerLeft,
            child: Chip(
              label: Text(providerBookingStatusLabel(booking.status)),
            ),
          ),

          const SizedBox(height: 24),

          Text(
            'Thông tin khách hàng',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 12),

          _InfoRow(title: 'Họ tên', value: booking.customerName),

          _InfoRow(title: 'Điện thoại', value: booking.customerPhone),

          _InfoRow(title: 'Địa chỉ', value: booking.serviceAddress),

          const SizedBox(height: 20),

          Text(
            'Thông tin lịch hẹn',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 12),

          _InfoRow(title: 'Ngày', value: booking.bookingDate),

          _InfoRow(title: 'Giờ', value: booking.bookingTime),

          _InfoRow(title: 'Số lượng', value: booking.quantity.toString()),

          _InfoRow(title: 'Đơn giá', value: _formatPrice(booking.unitPrice)),

          _InfoRow(
            title: 'Tổng tiền',
            value: _formatPrice(booking.totalAmount),
          ),

          if (booking.note?.isNotEmpty == true)
            _InfoRow(title: 'Ghi chú', value: booking.note!),

          if (booking.rejectionReason?.isNotEmpty == true)
            _InfoRow(title: 'Lý do từ chối', value: booking.rejectionReason!),

          if (booking.cancellationReason?.isNotEmpty == true)
            _InfoRow(title: 'Lý do hủy', value: booking.cancellationReason!),

          const SizedBox(height: 32),

          if (_isProcessing)
            const Center(child: CircularProgressIndicator())
          else
            ..._buildActions(booking),
        ],
      ),
    );
  }

  List<Widget> _buildActions(Booking booking) {
    switch (booking.status) {
      case 'PENDING':
        return [
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _reject,
                  icon: const Icon(Icons.close),
                  label: const Text('Từ chối'),
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: FilledButton.icon(
                  onPressed: _accept,
                  icon: const Icon(Icons.check),
                  label: const Text('Nhận đơn'),
                ),
              ),
            ],
          ),
        ];

      case 'ACCEPTED':
        return [
          FilledButton.icon(
            onPressed: _start,
            icon: const Icon(Icons.play_arrow),
            label: const Text('Bắt đầu dịch vụ'),
          ),
        ];

      case 'IN_PROGRESS':
        return [
          FilledButton.icon(
            onPressed: _complete,
            icon: const Icon(Icons.task_alt),
            label: const Text('Hoàn thành dịch vụ'),
          ),
        ];

      default:
        return [];
    }
  }
}

class _InfoRow extends StatelessWidget {
  final String title;
  final String value;

  const _InfoRow({required this.title, required this.value});

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
