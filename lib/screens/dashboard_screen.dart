import 'package:flutter/material.dart';
import '../models/dashboard.dart';
import '../services/laporan_service.dart';
import '../widgets/rupiah.dart';
import 'pembelian/pembelian_list_screen.dart';
import 'retur/retur_list_screen.dart';
import 'laporan/laporan_pembelian_screen.dart';
import 'laporan/laporan_retur_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _service = LaporanService();
  Future<DashboardSummary>? _future;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    setState(() {
      _future = _service.dashboard();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MSME Mobile'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _load),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => _load(),
        child: FutureBuilder<DashboardSummary>(
          future: _future,
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snap.hasError) {
              return ListView(children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text('Error: ${snap.error}', style: const TextStyle(color: Colors.red)),
                ),
              ]);
            }
            final d = snap.data!;
            return ListView(
              padding: const EdgeInsets.all(12),
              children: [
                Text('Ringkasan ${d.periodeStart} s/d ${d.periodeEnd}',
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 12),
                Row(children: [
                  Expanded(child: _card('Total Pembelian', formatRupiah(d.totalPembelian), Colors.blue, Icons.shopping_cart)),
                  const SizedBox(width: 8),
                  Expanded(child: _card('Jumlah Pembelian', '${d.jumlahPembelian}', Colors.green, Icons.list_alt)),
                ]),
                const SizedBox(height: 8),
                Row(children: [
                  Expanded(child: _card('Total Retur', formatRupiah(d.totalRetur), Colors.orange, Icons.assignment_return)),
                  const SizedBox(width: 8),
                  Expanded(child: _card('Jumlah Retur', '${d.jumlahRetur}', Colors.red, Icons.undo)),
                ]),
                const SizedBox(height: 20),
                const Divider(),
                _menuTile(Icons.shopping_cart, 'Pembelian', const PembelianListScreen()),
                _menuTile(Icons.assignment_return, 'Retur Pembelian', const ReturListScreen()),
                _menuTile(Icons.description, 'Laporan Pembelian', const LaporanPembelianScreen()),
                _menuTile(Icons.description_outlined, 'Laporan Retur Pembelian', const LaporanReturScreen()),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _card(String label, String value, Color color, IconData icon) {
    return Card(
      color: color,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(color: Colors.white, fontSize: 12)),
            const SizedBox(height: 2),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(value, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _menuTile(IconData icon, String title, Widget target) {
    return Card(
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => target)),
      ),
    );
  }
}
