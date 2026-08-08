import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

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

  final BookingService _bookingService = BookingService();

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

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
    final value = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (value != null) {
      setState(() {
        _selectedTime = value;
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedDate == null) {
      _showMessage('Vui lòng chọn ngày sử dụng dịch vụ.');
      return;
    }

    if (_selectedTime == null) {
      _showMessage('Vui lòng chọn giờ sử dụng dịch vụ.');
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final booking = await _bookingService.createBooking(
        serviceId: widget.service.id,
        bookingDate: DateFormat('yyyy-MM-dd').format(_selectedDate!),
        bookingTime:
            '${_selectedTime!.hour.toString().padLeft(2, '0')}:'
            '${_selectedTime!.minute.toString().padLeft(2, '0')}',
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

    return Scaffold(
      appBar: AppBar(title: const Text('Đặt dịch vụ')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              widget.service.name,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            Text(
              NumberFormat.currency(
                locale: 'vi_VN',
                symbol: '₫',
                decimalDigits: 0,
              ).format(widget.service.price),
            ),

            const SizedBox(height: 24),

            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Người nhận dịch vụ',
                border: OutlineInputBorder(),
              ),
              validator: (value) => value == null || value.trim().length < 2
                  ? 'Vui lòng nhập họ tên'
                  : null,
            ),

            const SizedBox(height: 16),

            TextFormField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Số điện thoại',
                border: OutlineInputBorder(),
              ),
              validator: (value) => value == null || value.trim().isEmpty
                  ? 'Vui lòng nhập số điện thoại'
                  : null,
            ),

            const SizedBox(height: 16),

            TextFormField(
              controller: _addressController,
              decoration: const InputDecoration(
                labelText: 'Địa chỉ sử dụng dịch vụ',
                border: OutlineInputBorder(),
              ),
              validator: (value) => value == null || value.trim().length < 5
                  ? 'Vui lòng nhập địa chỉ'
                  : null,
            ),

            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _pickDate,
                    icon: const Icon(Icons.calendar_month),
                    label: Text(
                      _selectedDate == null
                          ? 'Chọn ngày'
                          : DateFormat('dd/MM/yyyy').format(_selectedDate!),
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _pickTime,
                    icon: const Icon(Icons.schedule),
                    label: Text(
                      _selectedTime == null
                          ? 'Chọn giờ'
                          : _selectedTime!.format(context),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            Row(
              children: [
                const Text('Số lượng:'),

                const Spacer(),

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

                Text(
                  '$_quantity',
                  style: const TextStyle(fontWeight: FontWeight.bold),
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

            const SizedBox(height: 16),

            TextFormField(
              controller: _noteController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Ghi chú',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 24),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Text('Tổng tiền'),
                    const Spacer(),
                    Text(
                      NumberFormat.currency(
                        locale: 'vi_VN',
                        symbol: '₫',
                        decimalDigits: 0,
                      ).format(total),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            FilledButton(
              onPressed: _isSubmitting ? null : _submit,
              child: _isSubmitting
                  ? const CircularProgressIndicator()
                  : const Text('Xác nhận đặt dịch vụ'),
            ),
          ],
        ),
      ),
    );
  }
}
