import 'package:flutter/material.dart';
import '../../models/supplier.dart';
import '../../services/laporan_service.dart';
import '../../services/master_data_service.dart';
import '../../widgets/rupiah.dart';

class LaporanReturScreen extends StatefulWidget {
  const LaporanReturScreen({super.key});

  @override
  State<LaporanReturScreen> createState() => _LaporanReturScreenState();
}

class _LaporanReturScreenState extends State<LaporanReturScreen> {
  final _service = LaporanService();
  final _masterService = MasterDataService();

  DateTime _start = DateTime(DateTime.now().year, DateTime.now().month, 1);
  DateTime _end = DateTime.now();
  Supplier? _supplier;
  List<Supplier> _suppliers = [];
  Map<String, dynamic>? _data;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _loadSuppliers();
    _load();
  }

  Future<void> _loadSuppliers() async {
    try {
      final s = await _masterService.suppliers();
      setState(() => _suppliers = s);
    } catch (_) {}
  }

  String _fmt(DateTime d) => '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final data = await _service.laporanRetur(
        start: _fmt(_start),
        end: _fmt(_end),
        supplierId: _supplier?.id,
      );
      setState(() {
        _data = data;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Laporan Retur Pembelian')),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          Row(children: [
            Expanded(child: _dateBtn('Dari', _start, (d) => setState(() => _start = d))),
            const SizedBox(width: 8),
            Expanded(child: _dateBtn('Sampai', _end, (d) => setState(() => _end = d))),
          ]),
          const SizedBox(height: 8),
          DropdownButtonFormField<Supplier?>(
            initialValue: _supplier,
            decoration: const InputDecoration(labelText: 'Supplier (opsional)', border: OutlineInputBorder(), isDense: true),
            items: [
              const DropdownMenuItem(value: null, child: Text('Semua Supplier')),
              ..._suppliers.map((s) => DropdownMenuItem(value: s, child: Text(s.nama))),
            ],
            onChanged: (v) => setState(() => _supplier = v),
          ),
          const SizedBox(height: 8),
          ElevatedButton.icon(
            onPressed: _loading ? null : _load,
            icon: const Icon(Icons.filter_alt),
            label: const Text('Filter'),
          ),
          const Divider(height: 24),
          if (_loading) const Center(child: CircularProgressIndicator()),
          if (!_loading && _data != null) ...[
            Card(
              color: Colors.orange.shade50,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Total Retur: ${formatRupiah(_data!['total'])}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  Text('Jumlah Transaksi: ${_data!['jumlah_transaksi']}'),
                ]),
              ),
            ),
            const SizedBox(height: 8),
            ...(_data!['data'] as List).map((r) {
              final m = r as Map<String, dynamic>;
              return Card(
                child: ListTile(
                  title: Text(m['nomor']?.toString() ?? '-'),
                  subtitle: Text('${m['tanggal']} • ${(m['supplier'] as Map?)?['nama'] ?? '-'}\nPembelian: ${(m['pembelian'] as Map?)?['nomor'] ?? '-'}'),
                  trailing: Text(formatRupiah(m['total'] as num?), style: const TextStyle(fontWeight: FontWeight.bold)),
                  isThreeLine: true,
                ),
              );
            }),
          ],
        ],
      ),
    );
  }

  Widget _dateBtn(String label, DateTime val, void Function(DateTime) onPick) {
    return OutlinedButton(
      onPressed: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: val,
          firstDate: DateTime(2020),
          lastDate: DateTime(2100),
        );
        if (picked != null) onPick(picked);
      },
      child: Text('$label\n${_fmt(val)}', textAlign: TextAlign.center),
    );
  }
}
