import 'package:flutter/material.dart';
import '../../models/barang.dart';
import '../../services/master_data_service.dart';
import '../../widgets/rupiah.dart';
import 'input_stok_screen.dart';

class DaftarBarangScreen extends StatefulWidget {
  const DaftarBarangScreen({super.key});

  @override
  State<DaftarBarangScreen> createState() => _DaftarBarangScreenState();
}

class _DaftarBarangScreenState extends State<DaftarBarangScreen> {
  final _service = MasterDataService();
  Future<List<Barang>>? _future;
  String _search = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    setState(() {
      _future = _service.barangs();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Barang'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _load),
        ],
      ),
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.all(8),
          child: TextField(
            decoration: const InputDecoration(
              hintText: 'Cari kode / nama barang',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
              isDense: true,
            ),
            onChanged: (v) => setState(() => _search = v.toLowerCase()),
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
                return ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (_, i) {
                    final b = items[i];
                    final stokColor = b.stok <= 0
                        ? Colors.red
                        : b.stok < 10
                            ? Colors.orange
                            : Colors.green;
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: stokColor,
                          child: Text(
                            '${b.stok}',
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ),
                        title: Text(b.nama, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('${b.kode} • ${b.satuan}\nHarga ${formatRupiah(b.hargaPokok)}'),
                        isThreeLine: true,
                        trailing: const Icon(Icons.add_box, color: Colors.blue),
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
      ]),
    );
  }
}
