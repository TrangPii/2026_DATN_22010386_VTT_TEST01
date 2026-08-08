import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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
        search: _searchController.text,
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
    final newStatus = service.status == 'ACTIVE' ? 'INACTIVE' : 'ACTIVE';

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(newStatus == 'ACTIVE' ? 'Bật dịch vụ' : 'Tắt dịch vụ'),
        content: Text(
          newStatus == 'ACTIVE'
              ? 'Dịch vụ sẽ xuất hiện lại cho khách hàng.'
              : 'Dịch vụ sẽ không còn xuất hiện trong danh sách public.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Xác nhận'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await _serviceApi.updateStatus(id: service.id, status: newStatus);

      await _loadServices();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              newStatus == 'ACTIVE' ? 'Đã bật dịch vụ.' : 'Đã tắt dịch vụ.',
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
    }
  }

  String _formatPrice(double price) {
    return NumberFormat.currency(
      locale: 'vi_VN',
      symbol: '₫',
      decimalDigits: 0,
    ).format(price);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _loadServices,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            SearchBar(
              controller: _searchController,
              hintText: 'Tìm dịch vụ của bạn...',
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
              onSubmitted: (_) => _loadServices(),
            ),

            const SizedBox(height: 16),

            Row(
              children: [
                ChoiceChip(
                  label: const Text('Tất cả'),
                  selected: _status == null,
                  onSelected: (_) {
                    setState(() {
                      _status = null;
                    });

                    _loadServices();
                  },
                ),

                const SizedBox(width: 8),

                ChoiceChip(
                  label: const Text('Đang hoạt động'),
                  selected: _status == 'ACTIVE',
                  onSelected: (_) {
                    setState(() {
                      _status = 'ACTIVE';
                    });

                    _loadServices();
                  },
                ),

                const SizedBox(width: 8),

                ChoiceChip(
                  label: const Text('Đã tắt'),
                  selected: _status == 'INACTIVE',
                  onSelected: (_) {
                    setState(() {
                      _status = 'INACTIVE';
                    });

                    _loadServices();
                  },
                ),
              ],
            ),

            const SizedBox(height: 20),

            if (_isLoading)
              const Padding(
                padding: EdgeInsets.all(40),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_error != null)
              Column(
                children: [
                  Text(_error!, textAlign: TextAlign.center),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: _loadServices,
                    child: const Text('Thử lại'),
                  ),
                ],
              )
            else if (_services.isEmpty)
              const Padding(
                padding: EdgeInsets.all(40),
                child: Center(child: Text('Bạn chưa có dịch vụ nào.')),
              )
            else
              ..._services.map(
                (service) => Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                service.name,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),

                            Chip(
                              label: Text(
                                service.status == 'ACTIVE'
                                    ? 'Đang hoạt động'
                                    : 'Đã tắt',
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 8),

                        Text(service.category?.name ?? 'Chưa có danh mục'),

                        const SizedBox(height: 6),

                        Text(
                          '${_formatPrice(service.price)} / ${service.priceUnit}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),

                        if (service.estimatedDurationMinutes != null) ...[
                          const SizedBox(height: 6),
                          Text('${service.estimatedDurationMinutes} phút'),
                        ],

                        const SizedBox(height: 14),

                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () {
                                  _openForm(service: service);
                                },
                                icon: const Icon(Icons.edit_outlined),
                                label: const Text('Sửa'),
                              ),
                            ),

                            const SizedBox(width: 12),

                            Expanded(
                              child: FilledButton.tonalIcon(
                                onPressed: () {
                                  _changeStatus(service);
                                },
                                icon: Icon(
                                  service.status == 'ACTIVE'
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                ),
                                label: Text(
                                  service.status == 'ACTIVE' ? 'Tắt' : 'Bật',
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _openForm();
        },
        icon: const Icon(Icons.add),
        label: const Text('Thêm dịch vụ'),
      ),
    );
  }
}
