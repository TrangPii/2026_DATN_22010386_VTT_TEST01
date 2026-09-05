import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/ui/app_responsive.dart';
import '../../core/ui/app_theme.dart';
import '../../models/service.dart';
import '../../providers/auth_provider.dart';
import '../../services/booking_service.dart';

class CreateBookingScreen extends StatefulWidget {
  final Service service;

  const CreateBookingScreen({super.key, required this.service});

  @override
  State<CreateBookingScreen> createState() => _CreateBookingScreenState();
}

class _CreateBookingScreenState extends State<CreateBookingScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _noteController = TextEditingController();
  final _timeController = TextEditingController();

  final BookingService _bookingService = BookingService();

  DateTime? _selectedDate;

  int _quantity = 1;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();

    final user = context.read<AuthProvider>().user;

    _nameController.text = user?.name ?? '';
    _phoneController.text = user?.phone ?? '';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _noteController.dispose();
    _timeController.dispose();

    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();

    final value = await showDatePicker(
      context: context,
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: now.add(const Duration(days: 90)),
      initialDate: now,
    );

    if (value != null) {
      setState(() {
        _selectedDate = value;
      });
    }
  }

  Future<void> _pickTime() async {
    final initialTime = _timeController.text.isNotEmpty
        ? _parseTime(_timeController.text)
        : const TimeOfDay(hour: 8, minute: 0);

    final picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
      helpText: 'CHỌN THỜI GIAN',
      cancelText: 'HỦY',
      confirmText: 'XÁC NHẬN',
      hourLabelText: 'Giờ',
      minuteLabelText: 'Phút',
      builder: (context, child) {
        final mediaQuery = MediaQuery.of(context);

        return MediaQuery(
          data: mediaQuery.copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final hour = picked.hour.toString().padLeft(2, '0');
      final minute = picked.minute.toString().padLeft(2, '0');

      setState(() {
        _timeController.text = '$hour:$minute';
      });
    }
  }

  TimeOfDay _parseTime(String value) {
    final parts = value.split(':');

    if (parts.length != 2) {
      return const TimeOfDay(hour: 8, minute: 0);
    }

    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);

    if (hour == null ||
        minute == null ||
        hour < 0 ||
        hour > 23 ||
        minute < 0 ||
        minute > 59) {
      return const TimeOfDay(hour: 8, minute: 0);
    }

    return TimeOfDay(hour: hour, minute: minute);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedDate == null) {
      _showMessage('Vui lòng chọn ngày sử dụng dịch vụ.');
      return;
    }

    final timeText = _timeController.text.trim();

    final timeRegex = RegExp(r'^([01]\d|2[0-3]):([0-5]\d)$');

    if (!timeRegex.hasMatch(timeText)) {
      _showMessage('Vui lòng chọn thời gian thực hiện dịch vụ.');
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final booking = await _bookingService.createBooking(
        serviceId: widget.service.id,
        bookingDate: DateFormat('yyyy-MM-dd').format(_selectedDate!),
        bookingTime: timeText,
        quantity: _quantity,
        customerName: _nameController.text,
        customerPhone: _phoneController.text,
        serviceAddress: _addressController.text,
        note: _noteController.text,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Đặt dịch vụ thành công: ${booking.bookingCode}'),
        ),
      );

      Navigator.pop(context, true);
    } on BookingException catch (e) {
      if (mounted) {
        _showMessage(e.message);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final total = widget.service.price * _quantity;
    final provider = widget.service.provider;

    String money(double value) {
      return NumberFormat.currency(
        locale: 'vi_VN',
        symbol: 'đ',
        decimalDigits: 0,
      ).format(value);
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Đặt dịch vụ')),

      body: Form(
        key: _formKey,
        child: ListView(
          padding: AppResponsive.pagePadding(context, top: 18, bottom: 120),
          children: [
            // SERVICE SUMMARY
            Container(
              padding: EdgeInsets.all(14.rw(context)),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16.rr(context)),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12.rr(context)),
                    child: SizedBox(
                      width: 84.rw(context),
                      height: 84.rw(context),
                      child: widget.service.image == null
                          ? Container(
                              color: AppColors.softGray,
                              child: const Icon(
                                Icons.home_repair_service_rounded,
                              ),
                            )
                          : Image.network(
                              widget.service.image!,
                              fit: BoxFit.cover,
                              errorBuilder: (_, _, _) => Container(
                                color: AppColors.softGray,
                                child: const Icon(
                                  Icons.home_repair_service_rounded,
                                ),
                              ),
                            ),
                    ),
                  ),

                  SizedBox(width: 14.rw(context)),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.service.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 17.rf(context),
                            fontWeight: FontWeight.w700,
                          ),
                        ),

                        SizedBox(height: 5.rw(context)),

                        Text(
                          provider?.businessName ??
                              provider?.name ??
                              'Nhà cung cấp',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13.rf(context),
                            color: AppColors.textSecondary,
                          ),
                        ),

                        SizedBox(height: 7.rw(context)),

                        Text(
                          '${money(widget.service.price)}/${widget.service.priceUnit}',
                          style: TextStyle(
                            fontSize: 16.rf(context),
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 28.rw(context)),

            Text(
              'Thông tin đặt lịch',
              style: TextStyle(
                fontSize: 22.rf(context),
                fontWeight: FontWeight.w700,
              ),
            ),

            SizedBox(height: 18.rw(context)),

            // CUSTOMER NAME
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Người nhận dịch vụ',
                prefixIcon: Icon(Icons.person_outline),
              ),
              validator: (value) => value == null || value.trim().length < 2
                  ? 'Vui lòng nhập họ tên'
                  : null,
            ),

            SizedBox(height: 14.rw(context)),

            // PHONE
            TextFormField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Số điện thoại',
                prefixIcon: Icon(Icons.phone_outlined),
              ),
              validator: (value) => value == null || value.trim().isEmpty
                  ? 'Vui lòng nhập số điện thoại'
                  : null,
            ),

            SizedBox(height: 14.rw(context)),

            // DATE
            _BookingSelector(
              icon: Icons.calendar_month_outlined,
              label: 'Ngày thực hiện',
              value: _selectedDate == null
                  ? 'Chọn ngày'
                  : DateFormat('dd/MM/yyyy').format(_selectedDate!),
              onTap: _pickDate,
            ),

            SizedBox(height: 14.rw(context)),

            // TIME
            _BookingSelector(
              icon: Icons.schedule_outlined,
              label: 'Thời gian',
              value: _timeController.text.isEmpty
                  ? 'Chọn thời gian'
                  : _timeController.text,
              onTap: _pickTime,
            ),
            SizedBox(height: 14.rw(context)),

            // ADDRESS
            TextFormField(
              controller: _addressController,
              minLines: 1,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Địa chỉ thực hiện',
                prefixIcon: Icon(Icons.location_on_outlined),
                hintText: 'Nhập địa chỉ sử dụng dịch vụ',
              ),
              validator: (value) => value == null || value.trim().length < 5
                  ? 'Vui lòng nhập địa chỉ'
                  : null,
            ),

            SizedBox(height: 18.rw(context)),

            // QUANTITY
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: 16.rw(context),
                vertical: 12.rw(context),
              ),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(14.rr(context)),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Số lượng',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),

                  IconButton(
                    onPressed: _quantity > 1
                        ? () {
                            setState(() {
                              _quantity--;
                            });
                          }
                        : null,
                    icon: const Icon(Icons.remove_circle_outline),
                  ),

                  SizedBox(
                    width: 28.rw(context),
                    child: Text(
                      '$_quantity',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),

                  IconButton(
                    onPressed: _quantity < 10
                        ? () {
                            setState(() {
                              _quantity++;
                            });
                          }
                        : null,
                    icon: const Icon(Icons.add_circle_outline),
                  ),
                ],
              ),
            ),

            SizedBox(height: 18.rw(context)),

            TextFormField(
              controller: _noteController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Ghi chú',
                hintText: 'Nhập yêu cầu hoặc lưu ý cho nhà cung cấp...',
                alignLabelWithHint: true,
              ),
            ),

            SizedBox(height: 24.rw(context)),

            // ORDER SUMMARY
            Container(
              padding: EdgeInsets.all(18.rw(context)),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16.rr(context)),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tóm tắt đơn hàng',
                    style: TextStyle(
                      fontSize: 20.rf(context),
                      fontWeight: FontWeight.w700,
                    ),
                  ),

                  SizedBox(height: 18.rw(context)),

                  _SummaryRow(
                    label: 'Đơn giá',
                    value: money(widget.service.price),
                  ),

                  _SummaryRow(label: 'Số lượng', value: '$_quantity'),

                  const Divider(height: 28),

                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Tổng cộng',
                          style: TextStyle(
                            fontSize: 17.rf(context),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Text(
                        money(total),
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

      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          color: AppColors.surface,
          padding: EdgeInsets.fromLTRB(
            AppResponsive.horizontalPadding(context),
            12.rw(context),
            AppResponsive.horizontalPadding(context),
            12.rw(context),
          ),
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
                : const Text('Xác nhận đặt dịch vụ'),
          ),
        ),
      ),
    );
  }
}

class _BookingSelector extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback onTap;

  const _BookingSelector({
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14.rr(context)),
      child: Container(
        padding: EdgeInsets.all(15.rw(context)),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14.rr(context)),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primary),
            SizedBox(width: 13.rw(context)),
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
                    style: TextStyle(
                      fontSize: 15.rf(context),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;

  const _SummaryRow({required this.label, required this.value});

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
