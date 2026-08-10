import 'package:flutter/material.dart';

import '../../core/ui/app_responsive.dart';
import '../../core/ui/app_theme.dart';
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
  bool _hasChanges = false;

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

    // Listener đặt sau prefill.
    for (final controller in [
      _businessNameController,
      _descriptionController,
      _addressController,
      _experienceController,
    ]) {
      controller.addListener(() {
        if (!_hasChanges && mounted) {
          setState(() {
            _hasChanges = true;
          });
        }
      });
    }
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
    if (_isSubmitting || !_formKey.currentState!.validate()) {
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
        businessName: _businessNameController.text.trim(),
        description: _descriptionController.text.trim(),
        address: _addressController.text.trim(),
        experienceYears: experienceYears,
      );

      if (!mounted) return;

      _hasChanges = false;

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

  Future<bool> _confirmDiscard() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Bỏ thay đổi?'),
        content: const Text('Những thay đổi chưa được lưu sẽ bị mất.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Tiếp tục chỉnh sửa'),
          ),

          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Bỏ thay đổi'),
          ),
        ],
      ),
    );

    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_hasChanges || _isSubmitting,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop || !_hasChanges || _isSubmitting) {
          return;
        }

        final discard = await _confirmDiscard();

        if (discard && context.mounted) {
          Navigator.pop(context);
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(title: const Text('Chỉnh sửa hồ sơ')),

        body: Form(
          key: _formKey,
          child: ListView(
            padding: AppResponsive.pagePadding(context, top: 18, bottom: 120),
            children: [
              Container(
                padding: EdgeInsets.all(18.rw(context)),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(17.rr(context)),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Thông tin nhà cung cấp',
                      style: TextStyle(
                        fontSize: 19.rf(context),
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    SizedBox(height: 18.rw(context)),

                    TextFormField(
                      controller: _businessNameController,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'Tên nhà cung cấp',
                        prefixIcon: Icon(Icons.business_outlined),
                      ),
                      validator: (value) {
                        final text = value?.trim() ?? '';

                        if (text.length < 2) {
                          return 'Tên nhà cung cấp tối thiểu 2 ký tự';
                        }

                        if (text.length > 150) {
                          return 'Tên nhà cung cấp không được vượt quá 150 ký tự';
                        }

                        return null;
                      },
                    ),

                    SizedBox(height: 14.rw(context)),

                    TextFormField(
                      controller: _addressController,
                      minLines: 1,
                      maxLines: 2,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'Địa chỉ / Khu vực hoạt động',
                        prefixIcon: Icon(Icons.location_on_outlined),
                      ),
                      validator: (value) {
                        final text = value?.trim() ?? '';

                        if (text.length > 255) {
                          return 'Địa chỉ không được vượt quá 255 ký tự';
                        }

                        return null;
                      },
                    ),

                    SizedBox(height: 14.rw(context)),

                    TextFormField(
                      controller: _experienceController,
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'Số năm kinh nghiệm',
                        prefixIcon: Icon(Icons.work_outline),
                        suffixText: 'năm',
                      ),
                      validator: (value) {
                        final years = int.tryParse(value?.trim() ?? '');

                        if (years == null || years < 0 || years > 80) {
                          return 'Số năm kinh nghiệm không hợp lệ';
                        }

                        return null;
                      },
                    ),

                    SizedBox(height: 14.rw(context)),

                    TextFormField(
                      controller: _descriptionController,
                      minLines: 4,
                      maxLines: 7,
                      maxLength: 2000,
                      decoration: const InputDecoration(
                        labelText: 'Giới thiệu',
                        hintText:
                            'Mô tả kinh nghiệm, chuyên môn và dịch vụ của bạn...',
                        alignLabelWithHint: true,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 18.rw(context)),

              Container(
                padding: EdgeInsets.all(16.rw(context)),
                decoration: BoxDecoration(
                  color: AppColors.softBlue,
                  borderRadius: BorderRadius.circular(15.rr(context)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.info_outline_rounded,
                      color: AppColors.primary,
                    ),

                    SizedBox(width: 10.rw(context)),

                    Expanded(
                      child: Text(
                        'Thông tin hồ sơ sẽ được hiển thị cho khách hàng khi họ xem dịch vụ của bạn.',
                        style: TextStyle(
                          fontSize: 13.rf(context),
                          color: AppColors.textSecondary,
                          height: 1.45,
                        ),
                      ),
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
                  : const Text('Lưu thay đổi'),
            ),
          ),
        ),
      ),
    );
  }
}
