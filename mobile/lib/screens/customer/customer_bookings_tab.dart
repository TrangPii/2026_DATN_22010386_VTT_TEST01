import 'package:flutter/material.dart';

class CustomerBookingsTab extends StatelessWidget {
  const CustomerBookingsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long, size: 72),
          SizedBox(height: 16),
          Text(
            'Đơn của tôi',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text('Booking API sẽ được kết nối ở bước tiếp theo.'),
        ],
      ),
    );
  }
}
