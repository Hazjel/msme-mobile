import 'package:flutter/material.dart';
import '../../models/barang.dart';
import '../../services/stok_input_service.dart';

class InputStokScreen extends StatefulWidget {
  final Barang barang;
  const InputStokScreen({super.key, required this.barang});

  @override
  State<InputStokScreen> createState() => _InputStokScreenState();
}

class _InputStokScreenState extends State<InputStokScreen> {
  final _service = StokInputService();
  final _qtyCtrl = TextEditingController(text: '0');
  final _keteranganCtrl = TextEditingController();

  DateTime _tanggal = DateTime.now();
  bool _saving = false;
  int _qtyInput = 0;

  @override
  void initState() {
    super.initState();
    _qtyCtrl.addListener(() {
      setState(() {
        _qtyInput = int.tryParse(_qtyCtrl.text) ?? 0;
      });
    });
  }

  int get _qtySetelah => widget.barang.stok + _qtyInput;

  String _fmtDate(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  Future<void> _save() async {
    if (_qtyInput == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Qty tidak boleh 0')),
      );
      return;
    }
    if (_qtySetelah < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Stok tidak boleh negatif. Hasil: $_qtySetelah')),
      );
      return;
    }

    setState(() => _saving = true);
    try {
      await _service.store(
        barangId: widget.barang.id,
        qtyInput: _qtyInput,
        keterangan: _keteranganCtrl.text.isEmpty ? null : _keteranganCtrl.text,
        tanggal: _fmtDate(_tanggal),
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Stok berhasil disimpan')),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      setState(() => _saving = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final b = widget.barang;
    return Scaffold(
      appBar: AppBar(title: const Text('Input Stok')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(b.nama, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text('${b.kode} • ${b.satuan}', style: const TextStyle(color: Colors.grey)),
                  const Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Stok Sebelumnya', style: TextStyle(fontSize: 16)),
                      Text('${b.stok}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
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
          const SizedBox(height: 8),
          TextField(
            controller: _qtyCtrl,
            decoration: const InputDecoration(
              labelText: 'Qty Input',
              helperText: 'Positif = barang masuk, Negatif = barang keluar',
              border: OutlineInputBorder(),
            ),
            keyboardType: const TextInputType.numberWithOptions(signed: true),
          ),
          const SizedBox(height: 12),
          Card(
            color: _qtySetelah < 0 ? Colors.red.shade50 : Colors.green.shade50,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Stok Setelah', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  Text(
                    '$_qtySetelah',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: _qtySetelah < 0 ? Colors.red : Colors.green,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _keteranganCtrl,
            decoration: const InputDecoration(
              labelText: 'Keterangan (opsional)',
              border: OutlineInputBorder(),
            ),
            maxLines: 2,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _saving ? null : _save,
            icon: _saving
                ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.save),
            label: Text(_saving ? 'Menyimpan...' : 'Simpan Stok'),
            style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 12)),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _qtyCtrl.dispose();
    _keteranganCtrl.dispose();
    super.dispose();
  }
}
