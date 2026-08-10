import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/ui/app_responsive.dart';
import '../../core/ui/app_theme.dart';
import '../../models/service.dart';
import '../../models/service_category.dart';
import '../../providers/auth_provider.dart';
import '../../services/catalog_service.dart';
import 'service_detail_screen.dart';
import 'customer_service_list_screen.dart';

class CustomerHomeTab extends StatefulWidget {
  const CustomerHomeTab({super.key});

  @override
  State<CustomerHomeTab> createState() => _CustomerHomeTabState();
}

class _CustomerHomeTabState extends State<CustomerHomeTab> {
  final CatalogService _catalogService = CatalogService();
  final TextEditingController _searchController = TextEditingController();

  List<ServiceCategory> _categories = [];
  List<Service> _services = [];

  bool _isLoading = true;
  String? _error;

  int? _selectedCategoryId;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final results = await Future.wait([
        _catalogService.getCategories(),
        _catalogService.getServices(),
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

  Future<void> _loadServices() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final services = await _catalogService.getServices(
        categoryId: _selectedCategoryId,
        search: _searchController.text.trim(),
      );

      if (!mounted) return;

      setState(() {
        _services = services;
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

  Future<void> _selectCategory(int categoryId) async {
    setState(() {
      _selectedCategoryId = _selectedCategoryId == categoryId
          ? null
          : categoryId;
    });

    await _loadServices();
  }

  Future<void> _clearFilter() async {
    _searchController.clear();

    setState(() {
      _selectedCategoryId = null;
    });

    await _loadServices();
  }

  String _formatPrice(double value) {
    return NumberFormat.currency(
      locale: 'vi_VN',
      symbol: 'đ',
      decimalDigits: 0,
    ).format(value);
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;

    return RefreshIndicator(
      onRefresh: _loadInitialData,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: _HomeHeader(
              name: user?.name ?? 'Khách hàng',
              avatar: user?.avatar,
              searchController: _searchController,
              onSearch: _loadServices,
              onClear: _clearFilter,
            ),
          ),

          SliverPadding(
            padding: EdgeInsets.fromLTRB(
              AppResponsive.horizontalPadding(context),
              28.rw(context),
              AppResponsive.horizontalPadding(context),
              0,
            ),
            sliver: SliverToBoxAdapter(
              child: _CategorySection(
                categories: _categories,
                selectedCategoryId: _selectedCategoryId,
                onSelected: _selectCategory,
                onViewAll: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const CustomerServiceListScreen(),
                    ),
                  );
                },
              ),
            ),
          ),

          SliverPadding(
            padding: EdgeInsets.fromLTRB(
              AppResponsive.horizontalPadding(context),
              30.rw(context),
              AppResponsive.horizontalPadding(context),
              12.rw(context),
            ),
            sliver: SliverToBoxAdapter(
              child: Text(
                _selectedCategoryId == null
                    ? 'Dịch vụ nổi bật'
                    : 'Dịch vụ phù hợp',
                style: TextStyle(
                  fontSize: 24.rf(context),
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ),

          if (_isLoading)
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 48.rw(context)),
                child: const Center(child: CircularProgressIndicator()),
              ),
            )
          else if (_error != null)
            SliverPadding(
              padding: AppResponsive.pagePadding(context),
              sliver: SliverToBoxAdapter(
                child: _ErrorView(message: _error!, onRetry: _loadInitialData),
              ),
            )
          else if (_services.isEmpty)
            SliverPadding(
              padding: AppResponsive.pagePadding(context),
              sliver: SliverToBoxAdapter(
                child: _EmptyServices(onClear: _clearFilter),
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
                itemCount: _services.length,
                separatorBuilder: (_, _) => SizedBox(height: 16.rw(context)),
                itemBuilder: (context, index) {
                  final service = _services[index];

                  return _FeaturedServiceCard(
                    service: service,
                    priceText:
                        '${_formatPrice(service.price)}/${service.priceUnit}',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ServiceDetailScreen(service: service),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

// Header
class _HomeHeader extends StatelessWidget {
  final String name;
  final String? avatar;
  final TextEditingController searchController;
  final VoidCallback onSearch;
  final VoidCallback onClear;

  const _HomeHeader({
    required this.name,
    required this.avatar,
    required this.searchController,
    required this.onSearch,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final horizontal = AppResponsive.horizontalPadding(context);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        horizontal,
        18.rw(context),
        horizontal,
        28.rw(context),
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28.rr(context)),
          bottomRight: Radius.circular(28.rr(context)),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _Avatar(imageUrl: avatar, size: 54.rw(context)),

              SizedBox(width: 12.rw(context)),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Xin chào,',
                      style: TextStyle(
                        fontSize: 15.rf(context),
                        color: AppColors.textSecondary,
                      ),
                    ),
                    SizedBox(height: 2.rw(context)),
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 21.rf(context),
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: 28.rw(context)),

          Text(
            'Hôm nay bạn cần hỗ trợ gì?',
            style: TextStyle(
              fontSize: 15.rf(context),
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
              height: 1.2,
            ),
          ),

          SizedBox(height: 22.rw(context)),

          Container(
            decoration: BoxDecoration(
              color: AppColors.softGray,
              borderRadius: BorderRadius.circular(16.rr(context)),
            ),
            child: TextField(
              controller: searchController,
              textInputAction: TextInputAction.search,
              onSubmitted: (_) => onSearch(),
              decoration: InputDecoration(
                filled: false,
                hintText: 'Tìm dịch vụ bạn cần...',
                prefixIcon: Icon(
                  Icons.search_rounded,
                  size: 27.ri(context),
                  color: AppColors.textSecondary,
                ),
                suffixIcon: searchController.text.isNotEmpty
                    ? IconButton(
                        tooltip: 'Xóa tìm kiếm',
                        onPressed: onClear,
                        icon: const Icon(Icons.close_rounded),
                      )
                    : IconButton(
                        tooltip: 'Tìm kiếm',
                        onPressed: onSearch,
                        icon: const Icon(
                          Icons.tune_rounded,
                          color: AppColors.primary,
                        ),
                      ),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  vertical: 17.rw(context),
                  horizontal: 16.rw(context),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Category
class _CategorySection extends StatelessWidget {
  final List<ServiceCategory> categories;
  final int? selectedCategoryId;
  final ValueChanged<int> onSelected;
  final VoidCallback? onViewAll;

  const _CategorySection({
    required this.categories,
    required this.selectedCategoryId,
    required this.onSelected,
    required this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    if (categories.isEmpty) {
      return const SizedBox.shrink();
    }

    final visibleCategories = categories.take(4).toList();

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Danh mục dịch vụ',
                style: TextStyle(
                  fontSize: 24.rf(context),
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            TextButton(onPressed: onViewAll, child: const Text('Xem tất cả')),
          ],
        ),

        SizedBox(height: 16.rw(context)),

        LayoutBuilder(
          builder: (context, constraints) {
            final gap = 12.rw(context);

            final itemWidth = (constraints.maxWidth - (gap * 3)) / 4;

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: List.generate(visibleCategories.length, (index) {
                final category = visibleCategories[index];

                return Padding(
                  padding: EdgeInsets.only(
                    right: index == visibleCategories.length - 1 ? 0 : gap,
                  ),
                  child: SizedBox(
                    width: itemWidth,
                    child: _CategoryItem(
                      category: category,
                      selected: selectedCategoryId == category.id,
                      onTap: () => onSelected(category.id),
                    ),
                  ),
                );
              }),
            );
          },
        ),
      ],
    );
  }
}

class _CategoryItem extends StatelessWidget {
  final ServiceCategory category;
  final bool selected;
  final VoidCallback onTap;

  const _CategoryItem({
    required this.category,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final iconData = _categoryIcon(category.name);
    final iconColor = _categoryColor(category.name);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16.rr(context)),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: EdgeInsets.symmetric(
            vertical: 14.rw(context),
            horizontal: 5.rw(context),
          ),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16.rr(context)),
            border: Border.all(
              color: selected ? AppColors.primary : Colors.transparent,
              width: selected ? 1.4 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                width: 48.rw(context),
                height: 48.rw(context),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(iconData, size: 25.ri(context), color: iconColor),
              ),

              SizedBox(height: 10.rw(context)),

              Text(
                category.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13.rf(context),
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  color: selected ? AppColors.primary : AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Service card
class _FeaturedServiceCard extends StatelessWidget {
  final Service service;
  final String priceText;
  final VoidCallback onTap;

  const _FeaturedServiceCard({
    required this.service,
    required this.priceText,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final provider = service.provider;
    final imageSize = 112.rw(context);

    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(18.rr(context)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.all(14.rw(context)),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(18.rr(context)),
            border: Border.all(color: AppColors.border.withValues(alpha: 0.6)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // IMAGE
              ClipRRect(
                borderRadius: BorderRadius.circular(12.rr(context)),
                child: SizedBox(
                  width: imageSize,
                  height: imageSize,
                  child: _ServiceImage(imageUrl: service.image),
                ),
              ),

              SizedBox(width: 14.rw(context)),

              // CONTENT
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // CATEGORY + RATING
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
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

                        SizedBox(width: 6.rw(context)),

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
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 8.rw(context)),

                    // SERVICE NAME
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

                    // PROVIDER
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

                    SizedBox(height: 10.rw(context)),

                    // PRICE
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        priceText,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 18.rf(context),
                          fontWeight: FontWeight.w500,
                          color: AppColors.primary,
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

//Image/ Avatar
class _Avatar extends StatelessWidget {
  final String? imageUrl;
  final double size;

  const _Avatar({required this.imageUrl, required this.size});

  @override
  Widget build(BuildContext context) {
    if (imageUrl == null || imageUrl!.trim().isEmpty) {
      return Container(
        width: size,
        height: size,
        decoration: const BoxDecoration(
          color: AppColors.softBlue,
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.person_rounded,
          size: size * 0.55,
          color: AppColors.primary,
        ),
      );
    }

    return ClipOval(
      child: Image.network(
        imageUrl!,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => Container(
          width: size,
          height: size,
          color: AppColors.softBlue,
          alignment: Alignment.center,
          child: Icon(
            Icons.person_rounded,
            size: size * 0.55,
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }
}

class _ServiceImage extends StatelessWidget {
  final String? imageUrl;

  const _ServiceImage({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    if (imageUrl == null || imageUrl!.trim().isEmpty) {
      return Container(
        color: AppColors.softGray,
        alignment: Alignment.center,
        child: Icon(
          Icons.home_repair_service_rounded,
          size: 52.ri(context),
          color: AppColors.textSecondary,
        ),
      );
    }

    return Image.network(
      imageUrl!,
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) {
        return Container(
          color: AppColors.softGray,
          alignment: Alignment.center,
          child: Icon(
            Icons.broken_image_outlined,
            size: 46.ri(context),
            color: AppColors.textSecondary,
          ),
        );
      },
    );
  }
}

// Error
class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(24.rw(context)),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16.rr(context)),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Icon(
            Icons.error_outline_rounded,
            size: 44.ri(context),
            color: AppColors.error,
          ),
          SizedBox(height: 12.rw(context)),
          Text(
            'Không thể tải dữ liệu',
            style: TextStyle(
              fontSize: 17.rf(context),
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 6.rw(context)),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13.rf(context),
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: 16.rw(context)),
          OutlinedButton(onPressed: onRetry, child: const Text('Thử lại')),
        ],
      ),
    );
  }
}

class _EmptyServices extends StatelessWidget {
  final VoidCallback onClear;

  const _EmptyServices({required this.onClear});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(28.rw(context)),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16.rr(context)),
      ),
      child: Column(
        children: [
          Icon(
            Icons.search_off_rounded,
            size: 48.ri(context),
            color: AppColors.textSecondary,
          ),
          SizedBox(height: 12.rw(context)),
          Text(
            'Không tìm thấy dịch vụ',
            style: TextStyle(
              fontSize: 17.rf(context),
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 6.rw(context)),
          Text(
            'Hãy thử thay đổi từ khóa hoặc danh mục.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14.rf(context),
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: 16.rw(context)),
          TextButton(onPressed: onClear, child: const Text('Xóa bộ lọc')),
        ],
      ),
    );
  }
}

// Category mapping
IconData _categoryIcon(String name) {
  final normalized = name.toLowerCase();

  if (normalized.contains('dọn') || normalized.contains('vệ sinh')) {
    return Icons.cleaning_services_outlined;
  }

  if (normalized.contains('sửa') ||
      normalized.contains('điện') ||
      normalized.contains('nước')) {
    return Icons.build_outlined;
  }

  if (normalized.contains('làm đẹp')) {
    return Icons.spa_outlined;
  }

  if (normalized.contains('giáo dục') || normalized.contains('học')) {
    return Icons.school_outlined;
  }

  return Icons.home_repair_service_outlined;
}

Color _categoryColor(String name) {
  final normalized = name.toLowerCase();

  if (normalized.contains('dọn') || normalized.contains('vệ sinh')) {
    return AppColors.primary;
  }

  if (normalized.contains('sửa')) {
    return const Color(0xFF4F46E5);
  }

  if (normalized.contains('làm đẹp')) {
    return const Color(0xFFEA580C);
  }

  if (normalized.contains('giáo dục')) {
    return const Color(0xFF2563EB);
  }

  return AppColors.primary;
}
