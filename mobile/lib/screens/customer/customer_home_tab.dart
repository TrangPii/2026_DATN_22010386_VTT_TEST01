import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/service.dart';
import '../../models/service_category.dart';
import '../../providers/auth_provider.dart';
import '../../services/catalog_service.dart';
import 'service_detail_screen.dart';

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

      if (!mounted) {
        return;
      }

      setState(() {
        _categories = results[0] as List<ServiceCategory>;

        _services = results[1] as List<Service>;
      });
    } catch (e) {
      if (!mounted) {
        return;
      }

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
        search: _searchController.text,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _services = services;
      });
    } catch (e) {
      if (!mounted) {
        return;
      }

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

  String _formatPrice(double value) {
    return NumberFormat.currency(
      locale: 'vi_VN',
      symbol: '₫',
      decimalDigits: 0,
    ).format(value);
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;

    return RefreshIndicator(
      onRefresh: _loadInitialData,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        children: [
          Text('Xin chào,', style: Theme.of(context).textTheme.bodyLarge),

          const SizedBox(height: 4),

          Text(
            user?.name ?? 'Khách hàng',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 20),

          SearchBar(
            controller: _searchController,
            hintText: 'Tìm dịch vụ...',
            leading: const Icon(Icons.search),
            trailing: [
              IconButton(
                onPressed: () {
                  _searchController.clear();
                  _loadServices();
                },
                icon: const Icon(Icons.clear),
              ),
            ],
            onSubmitted: (_) {
              _loadServices();
            },
          ),

          const SizedBox(height: 28),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Danh mục',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),

              if (_selectedCategoryId != null)
                TextButton(
                  onPressed: () {
                    setState(() {
                      _selectedCategoryId = null;
                    });

                    _loadServices();
                  },
                  child: const Text('Tất cả'),
                ),
            ],
          ),

          const SizedBox(height: 12),

          SizedBox(
            height: 100,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _categories.length,
              separatorBuilder: (_, _) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final category = _categories[index];

                final selected = category.id == _selectedCategoryId;

                return InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () {
                    setState(() {
                      _selectedCategoryId = category.id;
                    });

                    _loadServices();
                  },
                  child: Container(
                    width: 130,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: selected
                          ? Theme.of(context).colorScheme.primaryContainer
                          : Theme.of(
                              context,
                            ).colorScheme.surfaceContainerHighest,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.home_repair_service),

                        const SizedBox(height: 8),

                        Text(
                          category.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 28),

          Text(
            _selectedCategoryId == null ? 'Dịch vụ nổi bật' : 'Dịch vụ',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 12),

          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(40),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_error != null)
            _ErrorView(message: _error!, onRetry: _loadInitialData)
          else if (_services.isEmpty)
            const Padding(
              padding: EdgeInsets.all(32),
              child: Center(child: Text('Không tìm thấy dịch vụ.')),
            )
          else
            ..._services.map(
              (service) => _ServiceCard(
                service: service,
                priceText:
                    '${_formatPrice(service.price)} / ${service.priceUnit}',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ServiceDetailScreen(service: service),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

class _ServiceCard extends StatelessWidget {
  final Service service;
  final String priceText;
  final VoidCallback onTap;

  const _ServiceCard({
    required this.service,
    required this.priceText,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                ),
                child: service.image == null
                    ? const Icon(Icons.home_repair_service, size: 36)
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          service.image!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.home_repair_service),
                        ),
                      ),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      service.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),

                    const SizedBox(height: 5),

                    Text(
                      service.provider?.businessName ??
                          service.provider?.name ??
                          'Nhà cung cấp',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 8),

                    Text(
                      priceText,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const Icon(Icons.error_outline, size: 44),

          const SizedBox(height: 12),

          Text(message, textAlign: TextAlign.center),

          const SizedBox(height: 12),

          OutlinedButton(onPressed: onRetry, child: const Text('Thử lại')),
        ],
      ),
    );
  }
}
