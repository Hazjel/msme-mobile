import 'package:flutter/material.dart';
import '../../models/barang.dart';
import '../../services/master_data_service.dart';
import '../../widgets/rupiah.dart';
import 'input_stok_screen.dart';

class DaftarBarangScreen extends StatefulWidget {
  const DaftarBarangScreen({super.key});

  @override
  State<DaftarBarangScreen> createState() => DaftarBarangScreenState();
}

class DaftarBarangScreenState extends State<DaftarBarangScreen> {
  final _service = MasterDataService();
  Future<List<Barang>>? _future;
  String _search = '';

  @override
  void initState() {
    super.initState();
    _future = _service.barangs();
  }

  void reload() {
    setState(() {
      _future = _service.barangs();
    });
  }

  void _load() => reload();

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Container(
        color: const Color(0xFF1565C0),
        padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        child: Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          elevation: 1,
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Cari Produk...',
              hintStyle: TextStyle(color: Colors.grey.shade500),
              prefixIcon: Icon(Icons.search, color: Colors.grey.shade600),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
            ),
            onChanged: (v) => setState(() => _search = v.toLowerCase()),
          ),
        ),
      ),
      Expanded(
        child: RefreshIndicator(
          onRefresh: () async => _load(),
          child: FutureBuilder<List<Barang>>(
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
              final all = snap.data ?? [];
              final items = _search.isEmpty
                  ? all
                  : all.where((b) =>
                      b.nama.toLowerCase().contains(_search) ||
                      b.kode.toLowerCase().contains(_search)).toList();
              if (items.isEmpty) {
                return const Center(child: Text('Tidak ada barang.'));
              }
              return ListView.separated(
                padding: const EdgeInsets.only(top: 8, bottom: 80),
                itemCount: items.length,
                separatorBuilder: (_, _) => const SizedBox(height: 4),
                itemBuilder: (_, i) {
                  final b = items[i];
                  return Container(
                    color: Colors.white,
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      title: Text(b.nama, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Stok: ${b.stok}', style: const TextStyle(fontSize: 13)),
                          Text('Harga ${formatRupiah(b.hargaPokok)}', style: const TextStyle(fontSize: 13)),
                        ],
                      ),
                      trailing: Icon(Icons.inventory_2, color: Colors.brown.shade300, size: 36),
                      isThreeLine: true,
                      onTap: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => InputStokScreen(barang: b)),
                        );
                        if (result == true) _load();
                      },
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    ]);
  }
}
