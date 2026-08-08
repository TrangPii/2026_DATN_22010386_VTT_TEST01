import 'package:flutter/material.dart';

import '../../models/service.dart';
import '../../models/service_category.dart';
import '../../services/catalog_service.dart';
import '../../services/provider_service_api.dart';

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
  final _imageController = TextEditingController();

  List<ServiceCategory> _categories = [];

  int? _categoryId;

  bool _isLoading = true;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();

    final service = widget.service;

    if (service != null) {
      _nameController.text = service.name;
      _descriptionController.text = service.description ?? '';

      _priceController.text = service.price.toStringAsFixed(0);

      _priceUnitController.text = service.priceUnit;

      _durationController.text =
          service.estimatedDurationMinutes?.toString() ?? '';

      _imageController.text = service.image ?? '';

      _categoryId = service.category?.id;
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
    _imageController.dispose();

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
          image: _imageController.text,
        );
      } else {
        await _serviceApi.createService(
          categoryId: _categoryId!,
          name: _nameController.text,
          description: _descriptionController.text,
          price: price,
          priceUnit: _priceUnitController.text,
          estimatedDurationMinutes: duration,
          image: _imageController.text,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? 'Sửa dịch vụ' : 'Thêm dịch vụ'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  DropdownButtonFormField<int>(
                    initialValue: _categoryId,
                    decoration: const InputDecoration(
                      labelText: 'Danh mục',
                      border: OutlineInputBorder(),
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
                      });
                    },
                    validator: (value) =>
                        value == null ? 'Vui lòng chọn danh mục' : null,
                  ),

                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Tên dịch vụ',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) =>
                        value == null || value.trim().length < 3
                        ? 'Tên dịch vụ tối thiểu 3 ký tự'
                        : null,
                  ),

                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _descriptionController,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      labelText: 'Mô tả',
                      border: OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _priceController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Giá',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      final number = double.tryParse(value?.trim() ?? '');

                      if (number == null || number < 0) {
                        return 'Giá không hợp lệ';
                      }

                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _priceUnitController,
                    decoration: const InputDecoration(
                      labelText: 'Đơn vị giá',
                      hintText: 'Ví dụ: lần, giờ',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) => value == null || value.trim().isEmpty
                        ? 'Vui lòng nhập đơn vị giá'
                        : null,
                  ),

                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _durationController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Thời gian dự kiến (phút)',
                      border: OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _imageController,
                    decoration: const InputDecoration(
                      labelText: 'URL hình ảnh',
                      border: OutlineInputBorder(),
                    ),
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
                        : Text(
                            widget.isEditing ? 'Lưu thay đổi' : 'Tạo dịch vụ',
                          ),
                  ),
                ],
              ),
            ),
    );
  }
}
