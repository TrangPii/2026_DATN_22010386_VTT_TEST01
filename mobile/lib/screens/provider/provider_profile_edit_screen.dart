import 'package:flutter/material.dart';

import '../../models/provider_profile.dart';
import '../../services/provider_profile_service.dart';

class ProviderProfileEditScreen extends StatefulWidget {
  final ProviderProfile profile;

  const ProviderProfileEditScreen({super.key, required this.profile});

  @override
  State<ProviderProfileEditScreen> createState() =>
      _ProviderProfileEditScreenState();
}

class _ProviderProfileEditScreenState extends State<ProviderProfileEditScreen> {
  final _formKey = GlobalKey<FormState>();

  final ProviderProfileService _profileService = ProviderProfileService();

  late final TextEditingController _businessNameController;

  late final TextEditingController _descriptionController;

  late final TextEditingController _addressController;

  late final TextEditingController _experienceController;

  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();

    _businessNameController = TextEditingController(
      text: widget.profile.businessName,
    );

    _descriptionController = TextEditingController(
      text: widget.profile.description ?? '',
    );

    _addressController = TextEditingController(
      text: widget.profile.address ?? '',
    );

    _experienceController = TextEditingController(
      text: widget.profile.experienceYears.toString(),
    );
  }

  @override
  void dispose() {
    _businessNameController.dispose();
    _descriptionController.dispose();
    _addressController.dispose();
    _experienceController.dispose();

    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final experienceYears = int.tryParse(_experienceController.text.trim());

    if (experienceYears == null) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final updated = await _profileService.updateProfile(
        businessName: _businessNameController.text,

        description: _descriptionController.text,

        address: _addressController.text,

        experienceYears: experienceYears,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cập nhật hồ sơ thành công.')),
      );

      Navigator.pop(context, updated);
    } on ProviderProfileException catch (e) {
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
      appBar: AppBar(title: const Text('Cập nhật hồ sơ')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            TextFormField(
              controller: _businessNameController,
              decoration: const InputDecoration(
                labelText: 'Tên nhà cung cấp',
                border: OutlineInputBorder(),
              ),
              validator: (value) => value == null || value.trim().length < 2
                  ? 'Tên nhà cung cấp tối thiểu 2 ký tự'
                  : null,
            ),

            const SizedBox(height: 16),

            TextFormField(
              controller: _descriptionController,
              maxLines: 5,
              decoration: const InputDecoration(
                labelText: 'Mô tả',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            TextFormField(
              controller: _addressController,
              decoration: const InputDecoration(
                labelText: 'Địa chỉ',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            TextFormField(
              controller: _experienceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Số năm kinh nghiệm',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                final years = int.tryParse(value?.trim() ?? '');

                if (years == null || years < 0 || years > 80) {
                  return 'Số năm kinh nghiệm không hợp lệ';
                }

                return null;
              },
            ),

            const SizedBox(height: 28),

            FilledButton(
              onPressed: _isSubmitting ? null : _submit,
              child: _isSubmitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Lưu thay đổi'),
            ),
          ],
        ),
      ),
    );
  }
}
