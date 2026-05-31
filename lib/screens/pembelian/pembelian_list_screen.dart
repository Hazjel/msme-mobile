import 'package:flutter/material.dart';
import '../../models/pembelian.dart';
import '../../services/pembelian_service.dart';
import '../../widgets/rupiah.dart';
import 'pembelian_detail_screen.dart';
import 'pembelian_form_screen.dart';

class PembelianListScreen extends StatefulWidget {
  const PembelianListScreen({super.key});

  @override
  State<PembelianListScreen> createState() => _PembelianListScreenState();
}

class _PembelianListScreenState extends State<PembelianListScreen> {
  final _service = PembelianService();
  Future<List<Pembelian>>? _future;
  String _search = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    setState(() {
      _future = _service.list(search: _search.isEmpty ? null : _search);
    });
  }

  Future<void> _delete(int id) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Hapus Pembelian'),
        content: const Text('Yakin hapus data ini?'),
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
      appBar: AppBar(title: const Text('Pembelian')),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const PembelianFormScreen()),
          );
          if (result == true) _load();
        },
        child: const Icon(Icons.add),
      ),
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.all(8),
          child: TextField(
            decoration: const InputDecoration(
              hintText: 'Cari nomor / supplier',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
              isDense: true,
            ),
            onSubmitted: (v) {
              _search = v;
              _load();
            },
          ),
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async => _load(),
            child: FutureBuilder<List<Pembelian>>(
              future: _future,
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snap.hasError) {
                  return Center(child: Text('Error: ${snap.error}'));
                }
                final items = snap.data ?? [];
                if (items.isEmpty) {
                  return const Center(child: Text('Tidak ada data.'));
                }
                return ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (_, i) {
                    final p = items[i];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      child: ListTile(
                        title: Text(p.nomor, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('${p.tanggal} • ${p.supplier?.nama ?? '-'}'),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(formatRupiah(p.total), style: const TextStyle(fontWeight: FontWeight.bold)),
                            PopupMenuButton<String>(
                              padding: EdgeInsets.zero,
                              onSelected: (v) {
                                if (v == 'delete') _delete(p.id);
                              },
                              itemBuilder: (_) => [
                                const PopupMenuItem(value: 'delete', child: Text('Hapus')),
                              ],
                            ),
                          ],
                        ),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => PembelianDetailScreen(id: p.id)),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ),
      ]),
    );
  }
}
