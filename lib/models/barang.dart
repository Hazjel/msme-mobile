class Barang {
  final int id;
  final String kode;
  final String nama;
  final String satuan;
  final double hargaPokok;
  final double hargaJual;
  final int stok;

  Barang({
    required this.id,
    required this.kode,
    required this.nama,
    required this.satuan,
    required this.hargaPokok,
    required this.hargaJual,
    required this.stok,
  });

  factory Barang.fromJson(Map<String, dynamic> json) => Barang(
        id: json['id'] as int,
        kode: json['kode']?.toString() ?? '',
        nama: json['nama']?.toString() ?? '',
        satuan: json['satuan']?.toString() ?? '',
        hargaPokok: _toDouble(json['harga_pokok']),
        hargaJual: _toDouble(json['harga_jual']),
        stok: (json['stok'] as num?)?.toInt() ?? 0,
      );

  static double _toDouble(dynamic v) {
    if (v == null) return 0;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0;
  }
}
