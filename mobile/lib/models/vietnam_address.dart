class VietnamProvince {
  final String code;
  final String name;

  const VietnamProvince({required this.code, required this.name});

  String get displayName {
    return name.replaceFirst(RegExp(r'^(Thành phố|Tỉnh)\s+'), '');
  }
}

class VietnamWard {
  final String code;
  final String name;
  final String provinceCode;

  const VietnamWard({
    required this.code,
    required this.name,
    required this.provinceCode,
  });
}

class VietnamAddressSelection {
  final VietnamProvince province;
  final VietnamWard ward;

  const VietnamAddressSelection({required this.province, required this.ward});

  String get formatted {
    return '${province.displayName}, ${ward.name}';
  }
}
