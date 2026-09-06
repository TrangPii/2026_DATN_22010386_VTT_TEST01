import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/vietnam_address.dart';

class VietnamAddressData {
  final List<VietnamProvince> provinces;
  final Map<String, List<VietnamWard>> wardsByProvince;

  const VietnamAddressData({
    required this.provinces,
    required this.wardsByProvince,
  });

  List<VietnamWard> wardsForProvince(String provinceCode) {
    return wardsByProvince[provinceCode] ?? const [];
  }
}

class VietnamAddressService {
  static Future<VietnamAddressData>? _cache;

  static Future<VietnamAddressData> load() {
    return _cache ??= _load();
  }

  static Future<VietnamAddressData> _load() async {
    final raw = await rootBundle.loadString('assets/data/vietnam_address.json');

    final decoded = jsonDecode(raw);

    if (decoded is! List) {
      throw const FormatException('Dữ liệu địa chỉ Việt Nam không hợp lệ.');
    }

    final provinces = <VietnamProvince>[];
    final wardsByProvince = <String, List<VietnamWard>>{};

    for (final item in decoded) {
      if (item is! Map) {
        continue;
      }

      if (item['type'] != 'table') {
        continue;
      }

      final tableName = item['name'];
      final tableData = item['data'];

      if (tableData is! List) {
        continue;
      }

      if (tableName == 'provinces') {
        for (final row in tableData) {
          if (row is! Map) {
            continue;
          }

          final code = row['province_code']?.toString();
          final name = row['name']?.toString();

          if (code == null || name == null) {
            continue;
          }

          provinces.add(VietnamProvince(code: code, name: name));
        }
      }

      if (tableName == 'wards') {
        for (final row in tableData) {
          if (row is! Map) {
            continue;
          }

          final code = row['ward_code']?.toString();
          final name = row['name']?.toString();
          final provinceCode = row['province_code']?.toString();

          if (code == null || name == null || provinceCode == null) {
            continue;
          }

          wardsByProvince.putIfAbsent(provinceCode, () => <VietnamWard>[]);

          wardsByProvince[provinceCode]!.add(
            VietnamWard(code: code, name: name, provinceCode: provinceCode),
          );
        }
      }
    }

    if (provinces.length != 34) {
      throw FormatException(
        'Dữ liệu tỉnh/thành không hợp lệ: '
        'tìm thấy ${provinces.length}/34.',
      );
    }

    final wardCount = wardsByProvince.values.fold<int>(
      0,
      (total, wards) => total + wards.length,
    );

    if (wardCount != 3321) {
      throw FormatException(
        'Dữ liệu xã/phường không hợp lệ: '
        'tìm thấy $wardCount/3321.',
      );
    }

    return VietnamAddressData(
      provinces: List.unmodifiable(provinces),
      wardsByProvince: {
        for (final entry in wardsByProvince.entries)
          entry.key: List.unmodifiable(entry.value),
      },
    );
  }
}
