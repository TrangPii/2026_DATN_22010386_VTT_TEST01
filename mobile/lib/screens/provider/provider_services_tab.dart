import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/ui/app_responsive.dart';
import '../../core/ui/app_theme.dart';
import '../../models/service.dart';
import '../../services/provider_service_api.dart';
import 'provider_service_form_screen.dart';

class ProviderServicesTab extends StatefulWidget {
  const ProviderServicesTab({super.key});

  @override
  State<ProviderServicesTab> createState() => _ProviderServicesTabState();
}

class _ProviderServicesTabState extends State<ProviderServicesTab> {
  final ProviderServiceApi _serviceApi = ProviderServiceApi();

  final TextEditingController _searchController = TextEditingController();

  List<Service> _services = [];

  bool _isLoading = true;
  bool _isChangingStatus = false;

  String? _error;
  String? _status;

  @override
  void initState() {
    super.initState();
    _loadServices();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadServices() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final services = await _serviceApi.getServices(
        status: _status,
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

  Future<void> _openForm({Service? service}) async {
    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => ProviderServiceFormScreen(service: service),
      ),
    );

    if (changed == true) {
      _loadServices();
    }
  }

  Future<void> _changeStatus(Service service) async {
    if (_isChangingStatus) return;

    final activating = service.status != 'ACTIVE';

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(activating ? 'Kích hoạt dịch vụ?' : 'Tạm ngừng dịch vụ?'),
        content: Text(
          activating
              ? 'Khách hàng sẽ có thể tìm thấy và đặt dịch vụ này.'
              : 'Khách hàng sẽ tạm thời không thể đặt dịch vụ này. Bạn có thể kích hoạt lại bất cứ lúc nào.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Quay lại'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(activating ? 'Kích hoạt' : 'Tạm ngừng'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() {
      _isChangingStatus = true;
    });

    try {
      await _serviceApi.updateStatus(
        id: service.id,
        status: activating ? 'ACTIVE' : 'INACTIVE',
      );

      await _loadServices();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              activating ? 'Đã kích hoạt dịch vụ.' : 'Đã tạm ngừng dịch vụ.',
            ),
          ),
        );
      }
    } on ProviderServiceException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.message)));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isChangingStatus = false;
        });
      }
    }
  }

  String _money(double value) {
    return NumberFormat.currency(
      locale: 'vi_VN',
      symbol: 'đ',
      decimalDigits: 0,
    ).format(value);
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _loadServices,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverPadding(
            padding: EdgeInsets.fromLTRB(
              AppResponsive.horizontalPadding(context),
              22.rw(context),
              AppResponsive.horizontalPadding(context),
              16.rw(context),
            ),
            sliver: SliverToBoxAdapter(
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Dịch vụ của tôi',
                      style: TextStyle(
                        fontSize: 28.rf(context),
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  SizedBox(width: 8.rw(context)),
                  FilledButton.icon(
                    onPressed: () => _openForm(),
                    //icon: const Icon(Icons.add_rounded),
                    label: const Text(
                      ' + ',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          SliverPadding(
            padding: EdgeInsets.symmetric(
              horizontal: AppResponsive.horizontalPadding(context),
            ),
            sliver: SliverToBoxAdapter(
              child: TextField(
                controller: _searchController,
                textInputAction: TextInputAction.search,
                onSubmitted: (_) => _loadServices(),
                decoration: InputDecoration(
                  hintText: 'Tìm kiếm dịch vụ...',
                  prefixIcon: const Icon(Icons.search_rounded),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          onPressed: () {
                            _searchController.clear();
                            _loadServices();
                          },
                          icon: const Icon(Icons.close_rounded),
                        )
                      : null,
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(child: SizedBox(height: 14.rw(context))),

          SliverToBoxAdapter(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(
                horizontal: AppResponsive.horizontalPadding(context),
              ),
              child: Row(
                children: [
                  _FilterChip(
                    text: 'Tất cả',
                    selected: _status == null,
                    onTap: () {
                      setState(() {
                        _status = null;
                      });
                      _loadServices();
                    },
                  ),
                  SizedBox(width: 9.rw(context)),
                  _FilterChip(
                    text: 'Đang hoạt động',
                    selected: _status == 'ACTIVE',
                    onTap: () {
                      setState(() {
                        _status = 'ACTIVE';
                      });
                      _loadServices();
                    },
                  ),
                  SizedBox(width: 9.rw(context)),
                  _FilterChip(
                    text: 'Tạm ngừng',
                    selected: _status == 'INACTIVE',
                    onTap: () {
                      setState(() {
                        _status = 'INACTIVE';
                      });
                      _loadServices();
                    },
                  ),
                ],
              ),
            ),
          ),

          SliverToBoxAdapter(child: SizedBox(height: 20.rw(context))),

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
                child: Column(
                  children: [
                    Text(_error!, textAlign: TextAlign.center),
                    SizedBox(height: 12.rw(context)),
                    OutlinedButton(
                      onPressed: _loadServices,
                      child: const Text('Thử lại'),
                    ),
                  ],
                ),
              ),
            )
          else if (_services.isEmpty)
            SliverPadding(
              padding: AppResponsive.pagePadding(context),
              sliver: SliverToBoxAdapter(
                child: _EmptyServices(onCreate: () => _openForm()),
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

                  return _ServiceCard(
                    service: service,
                    priceText:
                        '${_money(service.price)} / ${service.priceUnit}',
                    onEdit: () => _openForm(service: service),
                    onChangeStatus: () => _changeStatus(service),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String text;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.text,
    required this.selected,
    required this.onTap,
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
            horizontal: 16.rw(context),
            vertical: 9.rw(context),
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: selected ? AppColors.primary : AppColors.border,
            ),
          ),
          child: Text(
            text,
            style: TextStyle(
              fontSize: 13.rf(context),
              fontWeight: FontWeight.w600,
              color: selected ? Colors.white : AppColors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }
}

class _ServiceCard extends StatelessWidget {
  final Service service;
  final String priceText;
  final VoidCallback onEdit;
  final VoidCallback onChangeStatus;

  const _ServiceCard({
    required this.service,
    required this.priceText,
    required this.onEdit,
    required this.onChangeStatus,
  });

  @override
  Widget build(BuildContext context) {
    final active = service.status == 'ACTIVE';

    return Container(
      padding: EdgeInsets.all(14.rw(context)),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18.rr(context)),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // LEFT: Status + Image
          SizedBox(
            width: 112.rw(context),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _ServiceStatusBadge(active: active),

                SizedBox(height: 10.rw(context)),

                _ProviderServiceThumbnail(
                  imageUrl: service.image,
                  active: active,
                ),
              ],
            ),
          ),

          SizedBox(width: 14.rw(context)),

          // RIGHT: Category + Name + Desc + Info
          Expanded(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: 150.rw(context)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // CATEGORY + MENU
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(top: 2.rw(context)),
                          child: Text(
                            service.category?.name ?? 'Dịch vụ',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 13.5.rf(context),
                              color: AppColors.textSecondary,
                              height: 1.2,
                            ),
                          ),
                        ),
                      ),

                      Transform.translate(
                        offset: Offset(7.rw(context), -8.rw(context)),
                        child: PopupMenuButton<String>(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          icon: Icon(
                            Icons.more_vert_rounded,
                            size: 24.ri(context),
                            color: AppColors.textSecondary,
                          ),
                          onSelected: (value) {
                            switch (value) {
                              case 'edit':
                                onEdit();
                                break;

                              case 'status':
                                onChangeStatus();
                                break;
                            }
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'edit',
                              child: Row(
                                children: [
                                  Icon(Icons.edit_outlined),
                                  SizedBox(width: 12),
                                  Text('Chỉnh sửa'),
                                ],
                              ),
                            ),

                            PopupMenuItem(
                              value: 'status',
                              child: Row(
                                children: [
                                  Icon(
                                    active
                                        ? Icons.visibility_off_outlined
                                        : Icons.visibility_outlined,
                                  ),
                                  const SizedBox(width: 12),
                                  Text(active ? 'Tạm ngừng' : 'Kích hoạt lại'),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  // SERVICE NAME
                  Text(
                    service.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 18.rf(context),
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                      height: 1.22,
                    ),
                  ),

                  SizedBox(height: 10.rw(context)),

                  // DESCRIPTION
                  if (service.description?.trim().isNotEmpty == true)
                    Text(
                      service.description!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13.rf(context),
                        color: AppColors.textSecondary,
                        height: 1.35,
                      ),
                    )
                  else
                    Text(
                      'Chưa có mô tả dịch vụ',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13.rf(context),
                        color: AppColors.textSecondary,
                      ),
                    ),

                  SizedBox(height: 12.rw(context)),

                  // TIME + PRICE
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      if (service.estimatedDurationMinutes != null) ...[
                        Icon(
                          Icons.schedule_outlined,
                          size: 17.ri(context),
                          color: AppColors.textSecondary,
                        ),

                        SizedBox(width: 5.rw(context)),

                        Flexible(
                          flex: 2,
                          child: Text(
                            '${service.estimatedDurationMinutes} phút',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 13.rf(context),
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ],

                      SizedBox(width: 8.rw(context)),

                      Expanded(
                        flex: 3,
                        child: Text(
                          priceText,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            fontSize: 15.rf(context),
                            fontWeight: FontWeight.w600,
                            color: active
                                ? AppColors.primary
                                : AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProviderServiceThumbnail extends StatelessWidget {
  final String? imageUrl;
  final bool active;

  const _ProviderServiceThumbnail({
    required this.imageUrl,
    required this.active,
  });

  @override
  Widget build(BuildContext context) {
    final width = 112.rw(context);
    final height = 112.rw(context);

    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(13.rr(context)),
          child: SizedBox(
            width: width,
            height: height,
            child: imageUrl != null && imageUrl!.trim().isNotEmpty
                ? Image.network(
                    imageUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) {
                      return _fallback(context);
                    },
                  )
                : _fallback(context),
          ),
        ),

        // Overlay nhẹ khi tạm ngừng
        if (!active)
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(13.rr(context)),
              child: Container(color: Colors.white.withValues(alpha: 0.48)),
            ),
          ),
      ],
    );
  }

  Widget _fallback(BuildContext context) {
    return Container(
      color: AppColors.softGray,
      alignment: Alignment.center,
      child: Icon(
        Icons.home_repair_service_rounded,
        size: 38.ri(context),
        color: AppColors.textSecondary,
      ),
    );
  }
}

class _ServiceStatusBadge extends StatelessWidget {
  final bool active;

  const _ServiceStatusBadge({required this.active});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxWidth: 112.rw(context)),
      padding: EdgeInsets.symmetric(
        horizontal: 9.rw(context),
        vertical: 6.rw(context),
      ),
      decoration: BoxDecoration(
        color: active ? const Color(0xFFF0FDF4) : AppColors.softGray,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7.rw(context),
            height: 7.rw(context),
            decoration: BoxDecoration(
              color: active ? AppColors.success : AppColors.textSecondary,
              shape: BoxShape.circle,
            ),
          ),

          SizedBox(width: 6.rw(context)),

          Flexible(
            child: Text(
              active ? 'Đang hoạt động' : 'Tạm ngừng',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11.5.rf(context),
                fontWeight: FontWeight.w600,
                color: active ? AppColors.success : AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyServices extends StatelessWidget {
  final VoidCallback onCreate;

  const _EmptyServices({required this.onCreate});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(
          Icons.home_repair_service_outlined,
          size: 54.ri(context),
          color: AppColors.textSecondary,
        ),
        SizedBox(height: 12.rw(context)),
        Text(
          'Bạn chưa có dịch vụ',
          style: TextStyle(
            fontSize: 18.rf(context),
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(height: 5.rw(context)),
        const Text(
          'Tạo dịch vụ đầu tiên để bắt đầu nhận đơn từ khách hàng.',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColors.textSecondary),
        ),
        SizedBox(height: 16.rw(context)),
        FilledButton.icon(
          onPressed: onCreate,
          //icon: const Icon(Icons.add_rounded),
          label: const Text(
            ' + ',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
          ),
        ),
      ],
    );
  }
}
