import 'package:flutter/material.dart';
import '../../models/retur_pembelian.dart';
import '../../services/retur_service.dart';
import '../../widgets/rupiah.dart';

class ReturDetailScreen extends StatefulWidget {
  final int id;
  const ReturDetailScreen({super.key, required this.id});

  @override
  State<ReturDetailScreen> createState() => _ReturDetailScreenState();
}

class _ReturDetailScreenState extends State<ReturDetailScreen> {
  final _service = ReturService();
  Future<ReturPembelian>? _future;

  @override
  void initState() {
    super.initState();
    _future = _service.show(widget.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detail Retur')),
      body: FutureBuilder<ReturPembelian>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) return Center(child: Text('Error: ${snap.error}'));
          final r = snap.data!;
          return ListView(
            padding: const EdgeInsets.all(12),
            children: [
              _row('No. Retur', r.nomor),
              _row('Tanggal', r.tanggal),
              _row('Supplier', r.supplier?.nama ?? '-'),
              _row('No. Pembelian', r.pembelianNomor),
              _row('Keterangan', r.keterangan ?? '-'),
              const Divider(),
              const Text('Item Diretur', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 8),
              ...r.details.map((d) => Card(
                child: ListTile(
                  title: Text(d.barangNama),
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
                    const Text('TOTAL RETUR', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    Text(formatRupiah(r.total), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
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
        SizedBox(width: 110, child: Text(label, style: const TextStyle(color: Colors.grey))),
        Expanded(child: Text(value)),
      ],
    ),
  );
}
