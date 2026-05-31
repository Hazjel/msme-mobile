import 'package:flutter/material.dart';
import '../../models/barang.dart';
import '../../models/pembelian.dart';
import '../../models/supplier.dart';
import '../../services/master_data_service.dart';
import '../../services/pembelian_service.dart';
import '../../widgets/rupiah.dart';

class _ItemRow {
  Barang? barang;
  int qty = 1;
  double harga = 0;
}

class PembelianFormScreen extends StatefulWidget {
  final Pembelian? pembelian;
  const PembelianFormScreen({super.key, this.pembelian});

  bool get isEdit => pembelian != null;

  @override
  State<PembelianFormScreen> createState() => _PembelianFormScreenState();
}

class _PembelianFormScreenState extends State<PembelianFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _masterService = MasterDataService();
  final _pembelianService = PembelianService();

  DateTime _tanggal = DateTime.now();
  Supplier? _supplier;
  final _keteranganCtrl = TextEditingController();

  List<Supplier> _suppliers = [];
  List<Barang> _barangs = [];
  final List<_ItemRow> _items = [];

  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _loadMaster();
  }

  Future<void> _loadMaster() async {
    try {
      final s = await _masterService.suppliers();
      final b = await _masterService.barangs();
      setState(() {
        _suppliers = s;
        _barangs = b;
        _prefillIfEdit();
        if (_items.isEmpty) _items.add(_ItemRow());
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal load master: $e')));
      }
    }
  }

  void _prefillIfEdit() {
    final p = widget.pembelian;
    if (p == null) return;

    _tanggal = DateTime.tryParse(p.tanggal) ?? DateTime.now();
    _supplier = _suppliers.firstWhere(
      (s) => s.id == p.supplierId,
      orElse: () => Supplier(id: p.supplierId, nama: p.supplier?.nama ?? ''),
    );
    _keteranganCtrl.text = p.keterangan ?? '';

    for (final d in p.details) {
      final barang = _barangs.firstWhere(
        (b) => b.id == d.barangId,
        orElse: () => Barang(id: d.barangId, kode: d.barangKode, nama: d.barangNama, satuan: '', hargaPokok: d.harga, hargaJual: 0, stok: 0),
      );
      _items.add(_ItemRow()
        ..barang = barang
        ..qty = d.qty
        ..harga = d.harga);
    }
  }

  double get _grandTotal => _items.fold(0, (sum, r) => sum + (r.qty * r.harga));

  String _fmtDate(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_supplier == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pilih supplier')));
      return;
    }
    if (_items.any((r) => r.barang == null)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pilih barang untuk semua baris')));
      return;
    }

    setState(() => _saving = true);
    final payload = {
      'tanggal': _fmtDate(_tanggal),
      'supplier_id': _supplier!.id,
      'keterangan': _keteranganCtrl.text.isEmpty ? null : _keteranganCtrl.text,
      'items': _items.map((r) => {
        'barang_id': r.barang!.id,
        'qty': r.qty,
        'harga': r.harga,
      }).toList(),
    };

    try {
      if (widget.isEdit) {
        await _pembelianService.update(widget.pembelian!.id, payload);
      } else {
        await _pembelianService.store(payload);
      }
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
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      appBar: AppBar(title: Text(widget.isEdit ? 'Edit Pembelian' : 'Tambah Pembelian')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(12),
          children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Tanggal'),
              subtitle: Text(_fmtDate(_tanggal)),
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
            DropdownButtonFormField<Supplier>(
              initialValue: _supplier,
              decoration: const InputDecoration(labelText: 'Supplier', border: OutlineInputBorder()),
              items: _suppliers.map((s) => DropdownMenuItem(value: s, child: Text(s.nama))).toList(),
              onChanged: (v) => setState(() => _supplier = v),
              validator: (v) => v == null ? 'Wajib pilih' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _keteranganCtrl,
              decoration: const InputDecoration(labelText: 'Keterangan', border: OutlineInputBorder()),
              maxLines: 2,
            ),
            const Divider(height: 24),
            const Text('Item Barang', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            ..._items.asMap().entries.map((e) => _itemRowWidget(e.key, e.value)),
            TextButton.icon(
              icon: const Icon(Icons.add),
              label: const Text('Tambah Baris'),
              onPressed: () => setState(() => _items.add(_ItemRow())),
            ),
            const Divider(),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('TOTAL', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  Text(formatRupiah(_grandTotal), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                ],
              ),
            ),
            ElevatedButton.icon(
              onPressed: _saving ? null : _save,
              icon: _saving ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.save),
              label: Text(_saving ? 'Menyimpan...' : (widget.isEdit ? 'Update' : 'Simpan')),
            ),
          ],
        ),
      ),
    );
  }

  Widget _itemRowWidget(int idx, _ItemRow row) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            Row(children: [
              Expanded(
                child: DropdownButtonFormField<Barang>(
                  initialValue: row.barang,
                  isExpanded: true,
                  decoration: const InputDecoration(labelText: 'Barang', isDense: true),
                  items: _barangs.map((b) => DropdownMenuItem(value: b, child: Text('${b.kode} - ${b.nama}', overflow: TextOverflow.ellipsis))).toList(),
                  onChanged: (v) => setState(() {
                    row.barang = v;
                    if (v != null) row.harga = v.hargaPokok;
                  }),
                ),
              ),
              if (_items.length > 1)
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => setState(() => _items.removeAt(idx)),
                ),
            ]),
            Row(children: [
              Expanded(
                child: TextFormField(
                  initialValue: row.qty.toString(),
                  decoration: const InputDecoration(labelText: 'Qty', isDense: true),
                  keyboardType: TextInputType.number,
                  onChanged: (v) => setState(() => row.qty = int.tryParse(v) ?? 1),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextFormField(
                  initialValue: row.harga.toString(),
                  decoration: const InputDecoration(labelText: 'Harga', isDense: true),
                  keyboardType: TextInputType.number,
                  onChanged: (v) => setState(() => row.harga = double.tryParse(v) ?? 0),
                ),
              ),
            ]),
            const SizedBox(height: 4),
            Align(
              alignment: Alignment.centerRight,
              child: Text('Subtotal: ${formatRupiah(row.qty * row.harga)}'),
            ),
          ],
        ),
      ),
    );
  }
}
