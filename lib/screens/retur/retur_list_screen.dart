import 'package:flutter/material.dart';
import '../../models/retur_pembelian.dart';
import '../../services/retur_service.dart';
import '../../widgets/rupiah.dart';
import 'retur_detail_screen.dart';
import 'retur_form_screen.dart';

class ReturListScreen extends StatefulWidget {
  const ReturListScreen({super.key});

  @override
  State<ReturListScreen> createState() => _ReturListScreenState();
}

class _ReturListScreenState extends State<ReturListScreen> {
  final _service = ReturService();
  Future<List<ReturPembelian>>? _future;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    setState(() => _future = _service.list());
  }

  Future<void> _delete(int id) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Hapus Retur'),
        content: const Text('Yakin hapus data ini? Stok akan dikembalikan.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Hapus')),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await _service.destroy(id);
      _load();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Retur Pembelian')),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ReturFormScreen()),
          );
          if (result == true) _load();
        },
        child: const Icon(Icons.add),
      ),
      body: RefreshIndicator(
        onRefresh: () async => _load(),
        child: FutureBuilder<List<ReturPembelian>>(
          future: _future,
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snap.hasError) return Center(child: Text('Error: ${snap.error}'));
            final items = snap.data ?? [];
            if (items.isEmpty) return const Center(child: Text('Tidak ada data.'));
            return ListView.builder(
              itemCount: items.length,
              itemBuilder: (_, i) {
                final r = items[i];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: ListTile(
                    title: Text(r.nomor, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('${r.tanggal} • ${r.supplier?.nama ?? '-'}\nPembelian: ${r.pembelianNomor}'),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(formatRupiah(r.total), style: const TextStyle(fontWeight: FontWeight.bold)),
                        PopupMenuButton<String>(
                          padding: EdgeInsets.zero,
                          onSelected: (v) {
                            if (v == 'delete') _delete(r.id);
                          },
                          itemBuilder: (_) => [
                            const PopupMenuItem(value: 'delete', child: Text('Hapus')),
                          ],
                        ),
                      ],
                    ),
                    isThreeLine: true,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => ReturDetailScreen(id: r.id)),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
