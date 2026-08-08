import 'package:flutter/material.dart';

import '../../services/booking_service.dart';

class ReviewScreen extends StatefulWidget {
  final int bookingId;
  final String serviceName;

  const ReviewScreen({
    super.key,
    required this.bookingId,
    required this.serviceName,
  });

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  final BookingService _bookingService = BookingService();
  final TextEditingController _commentController = TextEditingController();

  int _rating = 5;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() {
      _isSubmitting = true;
    });

    try {
      await _bookingService.createReview(
        bookingId: widget.bookingId,
        rating: _rating,
        comment: _commentController.text,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Đánh giá thành công.')));

      Navigator.pop(context, true);
    } on BookingException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.message)));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Đánh giá dịch vụ')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(
            widget.serviceName,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 28),

          const Text('Mức độ hài lòng'),

          const SizedBox(height: 12),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              final value = index + 1;

              return IconButton(
                iconSize: 38,
                onPressed: () {
                  setState(() {
                    _rating = value;
                  });
                },
                icon: Icon(value <= _rating ? Icons.star : Icons.star_border),
              );
            }),
          ),

          const SizedBox(height: 24),

          TextField(
            controller: _commentController,
            maxLines: 5,
            maxLength: 1000,
            decoration: const InputDecoration(
              labelText: 'Nhận xét',
              hintText: 'Chia sẻ trải nghiệm của bạn...',
              border: OutlineInputBorder(),
            ),
          ),

          const SizedBox(height: 24),

          FilledButton(
            onPressed: _isSubmitting ? null : _submit,
            child: _isSubmitting
                ? const CircularProgressIndicator()
                : const Text('Gửi đánh giá'),
          ),
        ],
      ),
    );
  }
}
