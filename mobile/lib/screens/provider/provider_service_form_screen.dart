import 'package:flutter/material.dart';

import '../../core/ui/app_responsive.dart';
import '../../core/ui/app_theme.dart';
import '../../models/service.dart';
import '../../models/service_category.dart';
import '../../services/catalog_service.dart';
import '../../services/provider_service_api.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';

class ProviderServiceFormScreen extends StatefulWidget {
  final Service? service;

  const ProviderServiceFormScreen({super.key, this.service});

  bool get isEditing => service != null;

  @override
  State<ProviderServiceFormScreen> createState() =>
      _ProviderServiceFormScreenState();
}

class _ProviderServiceFormScreenState extends State<ProviderServiceFormScreen> {
  final _formKey = GlobalKey<FormState>();

  final ProviderServiceApi _serviceApi = ProviderServiceApi();

  final CatalogService _catalogService = CatalogService();

  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _priceUnitController = TextEditingController(text: 'lần');
  final _durationController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();
  XFile? _selectedImage;
  String? _existingImageUrl;

  List<ServiceCategory> _categories = [];

  int? _categoryId;

  bool _isLoading = true;
  bool _isSubmitting = false;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();

    final service = widget.service;

    // Prefill dữ liệu khi đang chỉnh sửa dịch vụ
    if (service != null) {
      _nameController.text = service.name;
      _descriptionController.text = service.description ?? '';

      _priceController.text = service.price.toStringAsFixed(0);

      _priceUnitController.text = service.priceUnit;

      _durationController.text =
          service.estimatedDurationMinutes?.toString() ?? '';

      _categoryId = service.category?.id;

      _existingImageUrl = service.image;
    }

    for (final controller in [
      _nameController,
      _descriptionController,
      _priceController,
      _priceUnitController,
      _durationController,
    ]) {
      controller.addListener(() {
        if (!_hasChanges && mounted) {
          setState(() {
            _hasChanges = true;
          });
        }
      });
    }

    _loadCategories();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _priceUnitController.dispose();
    _durationController.dispose();

