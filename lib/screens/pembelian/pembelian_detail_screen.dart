import 'package:flutter/material.dart';
import '../../models/pembelian.dart';
import '../../services/pembelian_service.dart';
import '../../widgets/rupiah.dart';

class PembelianDetailScreen extends StatefulWidget {
  final int id;
  const PembelianDetailScreen({super.key, required this.id});

  @override
  State<PembelianDetailScreen> createState() => _PembelianDetailScreenState();
}

class _PembelianDetailScreenState extends State<PembelianDetailScreen> {
  final _service = PembelianService();
  Future<Pembelian>? _future;

  @override
  void initState() {
    super.initState();
    _future = _service.show(widget.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detail Pembelian')),
      body: FutureBuilder<Pembelian>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) return Center(child: Text('Error: ${snap.error}'));
          final p = snap.data!;
          return ListView(
            padding: const EdgeInsets.all(12),
            children: [
              _row('Nomor', p.nomor),
              _row('Tanggal', p.tanggal),
              _row('Supplier', p.supplier?.nama ?? '-'),
              _row('Keterangan', p.keterangan ?? '-'),
              const Divider(),
              const Text('Item Barang', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 8),
              ...p.details.map((d) => Card(
                child: ListTile(
                  title: Text('${d.barangKode} - ${d.barangNama}'),
                  subtitle: Text('${d.qty} × ${formatRupiah(d.harga)}'),
                  trailing: Text(formatRupiah(d.subtotal), style: const TextStyle(fontWeight: FontWeight.bold)),
                ),
              )),
              const Divider(),
              Padding(
                padding: const EdgeInsets.all(8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('TOTAL', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    Text(formatRupiah(p.total), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _row(String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(width: 100, child: Text(label, style: const TextStyle(color: Colors.grey))),
        Expanded(child: Text(value)),
      ],
    ),
  );
}
