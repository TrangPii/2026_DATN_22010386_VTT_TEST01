import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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

  String _formatPrice(double value) {
    return NumberFormat.currency(
      locale: 'vi_VN',
      symbol: '₫',
      decimalDigits: 0,
    ).format(value);
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
                  selected: _selectedStatus == null,
                  onSelected: (_) {
                    setState(() {
                      _selectedStatus = null;
                    });

                    _loadBookings();
                  },
                ),

                const SizedBox(width: 8),

                ..._statuses.map(
                  (status) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(providerBookingStatusLabel(status)),
                      selected: _selectedStatus == status,
                      onSelected: (_) {
                        setState(() {
                          _selectedStatus = status;
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
            const Padding(
              padding: EdgeInsets.all(40),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_error != null)
            Column(
              children: [
                Text(_error!, textAlign: TextAlign.center),
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: _loadBookings,
                  child: const Text('Thử lại'),
                ),
              ],
            )
          else if (_bookings.isEmpty)
            const Padding(
              padding: EdgeInsets.all(40),
              child: Center(child: Text('Không có đơn hàng.')),
            )
          else
            ..._bookings.map(
              (booking) => Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            ProviderBookingDetailScreen(bookingId: booking.id),
                      ),
                    );

                    _loadBookings();
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                booking.serviceName,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            _StatusChip(status: booking.status),
                          ],
                        ),

                        const SizedBox(height: 10),

                        Text(booking.bookingCode),

                        const SizedBox(height: 6),

                        Row(
                          children: [
                            const Icon(Icons.person_outline, size: 18),
                            const SizedBox(width: 6),
                            Expanded(child: Text(booking.customerName)),
                          ],
                        ),

                        const SizedBox(height: 6),

                        Row(
                          children: [
                            const Icon(Icons.calendar_today_outlined, size: 18),
                            const SizedBox(width: 6),
                            Text(
                              '${booking.bookingDate} • ${booking.bookingTime}',
                            ),
                          ],
                        ),

                        const SizedBox(height: 8),

                        Text(
                          _formatPrice(booking.totalAmount),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String status;

  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    return Chip(label: Text(providerBookingStatusLabel(status)));
  }
}

String providerBookingStatusLabel(String status) {
  switch (status) {
    case 'PENDING':
      return 'Chờ xác nhận';

    case 'ACCEPTED':
      return 'Đã nhận';

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
