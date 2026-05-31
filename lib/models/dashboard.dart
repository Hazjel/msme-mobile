class DashboardSummary {
  final String periodeStart;
  final String periodeEnd;
  final double totalPembelian;
  final int jumlahPembelian;
  final double totalRetur;
  final int jumlahRetur;

  DashboardSummary({
    required this.periodeStart,
    required this.periodeEnd,
    required this.totalPembelian,
    required this.jumlahPembelian,
    required this.totalRetur,
    required this.jumlahRetur,
  });

  factory DashboardSummary.fromJson(Map<String, dynamic> json) {
    final periode = json['periode'] as Map<String, dynamic>?;
    return DashboardSummary(
      periodeStart: periode?['start']?.toString() ?? '',
      periodeEnd: periode?['end']?.toString() ?? '',
      totalPembelian: _toDouble(json['total_pembelian']),
      jumlahPembelian: (json['jumlah_pembelian'] as num?)?.toInt() ?? 0,
      totalRetur: _toDouble(json['total_retur']),
      jumlahRetur: (json['jumlah_retur'] as num?)?.toInt() ?? 0,
    );
  }

  static double _toDouble(dynamic v) {
    if (v == null) return 0;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0;
  }
}
