import 'supplier.dart';

class PembelianDetail {
  final int id;
  final int barangId;
  final String barangNama;
  final String barangKode;
  final int qty;
  final double harga;
  final double subtotal;

  PembelianDetail({
    required this.id,
    required this.barangId,
    required this.barangNama,
    required this.barangKode,
    required this.qty,
    required this.harga,
    required this.subtotal,
  });

  factory PembelianDetail.fromJson(Map<String, dynamic> json) {
    final barang = json['barang'] as Map<String, dynamic>?;
    return PembelianDetail(
      id: json['id'] as int? ?? 0,
      barangId: json['barang_id'] as int? ?? 0,
      barangNama: barang?['nama']?.toString() ?? '',
      barangKode: barang?['kode']?.toString() ?? '',
      qty: (json['qty'] as num?)?.toInt() ?? 0,
      harga: _toDouble(json['harga']),
      subtotal: _toDouble(json['subtotal']),
    );
  }

  static double _toDouble(dynamic v) {
    if (v == null) return 0;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0;
  }
}

class Pembelian {
  final int id;
  final String nomor;
  final String tanggal;
  final int supplierId;
  final Supplier? supplier;
  final double total;
  final String? keterangan;
  final List<PembelianDetail> details;

  Pembelian({
    required this.id,
    required this.nomor,
    required this.tanggal,
    required this.supplierId,
    required this.supplier,
    required this.total,
    required this.keterangan,
    required this.details,
  });

  factory Pembelian.fromJson(Map<String, dynamic> json) => Pembelian(
        id: json['id'] as int,
        nomor: json['nomor']?.toString() ?? '',
        tanggal: json['tanggal']?.toString() ?? '',
        supplierId: json['supplier_id'] as int? ?? 0,
        supplier: json['supplier'] != null
            ? Supplier.fromJson(json['supplier'] as Map<String, dynamic>)
            : null,
        total: _toDouble(json['total']),
        keterangan: json['keterangan']?.toString(),
        details: (json['details'] as List?)
                ?.map((e) => PembelianDetail.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
      );

  static double _toDouble(dynamic v) {
    if (v == null) return 0;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0;
  }
}
