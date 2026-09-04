import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/ui/app_responsive.dart';
import '../../core/ui/app_theme.dart';
import '../../models/service.dart';
import '../../models/service_category.dart';
import '../../services/catalog_service.dart';
import 'service_detail_screen.dart';

class CustomerServiceListScreen extends StatefulWidget {
  final int? initialCategoryId;

  const CustomerServiceListScreen({super.key, this.initialCategoryId});

  @override
  State<CustomerServiceListScreen> createState() =>
      _CustomerServiceListScreenState();
}

class _CustomerServiceListScreenState extends State<CustomerServiceListScreen> {
  final CatalogService _catalogService = CatalogService();
  final TextEditingController _searchController = TextEditingController();

  List<ServiceCategory> _categories = [];
  List<Service> _services = [];

  int? _selectedCategoryId;

  bool _isLoading = true;
  String? _error;

  PriceFilter _priceFilter = PriceFilter.all;
  RatingFilter _ratingFilter = RatingFilter.all;

  @override
  void initState() {
    super.initState();

    _selectedCategoryId = widget.initialCategoryId;

    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final results = await Future.wait([
        _catalogService.getCategories(),
        _catalogService.getServices(
          categoryId: _selectedCategoryId,
          search: _searchController.text.trim(),
        ),
      ]);

      if (!mounted) return;

      setState(() {
        _categories = results[0] as List<ServiceCategory>;
        _services = results[1] as List<Service>;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _error = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  List<Service> get _visibleServices {
    final result = _services.where((service) {
      final priceMatches = switch (_priceFilter) {
        PriceFilter.all => true,
        PriceFilter.under100 => service.price < 100000,
        PriceFilter.from100To300 =>
          service.price >= 100000 && service.price <= 300000,
        PriceFilter.over300 => service.price > 300000,
      };

      final rating = service.provider?.averageRating ?? 0;

      final ratingMatches = switch (_ratingFilter) {
        RatingFilter.all => true,
        RatingFilter.from4 => rating >= 4,
        RatingFilter.from45 => rating >= 4.5,
      };

      return priceMatches && ratingMatches;
    }).toList();

    return result;
  }

  String _formatPrice(double value) {
    return NumberFormat.currency(
      locale: 'vi_VN',
      symbol: 'đ',
      decimalDigits: 0,
    ).format(value);
  }

  Future<void> _selectCategory() async {
    final selected = await showModalBottomSheet<int?>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return _CategoryBottomSheet(
          categories: _categories,
          currentCategoryId: _selectedCategoryId,
        );
      },
    );

    if (!mounted) return;

    // null từ close và null từ "Tất cả" khó phân biệt,
    // bottom sheet dùng -1 cho lựa chọn "Tất cả".
    if (selected == null) return;

    setState(() {
      _selectedCategoryId = selected == -1 ? null : selected;
    });

    await _loadData();
  }

  Future<void> _selectPrice() async {
    final selected = await showModalBottomSheet<PriceFilter>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return _PriceBottomSheet(current: _priceFilter);
      },
    );

    if (selected == null || !mounted) return;

