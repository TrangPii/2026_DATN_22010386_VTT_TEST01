import 'package:flutter/material.dart';

class ProviderServicesTab extends StatelessWidget {
  const ProviderServicesTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.home_repair_service, size: 72),
          SizedBox(height: 16),
          Text(
            'Dịch vụ của tôi',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text('Provider Service Management sẽ được nối ở Phase 2.'),
        ],
      ),
    );
  }
}
