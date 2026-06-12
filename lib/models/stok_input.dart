class StokInput {
  final int id;
  final int barangId;
  final String barangKode;
  final String barangNama;
  final String barangSatuan;
  final int qtySebelum;
  final int qtyInput;
  final int qtySetelah;
  final int? userId;
  final String? userNama;
  final String? keterangan;
  final String tanggal;

  StokInput({
    required this.id,
    required this.barangId,
    required this.barangKode,
    required this.barangNama,
    required this.barangSatuan,
    required this.qtySebelum,
    required this.qtyInput,
    required this.qtySetelah,
    required this.userId,
    required this.userNama,
    required this.keterangan,
    required this.tanggal,
  });

  factory StokInput.fromJson(Map<String, dynamic> json) {
    final barang = json['barang'] as Map<String, dynamic>?;
    return StokInput(
      id: json['id'] as int,
      barangId: json['barang_id'] as int? ?? 0,
      barangKode: barang?['kode']?.toString() ?? '',
      barangNama: barang?['nama']?.toString() ?? '',
      barangSatuan: barang?['satuan']?.toString() ?? '',
      qtySebelum: (json['qty_sebelum'] as num?)?.toInt() ?? 0,
      qtyInput: (json['qty_input'] as num?)?.toInt() ?? 0,
      qtySetelah: (json['qty_setelah'] as num?)?.toInt() ?? 0,
      userId: json['user_id'] as int?,
      userNama: json['user_nama']?.toString(),
      keterangan: json['keterangan']?.toString(),
      tanggal: json['tanggal']?.toString() ?? '',
    );
  }
}