    super.dispose();
  }

  Future<void> _loadCategories() async {
    try {
      final categories = await _catalogService.getCategories();

      if (!mounted) return;

      setState(() {
        _categories = categories;

        if (_categoryId == null && categories.isNotEmpty) {
          _categoryId = categories.first.id;
        }
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _pickImage() async {
    final image = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
      maxWidth: 1600,
    );

    if (image == null || !mounted) {
      return;
    }

    setState(() {
      _selectedImage = image;
      _hasChanges = true;
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_categoryId == null) {
      return;
    }

    final price = double.tryParse(_priceController.text.trim());

    if (price == null) {
      return;
    }

    final duration = _durationController.text.trim().isEmpty
        ? null
        : int.tryParse(_durationController.text.trim());

    setState(() {
      _isSubmitting = true;
    });

    try {
      if (widget.isEditing) {
        await _serviceApi.updateService(
          id: widget.service!.id,
          categoryId: _categoryId!,
          name: _nameController.text,
          description: _descriptionController.text,
          price: price,
          priceUnit: _priceUnitController.text,
          estimatedDurationMinutes: duration,
          image: _selectedImage,
        );
      } else {
        await _serviceApi.createService(
          categoryId: _categoryId!,
          name: _nameController.text,
          description: _descriptionController.text,
          price: price,
          priceUnit: _priceUnitController.text,
          estimatedDurationMinutes: duration,
          image: _selectedImage,
        );
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.isEditing
                ? 'Cập nhật dịch vụ thành công.'
                : 'Tạo dịch vụ thành công.',
          ),
        ),
      );

      _hasChanges = false;
      Navigator.pop(context, true);
    } on ProviderServiceException catch (e) {
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

  Widget _imagePlaceholder(BuildContext context) {
    return Container(
      color: AppColors.softGray,
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.image_outlined,
            size: 42.ri(context),
            color: AppColors.textSecondary,
          ),
          SizedBox(height: 8.rw(context)),
          Text(
            'Chưa có hình ảnh',
            style: TextStyle(
              fontSize: 13.rf(context),
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Future<bool> _confirmDiscard() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Bỏ thay đổi?'),
        content: const Text('Những thay đổi chưa được lưu sẽ bị mất.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Tiếp tục chỉnh sửa'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Bỏ thay đổi'),
          ),
        ],
      ),
    );

    return result ?? false;
  }

  Widget _buildImagePreview(BuildContext context) {
    if (_selectedImage != null) {
      return FutureBuilder<List<int>>(
        future: _selectedImage!.readAsBytes(),

        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          return Image.memory(
            Uint8List.fromList(snapshot.data!),
            fit: BoxFit.cover,
          );
        },
      );
    }

    if (_existingImageUrl != null && _existingImageUrl!.isNotEmpty) {
      return Image.network(
        _existingImageUrl!,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => _imagePlaceholder(context),
      );
    }

    return _imagePlaceholder(context);
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
        appBar: AppBar(
          title: Text(widget.isEditing ? 'Chỉnh sửa dịch vụ' : 'Thêm dịch vụ'),
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Form(
                key: _formKey,
                child: ListView(
                  padding: AppResponsive.pagePadding(
                    context,
                    top: 18,
                    bottom: 120,
                  ),
                  children: [
                    // IMAGE
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
                            'Hình ảnh dịch vụ',
                            style: TextStyle(
                              fontSize: 18.rf(context),
                              fontWeight: FontWeight.w700,
                            ),
                          ),

                          SizedBox(height: 14.rw(context)),

                          ClipRRect(
                            borderRadius: BorderRadius.circular(14.rr(context)),
                            child: AspectRatio(
                              aspectRatio: 16 / 8,
                              child: _buildImagePreview(context),
                            ),
                          ),

                          SizedBox(height: 14.rw(context)),

                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: _isSubmitting ? null : _pickImage,
                              icon: const Icon(Icons.photo_library_outlined),
                              label: Text(
                                _selectedImage == null
                                    ? 'Chọn ảnh từ thư viện'
                                    : 'Chọn ảnh khác',
                              ),
                            ),
                          ),

                          SizedBox(height: 7.rw(context)),

                          Text(
                            'Hỗ trợ JPG, JPEG, PNG, WEBP. Dung lượng tối đa 4 MB.',
                            style: TextStyle(
                              fontSize: 12.rf(context),
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 18.rw(context)),

                    // MAIN INFO
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
                          DropdownButtonFormField<int>(
                            initialValue: _categoryId,
                            decoration: const InputDecoration(
                              labelText: 'Danh mục',
                              prefixIcon: Icon(Icons.category_outlined),
                            ),
                            items: _categories
                                .map(
                                  (category) => DropdownMenuItem(
                                    value: category.id,
                                    child: Text(category.name),
                                  ),
                                )
                                .toList(),
                            onChanged: (value) {
                              setState(() {
                                _categoryId = value;
                                _hasChanges = true;
                              });
                            },
                            validator: (value) =>
                                value == null ? 'Vui lòng chọn danh mục' : null,
                          ),

                          SizedBox(height: 14.rw(context)),

                          TextFormField(
                            controller: _nameController,
                            textInputAction: TextInputAction.next,
                            decoration: const InputDecoration(
                              labelText: 'Tên dịch vụ',
                              hintText: 'Nhập tên dịch vụ...',
                            ),
                            validator: (value) =>
                                value == null || value.trim().length < 3
                                ? 'Tên dịch vụ tối thiểu 3 ký tự'
                                : null,
                          ),

                          SizedBox(height: 14.rw(context)),

                          TextFormField(
                            controller: _descriptionController,
                            minLines: 4,
                            maxLines: 6,
                            decoration: const InputDecoration(
                              labelText: 'Mô tả dịch vụ',
                              hintText: 'Mô tả chi tiết về dịch vụ của bạn...',
                              alignLabelWithHint: true,
                            ),
                          ),

                          SizedBox(height: 14.rw(context)),

                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 3,
                                child: TextFormField(
                                  controller: _priceController,
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(
                                    labelText: 'Giá dịch vụ',
                                    suffixText: 'VNĐ',
                                  ),
                                  validator: (value) {
                                    final number = double.tryParse(
                                      value?.trim() ?? '',
                                    );

                                    if (number == null || number < 0) {
                                      return 'Giá không hợp lệ';
                                    }

                                    return null;
                                  },
                                ),
                              ),

                              SizedBox(width: 12.rw(context)),

                              Expanded(
                                flex: 2,
                                child: TextFormField(
                                  controller: _priceUnitController,
                                  decoration: const InputDecoration(
                                    labelText: 'Đơn vị',
                                    hintText: 'Giờ',
                                  ),
                                  validator: (value) =>
                                      value == null || value.trim().isEmpty
                                      ? 'Bắt buộc'
                                      : null,
                                ),
                              ),
                            ],
                          ),

                          SizedBox(height: 14.rw(context)),

                          TextFormField(
                            controller: _durationController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Thời gian dự kiến',
                              hintText: 'Ví dụ: 120',
                              suffixText: 'phút',
                              prefixIcon: Icon(Icons.schedule_outlined),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return null;
                              }

                              final minutes = int.tryParse(value.trim());

                              if (minutes == null || minutes <= 0) {
                                return 'Thời gian không hợp lệ';
                              }

                              return null;
                            },
                          ),
                        ],
                      ),
                    ),

                    if (widget.isEditing) ...[
                      SizedBox(height: 18.rw(context)),

                      Container(
                        padding: EdgeInsets.all(17.rw(context)),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(16.rr(context)),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Trạng thái dịch vụ',
                                    style: TextStyle(
                                      fontSize: 16.rf(context),
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  SizedBox(height: 4.rw(context)),
                                  Text(
                                    widget.service!.status == 'ACTIVE'
                                        ? 'Dịch vụ hiện đang hoạt động.'
                                        : 'Dịch vụ hiện đang tạm ngừng.',
                                    style: TextStyle(
                                      fontSize: 12.5.rf(context),
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 10.rw(context),
                                vertical: 5.rw(context),
                              ),
                              decoration: BoxDecoration(
                                color: widget.service!.status == 'ACTIVE'
                                    ? const Color(0xFFF0FDF4)
                                    : AppColors.softGray,
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                widget.service!.status == 'ACTIVE'
                                    ? 'Đang hoạt động'
                                    : 'Tạm ngừng',
                                style: TextStyle(
                                  fontSize: 11.5.rf(context),
                                  fontWeight: FontWeight.w600,
                                  color: widget.service!.status == 'ACTIVE'
                                      ? AppColors.success
                                      : AppColors.textSecondary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
        bottomNavigationBar: _isLoading
            ? null
            : SafeArea(
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
                        : Text(
                            widget.isEditing ? 'Lưu thay đổi' : 'Tạo dịch vụ',
                          ),
                  ),
                ),
              ),
      ),
    );
  }
}
