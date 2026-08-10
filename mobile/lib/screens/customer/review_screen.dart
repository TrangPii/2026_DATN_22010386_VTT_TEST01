import 'package:flutter/material.dart';

import '../../core/ui/app_responsive.dart';
import '../../core/ui/app_theme.dart';
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

  int _rating = 0;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn số sao đánh giá.')),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      await _bookingService.createReview(
        bookingId: widget.bookingId,
        rating: _rating,
        comment: _commentController.text.trim(),
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

  String get _ratingText {
    switch (_rating) {
      case 1:
        return 'Rất không hài lòng';
      case 2:
        return 'Chưa hài lòng';
      case 3:
        return 'Bình thường';
      case 4:
        return 'Hài lòng';
      case 5:
        return 'Rất hài lòng';
      default:
        return 'Chọn mức đánh giá';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: AppBar(title: const Text('Đánh giá dịch vụ')),

      body: ListView(
        padding: AppResponsive.pagePadding(context, top: 20, bottom: 120),
        children: [
          // SERVICE
          Container(
            padding: EdgeInsets.all(16.rw(context)),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16.rr(context)),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                Container(
                  width: 62.rw(context),
                  height: 62.rw(context),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.softBlue,
                    borderRadius: BorderRadius.circular(12.rr(context)),
                  ),
                  child: Icon(
                    Icons.home_repair_service_rounded,
                    color: AppColors.primary,
                    size: 30.ri(context),
                  ),
                ),

                SizedBox(width: 13.rw(context)),

                Expanded(
                  child: Text(
                    widget.serviceName,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 17.rf(context),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 34.rw(context)),

          Text(
            'Trải nghiệm của bạn thế nào?',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 25.rf(context),
              fontWeight: FontWeight.w700,
              height: 1.25,
            ),
          ),

          SizedBox(height: 10.rw(context)),

          Text(
            _ratingText,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14.rf(context),
              color: _rating == 0 ? AppColors.textSecondary : AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),

          SizedBox(height: 20.rw(context)),

          // STARS
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              final value = index + 1;

              return IconButton(
                tooltip: '$value sao',
                onPressed: () {
                  setState(() {
                    _rating = value;
                  });
                },
                padding: EdgeInsets.symmetric(horizontal: 4.rw(context)),
                iconSize: 43.ri(context),
                icon: Icon(
                  value <= _rating
                      ? Icons.star_rounded
                      : Icons.star_border_rounded,
                  color: value <= _rating
                      ? AppColors.warning
                      : const Color(0xFFCBD5E1),
                ),
              );
            }),
          ),

          SizedBox(height: 34.rw(context)),

          Text(
            'Chia sẻ cảm nhận của bạn',
            style: TextStyle(
              fontSize: 18.rf(context),
              fontWeight: FontWeight.w700,
            ),
          ),

          SizedBox(height: 10.rw(context)),

          TextField(
            controller: _commentController,
            maxLines: 6,
            maxLength: 1000,
            decoration: const InputDecoration(
              hintText:
                  'Dịch vụ có đáp ứng mong đợi của bạn không? Nhà cung cấp có nhiệt tình không?...',
              alignLabelWithHint: true,
            ),
          ),
        ],
      ),

      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          padding: EdgeInsets.fromLTRB(
            AppResponsive.horizontalPadding(context),
            12.rw(context),
            AppResponsive.horizontalPadding(context),
            12.rw(context),
          ),
          color: AppColors.surface,
          child: FilledButton(
            onPressed: _isSubmitting ? null : _submit,
            child: _isSubmitting
                ? SizedBox(
                    width: 20.rw(context),
                    height: 20.rw(context),
                    child: const CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text('Gửi đánh giá'),
          ),
        ),
      ),
    );
  }
}
