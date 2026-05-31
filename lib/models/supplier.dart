class Supplier {
  final int id;
  final String nama;

  Supplier({required this.id, required this.nama});

  factory Supplier.fromJson(Map<String, dynamic> json) => Supplier(
        id: json['id'] as int,
        nama: json['nama'] as String? ?? '',
      );
}
