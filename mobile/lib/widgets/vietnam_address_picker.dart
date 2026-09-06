import 'package:flutter/material.dart';

import '../models/vietnam_address.dart';
import '../services/vietnam_address_service.dart';

class VietnamAddressPicker {
  static Future<VietnamAddressSelection?> show({
    required BuildContext context,
    String? initialProvinceCode,
    String? initialWardCode,
  }) async {
    final data = await VietnamAddressService.load();

    if (!context.mounted) {
      return null;
    }

    return showModalBottomSheet<VietnamAddressSelection>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) {
        return _VietnamAddressPickerSheet(
          data: data,
          initialProvinceCode: initialProvinceCode,
          initialWardCode: initialWardCode,
        );
      },
    );
  }
}

class _VietnamAddressPickerSheet extends StatefulWidget {
  final VietnamAddressData data;
  final String? initialProvinceCode;
  final String? initialWardCode;

  const _VietnamAddressPickerSheet({
    required this.data,
    this.initialProvinceCode,
    this.initialWardCode,
  });

  @override
  State<_VietnamAddressPickerSheet> createState() =>
      _VietnamAddressPickerSheetState();
}

class _VietnamAddressPickerSheetState
    extends State<_VietnamAddressPickerSheet> {
  final TextEditingController _searchController = TextEditingController();

  int _step = 0;

  VietnamProvince? _selectedProvince;
  VietnamWard? _selectedWard;

  String _searchText = '';

  @override
  void initState() {
    super.initState();

    if (widget.initialProvinceCode != null) {
      for (final province in widget.data.provinces) {
        if (province.code == widget.initialProvinceCode) {
          _selectedProvince = province;
          break;
        }
      }
    }

    if (_selectedProvince != null && widget.initialWardCode != null) {
      final wards = widget.data.wardsForProvince(_selectedProvince!.code);

      for (final ward in wards) {
        if (ward.code == widget.initialWardCode) {
          _selectedWard = ward;
          break;
        }
      }
    }

    if (_selectedProvince != null) {
      _step = 1;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _setStep(int step) {
    setState(() {
      _step = step;
      _searchText = '';
      _searchController.clear();
    });
  }

  void _selectProvince(VietnamProvince province) {
    setState(() {
      _selectedProvince = province;
      _selectedWard = null;
      _step = 1;
      _searchText = '';
      _searchController.clear();
    });
  }

  void _selectWard(VietnamWard ward) {
    if (_selectedProvince == null) {
      return;
    }

    Navigator.pop(
      context,
      VietnamAddressSelection(province: _selectedProvince!, ward: ward),
    );
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height * 0.82;

    final items = _step == 0 ? _filteredProvinces() : _filteredWards();

    return SizedBox(
      height: height,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    'Chọn địa chỉ',
                    style: TextStyle(fontSize: 21, fontWeight: FontWeight.w700),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Expanded(
                  child: _AddressStepButton(
                    title: 'Tỉnh/Thành phố',
                    value:
                        _selectedProvince?.displayName ?? 'Chọn tỉnh/thành phố',
                    selected: _step == 0,
                    onTap: () => _setStep(0),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _AddressStepButton(
                    title: 'Xã/Phường',
                    value: _selectedWard?.name ?? 'Chọn xã/phường',
                    selected: _step == 1,
                    enabled: _selectedProvince != null,
                    onTap: _selectedProvince == null ? null : () => _setStep(1),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchText = value.trim();
                });
              },
              decoration: InputDecoration(
                hintText: _step == 0
                    ? 'Tìm tỉnh/thành phố...'
                    : 'Tìm xã/phường...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchText.isEmpty
                    ? null
                    : IconButton(
                        onPressed: () {
                          setState(() {
                            _searchText = '';
                            _searchController.clear();
                          });
                        },
                        icon: const Icon(Icons.clear),
                      ),
              ),
            ),
          ),

          const SizedBox(height: 8),

          Expanded(
            child: items.isEmpty
                ? const Center(child: Text('Không tìm thấy địa chỉ phù hợp.'))
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      if (_step == 0) {
                        final province = items[index] as VietnamProvince;

                        return ListTile(
                          leading: const Icon(Icons.location_city_outlined),
                          title: Text(province.displayName),
                          trailing: province.code == _selectedProvince?.code
                              ? const Icon(
                                  Icons.check_circle,
                                  color: Colors.blue,
                                )
                              : const Icon(Icons.chevron_right),
                          onTap: () => _selectProvince(province),
                        );
                      }

                      final ward = items[index] as VietnamWard;

                      return ListTile(
                        leading: Icon(
                          ward.name.startsWith('Phường')
                              ? Icons.location_city_outlined
                              : Icons.location_on_outlined,
                        ),
                        title: Text(ward.name),
                        trailing: ward.code == _selectedWard?.code
                            ? const Icon(Icons.check_circle, color: Colors.blue)
                            : null,
                        onTap: () => _selectWard(ward),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  List<VietnamProvince> _filteredProvinces() {
    if (_searchText.isEmpty) {
      return widget.data.provinces;
    }

    final query = _searchText.toLowerCase();

    return widget.data.provinces.where((province) {
      return province.displayName.toLowerCase().contains(query);
    }).toList();
  }

  List<VietnamWard> _filteredWards() {
    if (_selectedProvince == null) {
      return const [];
    }

    final wards = widget.data.wardsForProvince(_selectedProvince!.code);

    if (_searchText.isEmpty) {
      return wards;
    }

    final query = _searchText.toLowerCase();

    return wards.where((ward) {
      return ward.name.toLowerCase().contains(query);
    }).toList();
  }
}

class _AddressStepButton extends StatelessWidget {
  final String title;
  final String value;
  final bool selected;
  final bool enabled;
  final VoidCallback? onTap;

  const _AddressStepButton({
    required this.title,
    required this.value,
    required this.selected,
    this.enabled = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;

    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: selected
              ? color.primary.withValues(alpha: 0.08)
              : color.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected
                ? color.primary
                : color.outline.withValues(alpha: 0.35),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(fontSize: 11, color: color.onSurfaceVariant),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: enabled
                    ? color.onSurface
                    : color.onSurface.withValues(alpha: 0.4),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
