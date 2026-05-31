import 'supplier.dart';

class ReturPembelianDetail {
  final int id;
  final int pembelianDetailId;
  final int barangId;
  final String barangNama;
  final int qty;
  final double harga;
  final double subtotal;

  ReturPembelianDetail({
    required this.id,
    required this.pembelianDetailId,
    required this.barangId,
    required this.barangNama,
    required this.qty,
    required this.harga,
    required this.subtotal,
  });

  factory ReturPembelianDetail.fromJson(Map<String, dynamic> json) {
    final barang = json['barang'] as Map<String, dynamic>?;
    return ReturPembelianDetail(
      id: json['id'] as int? ?? 0,
      pembelianDetailId: json['pembelian_detail_id'] as int? ?? 0,
      barangId: json['barang_id'] as int? ?? 0,
      barangNama: barang?['nama']?.toString() ?? '',
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

class ReturPembelian {
  final int id;
  final String nomor;
  final String tanggal;
  final int pembelianId;
  final String pembelianNomor;
  final int supplierId;
  final Supplier? supplier;
  final double total;
  final String? keterangan;
  final List<ReturPembelianDetail> details;

  ReturPembelian({
    required this.id,
    required this.nomor,
    required this.tanggal,
    required this.pembelianId,
    required this.pembelianNomor,
    required this.supplierId,
    required this.supplier,
    required this.total,
    required this.keterangan,
    required this.details,
  });

  factory ReturPembelian.fromJson(Map<String, dynamic> json) {
    final pembelian = json['pembelian'] as Map<String, dynamic>?;
    return ReturPembelian(
      id: json['id'] as int,
      nomor: json['nomor']?.toString() ?? '',
      tanggal: json['tanggal']?.toString() ?? '',
      pembelianId: json['pembelian_id'] as int? ?? 0,
      pembelianNomor: pembelian?['nomor']?.toString() ?? '',
      supplierId: json['supplier_id'] as int? ?? 0,
      supplier: json['supplier'] != null
          ? Supplier.fromJson(json['supplier'] as Map<String, dynamic>)
          : null,
      total: _toDouble(json['total']),
      keterangan: json['keterangan']?.toString(),
      details: (json['details'] as List?)
              ?.map((e) => ReturPembelianDetail.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  static double _toDouble(dynamic v) {
    if (v == null) return 0;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0;
  }
}
