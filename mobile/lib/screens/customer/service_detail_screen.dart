import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/service.dart';
import '../../screens/customer/create_booking_screen.dart';

class ServiceDetailScreen extends StatelessWidget {
  final Service service;

  const ServiceDetailScreen({super.key, required this.service});

  String _formatPrice(double value) {
    return NumberFormat.currency(
      locale: 'vi_VN',
      symbol: '₫',
      decimalDigits: 0,
    ).format(value);
  }

  @override
  Widget build(BuildContext context) {
    final provider = service.provider;

    return Scaffold(
      appBar: AppBar(title: const Text('Chi tiết dịch vụ')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Container(
              height: 190,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
              ),
              child: service.image == null
                  ? const Icon(Icons.home_repair_service, size: 72)
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.network(
                        service.image!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(
                            Icons.home_repair_service,
                            size: 72,
                          );
                        },
                      ),
                    ),
            ),

            const SizedBox(height: 20),

            Text(
              service.name,
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            Text(
              '${_formatPrice(service.price)} / ${service.priceUnit}',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),

            if (service.estimatedDurationMinutes != null) ...[
              const SizedBox(height: 8),

              Row(
                children: [
                  const Icon(Icons.schedule, size: 18),
                  const SizedBox(width: 6),
                  Text('${service.estimatedDurationMinutes} phút'),
                ],
              ),
            ],

            const SizedBox(height: 24),

            Text(
              'Mô tả dịch vụ',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            Text(
              service.description?.isNotEmpty == true
                  ? service.description!
                  : 'Chưa có mô tả.',
            ),

            const SizedBox(height: 28),

            Text(
              'Nhà cung cấp',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 12),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      child: Text(
                        provider?.name.isNotEmpty == true
                            ? provider!.name[0].toUpperCase()
                            : 'P',
                      ),
                    ),

                    const SizedBox(width: 16),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            provider?.businessName ??
                                provider?.name ??
                                'Nhà cung cấp',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),

                          const SizedBox(height: 4),

                          Row(
                            children: [
                              const Icon(Icons.star, size: 18),
                              const SizedBox(width: 4),
                              Text(
                                '${provider?.averageRating.toStringAsFixed(1) ?? '0.0'}'
                                ' (${provider?.totalReviews ?? 0} đánh giá)',
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),

            SizedBox(
              height: 52,
              child: FilledButton.icon(
                onPressed: () async {
                  final created = await Navigator.push<bool>(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CreateBookingScreen(service: service),
                    ),
                  );

                  if (created == true && context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Bạn có thể xem đơn vừa tạo trong "Đơn của tôi".',
                        ),
                      ),
                    );
                  }
                },
                icon: const Icon(Icons.calendar_month),
                label: const Text('Đặt dịch vụ'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
