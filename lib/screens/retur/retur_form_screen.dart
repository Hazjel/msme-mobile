import 'package:flutter/material.dart';
import '../../models/pembelian.dart';
import '../../services/pembelian_service.dart';
import '../../services/retur_service.dart';
import '../../widgets/rupiah.dart';

class _SisaItem {
  final int pembelianDetailId;
  final String barangNama;
  final int qtyBeli;
  final int sudahDiretur;
  final int sisaRetur;
  final double harga;
  bool checked;
  int qty;

  _SisaItem({
    required this.pembelianDetailId,
    required this.barangNama,
    required this.qtyBeli,
    required this.sudahDiretur,
    required this.sisaRetur,
    required this.harga,
    this.checked = false,
    this.qty = 1,
  });
}

class ReturFormScreen extends StatefulWidget {
  const ReturFormScreen({super.key});

  @override
  State<ReturFormScreen> createState() => _ReturFormScreenState();
}

class _ReturFormScreenState extends State<ReturFormScreen> {
  final _pembelianService = PembelianService();
  final _returService = ReturService();

  DateTime _tanggal = DateTime.now();
  final _keteranganCtrl = TextEditingController();

  List<Pembelian> _pembelians = [];
  Pembelian? _selectedPembelian;
  List<_SisaItem> _items = [];

  bool _loadingMaster = true;
  bool _loadingSisa = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _loadPembelians();
  }

  Future<void> _loadPembelians() async {
    try {
      final list = await _pembelianService.list();
      setState(() {
        _pembelians = list;
        _loadingMaster = false;
      });
    } catch (e) {
      setState(() => _loadingMaster = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal load: $e')));
      }
    }
  }

  Future<void> _loadSisa(int pembelianId) async {
    setState(() => _loadingSisa = true);
    try {
      final data = await _returService.sisaRetur(pembelianId);
      final list = (data['items'] as List).map((e) {
        final m = e as Map<String, dynamic>;
        return _SisaItem(
          pembelianDetailId: m['pembelian_detail_id'] as int,
          barangNama: m['barang_nama']?.toString() ?? '',
          qtyBeli: (m['qty_beli'] as num).toInt(),
          sudahDiretur: (m['sudah_diretur'] as num).toInt(),
          sisaRetur: (m['sisa_retur'] as num).toInt(),
          harga: (m['harga'] as num).toDouble(),
        );
      }).toList();
      setState(() {
        _items = list;
        _loadingSisa = false;
      });
    } catch (e) {
      setState(() => _loadingSisa = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal: $e')));
      }
    }
  }

  Future<void> _save() async {
    if (_selectedPembelian == null) return;
    final checkedItems = _items.where((i) => i.checked).toList();
    if (checkedItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pilih minimal 1 barang')));
      return;
    }

    setState(() => _saving = true);
    try {
      await _returService.store({
        'pembelian_id': _selectedPembelian!.id,
        'tanggal': '${_tanggal.year}-${_tanggal.month.toString().padLeft(2, '0')}-${_tanggal.day.toString().padLeft(2, '0')}',
        'keterangan': _keteranganCtrl.text.isEmpty ? null : _keteranganCtrl.text,
        'items': checkedItems.map((i) => {
          'pembelian_detail_id': i.pembelianDetailId,
          'qty': i.qty,
        }).toList(),
      });
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      setState(() => _saving = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal simpan: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loadingMaster) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Tambah Retur')),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          DropdownButtonFormField<Pembelian>(
            initialValue: _selectedPembelian,
            decoration: const InputDecoration(labelText: 'Pilih Pembelian', border: OutlineInputBorder()),
            isExpanded: true,
            items: _pembelians.map((p) => DropdownMenuItem(
              value: p,
              child: Text('${p.nomor} - ${p.supplier?.nama ?? '-'}', overflow: TextOverflow.ellipsis),
            )).toList(),
            onChanged: (v) {
              setState(() => _selectedPembelian = v);
              if (v != null) _loadSisa(v.id);
            },
          ),
          const SizedBox(height: 12),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Tanggal Retur'),
            subtitle: Text('${_tanggal.toLocal()}'.split(' ')[0]),
            trailing: const Icon(Icons.calendar_today),
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: _tanggal,
                firstDate: DateTime(2020),
                lastDate: DateTime(2100),
              );
              if (picked != null) setState(() => _tanggal = picked);
            },
          ),
          TextField(
            controller: _keteranganCtrl,
            decoration: const InputDecoration(labelText: 'Keterangan', border: OutlineInputBorder()),
            maxLines: 2,
          ),
          const Divider(height: 24),
          if (_loadingSisa) const Center(child: CircularProgressIndicator()),
          if (!_loadingSisa && _items.isNotEmpty)
            const Text('Pilih Barang yang Diretur', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ..._items.map((item) {
            final habis = item.sisaRetur <= 0;
            return Card(
              child: CheckboxListTile(
                value: item.checked,
                onChanged: habis ? null : (v) => setState(() => item.checked = v ?? false),
                title: Text(item.barangNama, style: TextStyle(color: habis ? Colors.grey : null)),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Beli: ${item.qtyBeli} | Sudah Retur: ${item.sudahDiretur} | Sisa: ${item.sisaRetur}'),
                    Text(formatRupiah(item.harga)),
                    if (item.checked)
                      TextFormField(
                        initialValue: item.qty.toString(),
                        decoration: const InputDecoration(labelText: 'Qty Retur', isDense: true),
                        keyboardType: TextInputType.number,
                        onChanged: (v) {
                          final n = int.tryParse(v) ?? 1;
                          item.qty = n.clamp(1, item.sisaRetur);
                        },
                      ),
                  ],
                ),
                isThreeLine: true,
              ),
            );
          }),
          if (_items.isNotEmpty) ...[
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _saving ? null : _save,
              icon: _saving ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.save),
              label: Text(_saving ? 'Menyimpan...' : 'Simpan Retur'),
            ),
          ],
        ],
      ),
    );
  }
}
