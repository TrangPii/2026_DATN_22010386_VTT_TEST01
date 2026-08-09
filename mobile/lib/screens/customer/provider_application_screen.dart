import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/provider_application.dart';
import '../../providers/auth_provider.dart';
import '../../services/provider_application_service.dart';

class ProviderApplicationScreen extends StatefulWidget {
  final ProviderApplication? application;

  const ProviderApplicationScreen({super.key, this.application});

  @override
  State<ProviderApplicationScreen> createState() =>
      _ProviderApplicationScreenState();
}

class _ProviderApplicationScreenState extends State<ProviderApplicationScreen> {
  final _formKey = GlobalKey<FormState>();

  final ProviderApplicationService _applicationService =
      ProviderApplicationService();

  late final TextEditingController _businessNameController;

  late final TextEditingController _descriptionController;

  late final TextEditingController _addressController;

  late final TextEditingController _identityNumberController;

  late final TextEditingController _experienceYearsController;

  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();

    final application = widget.application;

    _businessNameController = TextEditingController(
      text: application?.businessName ?? '',
    );

    _descriptionController = TextEditingController(
      text: application?.description ?? '',
    );

    _addressController = TextEditingController(
      text: application?.address ?? '',
    );

    _identityNumberController = TextEditingController(
      text: application?.identityNumber ?? '',
    );

    _experienceYearsController = TextEditingController(
      text: application != null ? application.experienceYears.toString() : '',
    );
  }

  @override
  void dispose() {
    _businessNameController.dispose();
    _descriptionController.dispose();
    _addressController.dispose();
    _identityNumberController.dispose();
    _experienceYearsController.dispose();

    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() || _isSubmitting) {
      return;
    }

    final experienceYears = int.tryParse(
      _experienceYearsController.text.trim(),
    );

    if (experienceYears == null) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      await _applicationService.submit(
        businessName: _businessNameController.text,

        description: _descriptionController.text,

        address: _addressController.text,

        identityNumber: _identityNumberController.text,

        experienceYears: experienceYears,
      );

      if (!mounted) {
        return;
      }

      await context.read<AuthProvider>().refreshCurrentUser();

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã gửi hồ sơ đăng ký Nhà cung cấp.')),
      );

      Navigator.pop(context, true);
    } on ProviderApplicationException catch (e) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.message)));
    } catch (_) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Không thể gửi hồ sơ. Vui lòng thử lại.')),
      );
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
    final isResubmit = widget.application?.isRejected == true;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isResubmit ? 'Cập nhật hồ sơ Nhà cung cấp' : 'Đăng ký Nhà cung cấp',
        ),
      ),

      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text(
                'Thông tin Nhà cung cấp',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 8),

              const Text(
                'Thông tin này sẽ được quản trị viên kiểm tra trước khi cấp quyền Nhà cung cấp.',
              ),

              const SizedBox(height: 24),

              TextFormField(
                controller: _businessNameController,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Tên Nhà cung cấp',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.business),
                ),
                validator: (value) {
                  final text = value?.trim() ?? '';

                  if (text.isEmpty) {
                    return 'Vui lòng nhập tên Nhà cung cấp.';
                  }

                  if (text.length < 2) {
                    return 'Tên phải có ít nhất 2 ký tự.';
                  }

                  if (text.length > 150) {
                    return 'Tên không được vượt quá 150 ký tự.';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _descriptionController,
                minLines: 3,
                maxLines: 5,
                decoration: const InputDecoration(
                  labelText: 'Giới thiệu',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                  prefixIcon: Icon(Icons.description),
                ),
                validator: (value) {
                  if (value != null && value.trim().length > 2000) {
                    return 'Giới thiệu không được vượt quá 2000 ký tự.';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _addressController,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Địa chỉ',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.location_on),
                ),
                validator: (value) {
                  final text = value?.trim() ?? '';

                  if (text.isEmpty) {
                    return 'Vui lòng nhập địa chỉ.';
                  }

                  if (text.length > 255) {
                    return 'Địa chỉ không được vượt quá 255 ký tự.';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _identityNumberController,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Số giấy tờ định danh',
                  hintText: 'CCCD hoặc giấy tờ tương đương',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.badge_outlined),
                ),
                validator: (value) {
                  final text = value?.trim() ?? '';

                  if (text.isEmpty) {
                    return 'Vui lòng nhập số giấy tờ định danh.';
                  }

                  if (text.length > 50) {
                    return 'Số giấy tờ không hợp lệ.';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _experienceYearsController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Số năm kinh nghiệm',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.work_outline),
                ),
                validator: (value) {
                  final years = int.tryParse(value?.trim() ?? '');

                  if (years == null) {
                    return 'Vui lòng nhập số năm kinh nghiệm.';
                  }

                  if (years < 0 || years > 80) {
                    return 'Số năm kinh nghiệm phải từ 0 đến 80.';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 28),

              FilledButton.icon(
                onPressed: _isSubmitting ? null : _submit,
                icon: _isSubmitting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.send_outlined),
                label: Text(
                  _isSubmitting
                      ? 'Đang gửi...'
                      : isResubmit
                      ? 'Gửi lại hồ sơ'
                      : 'Gửi hồ sơ đăng ký',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
