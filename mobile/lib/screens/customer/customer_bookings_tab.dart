import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/booking.dart';
import '../../services/booking_service.dart';
import '../customer/booking_detail_screen.dart';

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

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _loadBookings,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                ChoiceChip(
                  label: const Text('Tất cả'),
                  selected: _status == null,
                  onSelected: (_) {
                    setState(() {
                      _status = null;
                    });

                    _loadBookings();
                  },
                ),

                const SizedBox(width: 8),

                ..._statuses.map(
                  (status) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(_statusLabel(status)),
                      selected: _status == status,
                      onSelected: (_) {
                        setState(() {
                          _status = status;
                        });

                        _loadBookings();
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(40),
                child: CircularProgressIndicator(),
              ),
            )
          else if (_error != null)
            Center(child: Text(_error!))
          else if (_bookings.isEmpty)
            const Padding(
              padding: EdgeInsets.all(40),
              child: Center(child: Text('Bạn chưa có đơn nào.')),
            )
          else
            ..._bookings.map(
              (booking) => Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),

                  title: Text(
                    booking.serviceName,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),

                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 6),

                      Text(booking.bookingCode),

                      const SizedBox(height: 4),

                      Text(
                        '${booking.bookingDate} • '
                        '${booking.bookingTime}',
                      ),

                      const SizedBox(height: 8),

                      Text(
                        NumberFormat.currency(
                          locale: 'vi_VN',
                          symbol: '₫',
                          decimalDigits: 0,
                        ).format(booking.totalAmount),
                      ),

                      const SizedBox(height: 8),

                      Text(
                        _statusLabel(booking.status),
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),

                  trailing: const Icon(Icons.chevron_right),

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
                ),
              ),
            ),
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
