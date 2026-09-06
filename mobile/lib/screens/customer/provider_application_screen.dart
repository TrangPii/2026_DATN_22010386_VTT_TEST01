import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/ui/app_responsive.dart';
import '../../core/ui/app_theme.dart';
import '../../models/provider_application.dart';
import '../../providers/auth_provider.dart';
import '../../services/provider_application_service.dart';
import '../../models/vietnam_address.dart';
import '../../widgets/vietnam_address_picker.dart';

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

  late final TextEditingController _identityNumberController;

  late final TextEditingController _experienceYearsController;

  VietnamProvince? _selectedProvince;
  VietnamWard? _selectedWard;

  String? _addressPickerError;

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

    _identityNumberController = TextEditingController(
      text: application?.identityNumber ?? '',
    );

    _experienceYearsController = TextEditingController(
      text: application != null ? application.experienceYears.toString() : '',
    );
  }

  Future<void> _pickAddress() async {
    final result = await VietnamAddressPicker.show(
      context: context,
      initialProvinceCode: _selectedProvince?.code,
      initialWardCode: _selectedWard?.code,
    );

    if (result == null) {
      return;
    }

    setState(() {
      _selectedProvince = result.province;
      _selectedWard = result.ward;
      _addressPickerError = null;
    });
  }

  @override
  void dispose() {
    _businessNameController.dispose();
    _descriptionController.dispose();
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

    final address =
        '${_selectedProvince!.displayName}, '
        '${_selectedWard!.name}';

    if (_selectedProvince == null || _selectedWard == null) {
      setState(() {
        _addressPickerError = 'Vui lòng chọn tỉnh/thành phố và xã/phường.';
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn khu vực hoạt động.')),
      );

      return;
    }

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

        address: address,

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
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          isResubmit
              ? 'Cập nhật hồ sơ Nhà cung cấp'
              : 'Đăng ký trở thành nhà cung cấp',
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: AppResponsive.pagePadding(context, top: 18, bottom: 110),
          children: [
            // INTRO
            Container(
              padding: EdgeInsets.all(20.rw(context)),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(18.rr(context)),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  Container(
                    width: 70.rw(context),
                    height: 70.rw(context),
                    decoration: const BoxDecoration(
                      color: AppColors.softBlue,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.verified_user_outlined,
                      size: 34.ri(context),
                      color: AppColors.primary,
                    ),
                  ),
                  SizedBox(height: 16.rw(context)),
                  Text(
                    isResubmit
                        ? 'Cập nhật hồ sơ của bạn'
                        : 'Tham gia đội ngũ chuyên gia',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 21.rf(context),
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                  SizedBox(height: 8.rw(context)),
                  Text(
                    isResubmit
                        ? 'Kiểm tra và cập nhật lại thông tin trước khi gửi hồ sơ xét duyệt.'
                        : 'Hoàn thiện thông tin để bắt đầu cung cấp dịch vụ trên Smart Service.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13.5.rf(context),
                      color: AppColors.textSecondary,
                      height: 1.45,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 18.rw(context)),

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
                  Row(
                    children: [
                      const Icon(
                        Icons.storefront_outlined,
                        color: AppColors.primary,
                      ),
                      SizedBox(width: 9.rw(context)),
                      Text(
                        'Thông tin nhà cung cấp',
                        style: TextStyle(
                          fontSize: 19.rf(context),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 20.rw(context)),

                  TextFormField(
                    controller: _businessNameController,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: 'Tên hiển thị / Tên nhà cung cấp',
                      hintText: 'Ví dụ: Dịch vụ Điện lạnh Hùng Phát',
                      prefixIcon: Icon(Icons.business_outlined),
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

                  SizedBox(height: 14.rw(context)),

                  TextFormField(
                    controller: _descriptionController,
                    minLines: 4,
                    maxLines: 6,
                    decoration: const InputDecoration(
                      labelText: 'Giới thiệu bản thân / Doanh nghiệp',
                      hintText: 'Mô tả ngắn về dịch vụ và điểm mạnh của bạn...',
                      alignLabelWithHint: true,
                    ),
                    validator: (value) {
                      if (value != null && value.trim().length > 2000) {
                        return 'Giới thiệu không được vượt quá 2000 ký tự.';
                      }

                      return null;
                    },
                  ),

                  SizedBox(height: 14.rw(context)),

                  FormField<VietnamAddressSelection>(
                    validator: (_) {
                      if (_selectedProvince == null || _selectedWard == null) {
                        return 'Vui lòng chọn tỉnh/thành phố và xã/phường.';
                      }

                      return null;
                    },
                    builder: (field) {
                      final hasError = field.hasError;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          InkWell(
                            onTap: _pickAddress,
                            borderRadius: BorderRadius.circular(14.rr(context)),
                            child: Container(
                              padding: EdgeInsets.all(15.rw(context)),
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius: BorderRadius.circular(
                                  14.rr(context),
                                ),
                                border: Border.all(
                                  color: hasError
                                      ? Theme.of(context).colorScheme.error
                                      : AppColors.border,
                                ),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.location_on_outlined,
                                    color: AppColors.primary,
                                  ),
                                  SizedBox(width: 13.rw(context)),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Khu vực hoạt động',
                                          style: TextStyle(
                                            fontSize: 12.rf(context),
                                            color: AppColors.textSecondary,
                                          ),
                                        ),
                                        SizedBox(height: 4.rw(context)),
                                        Text(
                                          _selectedProvince == null ||
                                                  _selectedWard == null
                                              ? 'Chọn tỉnh/thành phố, xã/phường'
                                              : '${_selectedProvince!.displayName} • '
                                                    '${_selectedWard!.name}',
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: 15.rf(context),
                                            fontWeight: FontWeight.w500,
                                            color: _selectedProvince == null
                                                ? AppColors.textSecondary
                                                : null,
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
                          ),

                          if (hasError) ...[
                            SizedBox(height: 6.rw(context)),
                            Padding(
                              padding: EdgeInsets.only(left: 16.rw(context)),
                              child: Text(
                                field.errorText!,
                                style: TextStyle(
                                  fontSize: 12.rf(context),
                                  color: Theme.of(context).colorScheme.error,
                                ),
                              ),
                            ),
                          ],
                        ],
                      );
                    },
                  ),

                  SizedBox(height: 14.rw(context)),

                  TextFormField(
                    controller: _identityNumberController,
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: 'Số giấy tờ định danh',
                      hintText: 'CCCD hoặc giấy tờ tương đương',
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

                  SizedBox(height: 14.rw(context)),

                  TextFormField(
                    controller: _experienceYearsController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Số năm kinh nghiệm',
                      hintText: 'Ví dụ: 3',
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
                ],
              ),
            ),

            SizedBox(height: 18.rw(context)),

            Container(
              padding: EdgeInsets.all(16.rw(context)),
              decoration: BoxDecoration(
                color: AppColors.softBlue,
                borderRadius: BorderRadius.circular(15.rr(context)),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.18),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.info_outline_rounded,
                    color: AppColors.primary,
                  ),
                  SizedBox(width: 12.rw(context)),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Quy trình duyệt hồ sơ',
                          style: TextStyle(
                            fontSize: 15.rf(context),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: 4.rw(context)),
                        Text(
                          'Sau khi gửi, quản trị viên sẽ kiểm tra thông tin. Bạn chỉ có thể sử dụng chế độ Provider sau khi hồ sơ được phê duyệt.',
                          style: TextStyle(
                            fontSize: 13.rf(context),
                            color: AppColors.textSecondary,
                            height: 1.45,
                          ),
                        ),
                      ],
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
          color: AppColors.surface,
          padding: EdgeInsets.fromLTRB(
            AppResponsive.horizontalPadding(context),
            12.rw(context),
            AppResponsive.horizontalPadding(context),
            12.rw(context),
          ),
          child: FilledButton.icon(
            onPressed: _isSubmitting ? null : _submit,
            icon: _isSubmitting
                ? SizedBox(
                    width: 18.rw(context),
                    height: 18.rw(context),
                    child: const CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.send_outlined),
            label: Text(
              _isSubmitting
                  ? 'Đang gửi...'
                  : isResubmit
                  ? 'Gửi lại hồ sơ'
                  : 'Gửi hồ sơ',
            ),
          ),
        ),
      ),
    );
  }
}