    setState(() {
      _priceFilter = selected;
    });
  }

  Future<void> _selectRating() async {
    final selected = await showModalBottomSheet<RatingFilter>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return _RatingBottomSheet(current: _ratingFilter);
      },
    );

    if (selected == null || !mounted) return;

    setState(() {
      _ratingFilter = selected;
    });
  }

  Future<void> _resetFilters() async {
    _searchController.clear();

    setState(() {
      _selectedCategoryId = null;
      _priceFilter = PriceFilter.all;
      _ratingFilter = RatingFilter.all;
    });

    await _loadData();
  }

  @override
  Widget build(BuildContext context) {
    final services = _visibleServices;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Dịch vụ')),
      body: SafeArea(
        top: false,
        child: RefreshIndicator(
          onRefresh: _loadData,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverPadding(
                padding: EdgeInsets.fromLTRB(
                  AppResponsive.horizontalPadding(context),
                  18.rw(context),
                  AppResponsive.horizontalPadding(context),
                  0,
                ),
                sliver: SliverToBoxAdapter(
                  child: _SearchField(
                    controller: _searchController,
                    onSearch: _loadData,
                  ),
                ),
              ),

              SliverPadding(
                padding: EdgeInsets.fromLTRB(
                  AppResponsive.horizontalPadding(context),
                  16.rw(context),
                  0,
                  20.rw(context),
                ),
                sliver: SliverToBoxAdapter(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _FilterChip(
                          text: 'Tất cả',
                          selected:
                              _selectedCategoryId == null &&
                              _priceFilter == PriceFilter.all &&
                              _ratingFilter == RatingFilter.all,
                          onTap: _resetFilters,
                        ),

                        SizedBox(width: 10.rw(context)),

                        _FilterChip(
                          text: _categoryLabel,
                          selected: _selectedCategoryId != null,
                          showArrow: true,
                          onTap: _selectCategory,
                        ),

                        SizedBox(width: 10.rw(context)),

                        _FilterChip(
                          text: 'Giá',
                          selected: _priceFilter != PriceFilter.all,
                          showArrow: true,
                          onTap: _selectPrice,
                        ),

                        SizedBox(width: 10.rw(context)),

                        Padding(
                          padding: EdgeInsets.only(
                            right: AppResponsive.horizontalPadding(context),
                          ),
                          child: _FilterChip(
                            text: 'Đánh giá',
                            selected: _ratingFilter != RatingFilter.all,
                            showArrow: true,
                            onTap: _selectRating,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              if (_isLoading)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 60.rw(context)),
                    child: const Center(child: CircularProgressIndicator()),
                  ),
                )
              else if (_error != null)
                SliverPadding(
                  padding: AppResponsive.pagePadding(context),
                  sliver: SliverToBoxAdapter(
                    child: _ErrorState(message: _error!, onRetry: _loadData),
                  ),
                )
              else if (services.isEmpty)
                SliverPadding(
                  padding: AppResponsive.pagePadding(context),
                  sliver: SliverToBoxAdapter(
                    child: _EmptyState(onReset: _resetFilters),
                  ),
                )
              else
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(
                    AppResponsive.horizontalPadding(context),
                    0,
                    AppResponsive.horizontalPadding(context),
                    32.rw(context),
                  ),
                  sliver: SliverList.separated(
                    itemCount: services.length,
                    separatorBuilder: (_, _) =>
                        SizedBox(height: 16.rw(context)),
                    itemBuilder: (context, index) {
                      final service = services[index];

                      return _ServiceListCard(
                        service: service,
                        priceText:
                            '${_formatPrice(service.price)}/${service.priceUnit}',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  ServiceDetailScreen(service: service),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  String get _categoryLabel {
    if (_selectedCategoryId == null) {
      return 'Danh mục';
    }

    for (final category in _categories) {
      if (category.id == _selectedCategoryId) {
        return category.name;
      }
    }

    return 'Danh mục';
  }
}

enum PriceFilter { all, under100, from100To300, over300 }

enum RatingFilter { all, from4, from45 }

class _SearchField extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSearch;

  const _SearchField({required this.controller, required this.onSearch});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.softGray,
        borderRadius: BorderRadius.circular(16.rr(context)),
      ),
      child: TextField(
        controller: controller,
        textInputAction: TextInputAction.search,
        onSubmitted: (_) => onSearch(),
        decoration: InputDecoration(
          filled: false,
          hintText: 'Tìm kiếm dịch vụ...',
          prefixIcon: Icon(
            Icons.search_rounded,
            size: 27.ri(context),
            color: AppColors.textSecondary,
          ),
          suffixIcon: IconButton(
            onPressed: onSearch,
            icon: const Icon(Icons.search_rounded, color: AppColors.primary),
          ),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String text;
  final bool selected;
  final bool showArrow;
  final VoidCallback onTap;

  const _FilterChip({
    required this.text,
    required this.selected,
    required this.onTap,
    this.showArrow = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.primary : AppColors.surface,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: 17.rw(context),
            vertical: 11.rw(context),
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: selected ? AppColors.primary : AppColors.border,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                text,
                maxLines: 1,
                style: TextStyle(
                  fontSize: 14.rf(context),
                  fontWeight: FontWeight.w600,
                  color: selected ? Colors.white : AppColors.textPrimary,
                ),
              ),
              if (showArrow) ...[
                SizedBox(width: 6.rw(context)),
                Icon(
                  Icons.keyboard_arrow_down_rounded,
                  size: 19.ri(context),
                  color: selected ? Colors.white : AppColors.textPrimary,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _ServiceListCard extends StatelessWidget {
  final Service service;
  final String priceText;
  final VoidCallback onTap;

  const _ServiceListCard({
    required this.service,
    required this.priceText,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final provider = service.provider;

    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(18.rr(context)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.all(14.rw(context)),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ServiceThumbnail(imageUrl: service.image),

              SizedBox(width: 14.rw(context)),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            service.category?.name ?? 'Dịch vụ',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 13.rf(context),
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),

                        SizedBox(width: 5.rw(context)),

                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 9.rw(context),
                            vertical: 4.rw(context),
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF5F3FF),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.star_rounded,
                                size: 15.ri(context),
                                color: AppColors.warning,
                              ),
                              SizedBox(width: 3.rw(context)),
                              Text(
                                provider != null && provider.averageRating > 0
                                    ? provider.averageRating.toStringAsFixed(1)
                                    : 'Mới',
                                style: TextStyle(
                                  fontSize: 12.5.rf(context),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 8.rw(context)),

                    Text(
                      service.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 17.rf(context),
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                        height: 1.22,
                      ),
                    ),

                    SizedBox(height: 6.rw(context)),

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

                    SizedBox(height: 12.rw(context)),

                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        priceText,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 19.rf(context),
                          color: AppColors.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ServiceThumbnail extends StatelessWidget {
  final String? imageUrl;

  const _ServiceThumbnail({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    final size = 112.rw(context);

    return ClipRRect(
      borderRadius: BorderRadius.circular(12.rr(context)),
      child: SizedBox(
        width: size,
        height: size,
        child: imageUrl == null || imageUrl!.trim().isEmpty
            ? Container(
                color: AppColors.softGray,
                alignment: Alignment.center,
                child: Icon(
                  Icons.home_repair_service_rounded,
                  size: 38.ri(context),
                  color: AppColors.textSecondary,
                ),
              )
            : Image.network(
                imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  debugPrint('CUSTOMER IMAGE ERROR: $error');
                  debugPrint('CUSTOMER IMAGE URL: $imageUrl');
                  return Container(
                    color: AppColors.softGray,
                    alignment: Alignment.center,
                    child: Icon(
                      Icons.home_repair_service_rounded,
                      size: 38.ri(context),
                      color: AppColors.textSecondary,
                    ),
                  );
                },
              ),
      ),
    );
  }
}

class _CategoryBottomSheet extends StatelessWidget {
  final List<ServiceCategory> categories;
  final int? currentCategoryId;

  const _CategoryBottomSheet({
    required this.categories,
    required this.currentCategoryId,
  });

  @override
  Widget build(BuildContext context) {
    return _SheetContainer(
      title: 'Chọn danh mục',
      child: Column(
        children: [
          _SheetOption(
            title: 'Tất cả danh mục',
            selected: currentCategoryId == null,
            onTap: () => Navigator.pop(context, -1),
          ),
          ...categories.map(
            (category) => _SheetOption(
              title: category.name,
              selected: currentCategoryId == category.id,
              onTap: () => Navigator.pop(context, category.id),
            ),
          ),
        ],
      ),
    );
  }
}

class _PriceBottomSheet extends StatelessWidget {
  final PriceFilter current;

  const _PriceBottomSheet({required this.current});

  @override
  Widget build(BuildContext context) {
    return _SheetContainer(
      title: 'Khoảng giá',
      child: Column(
        children: [
          _SheetOption(
            title: 'Tất cả mức giá',
            selected: current == PriceFilter.all,
            onTap: () => Navigator.pop(context, PriceFilter.all),
          ),
          _SheetOption(
            title: 'Dưới 100.000đ',
            selected: current == PriceFilter.under100,
            onTap: () => Navigator.pop(context, PriceFilter.under100),
          ),
          _SheetOption(
            title: '100.000đ – 300.000đ',
            selected: current == PriceFilter.from100To300,
            onTap: () => Navigator.pop(context, PriceFilter.from100To300),
          ),
          _SheetOption(
            title: 'Trên 300.000đ',
            selected: current == PriceFilter.over300,
            onTap: () => Navigator.pop(context, PriceFilter.over300),
          ),
        ],
      ),
    );
  }
}

class _RatingBottomSheet extends StatelessWidget {
  final RatingFilter current;

  const _RatingBottomSheet({required this.current});

  @override
  Widget build(BuildContext context) {
    return _SheetContainer(
      title: 'Đánh giá',
      child: Column(
        children: [
          _SheetOption(
            title: 'Tất cả đánh giá',
            selected: current == RatingFilter.all,
            onTap: () => Navigator.pop(context, RatingFilter.all),
          ),
          _SheetOption(
            title: '4.0 ★ trở lên',
            selected: current == RatingFilter.from4,
            onTap: () => Navigator.pop(context, RatingFilter.from4),
          ),
          _SheetOption(
            title: '4.5 ★ trở lên',
            selected: current == RatingFilter.from45,
            onTap: () => Navigator.pop(context, RatingFilter.from45),
          ),
        ],
      ),
    );
  }
}

class _SheetContainer extends StatelessWidget {
  final String title;
  final Widget child;

  const _SheetContainer({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        20.rw(context),
        12.rw(context),
        20.rw(context),
        24.rw(context) + MediaQuery.paddingOf(context).bottom,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24.rr(context)),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40.rw(context),
              height: 4.rw(context),
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(999),
              ),
            ),

            SizedBox(height: 18.rw(context)),

            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 20.rf(context),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),

            SizedBox(height: 12.rw(context)),

            child,
          ],
        ),
      ),
    );
  }
}

class _SheetOption extends StatelessWidget {
  final String title;
  final bool selected;
  final VoidCallback onTap;

  const _SheetOption({
    required this.title,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      onTap: onTap,
      title: Text(title),
      trailing: selected
          ? const Icon(Icons.check_circle_rounded, color: AppColors.primary)
          : null,
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onReset;

  const _EmptyState({required this.onReset});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(
          Icons.search_off_rounded,
          size: 52.ri(context),
          color: AppColors.textSecondary,
        ),
        SizedBox(height: 14.rw(context)),
        Text(
          'Không tìm thấy dịch vụ',
          style: TextStyle(
            fontSize: 18.rf(context),
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(height: 6.rw(context)),
        Text(
          'Hãy thử thay đổi từ khóa hoặc bộ lọc.',
          textAlign: TextAlign.center,
          style: const TextStyle(color: AppColors.textSecondary),
        ),
        SizedBox(height: 14.rw(context)),
        TextButton(onPressed: onReset, child: const Text('Xóa bộ lọc')),
      ],
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(
          Icons.error_outline_rounded,
          size: 48.ri(context),
          color: AppColors.error,
        ),
        SizedBox(height: 12.rw(context)),
        Text(message, textAlign: TextAlign.center),
        SizedBox(height: 14.rw(context)),
        OutlinedButton(onPressed: onRetry, child: const Text('Thử lại')),
      ],
    );
  }
}
