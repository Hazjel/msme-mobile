import 'package:flutter/material.dart';
import 'barang/daftar_barang_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  final _daftarBarangKey = GlobalKey<DaftarBarangScreenState>();

  Widget _body() {
    switch (_currentIndex) {
      case 0:
        return DaftarBarangScreen(key: _daftarBarangKey);
      case 1:
        return const _PlaceholderBody(group: '5', fitur: 'Histori Stok', icon: Icons.history);
      case 2:
        return const _PlaceholderBody(group: '4', fitur: 'Notifikasi', icon: Icons.notifications);
      case 3:
        return const _PlaceholderBody(group: '1', fitur: 'Profil Pengguna', icon: Icons.person);
      default:
        return const SizedBox.shrink();
    }
  }

  String _title() {
    switch (_currentIndex) {
      case 0: return 'Daftar Barang';
      case 1: return 'Histori Stok';
      case 2: return 'Notifikasi';
      case 3: return 'Profil';
      default: return '';
    }
  }

  void _openScan() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Scan Barcode'),
        content: const Text('Fitur Kelompok 3 — coming soon.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const Icon(Icons.menu),
        title: Text(_title()),
        actions: [
          if (_currentIndex == 0)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () => _daftarBarangKey.currentState?.reload(),
            ),
        ],
      ),
      body: _body(),
      floatingActionButton: SizedBox(
        width: 60,
        height: 60,
        child: FloatingActionButton(
          onPressed: _openScan,
          backgroundColor: const Color(0xFF1565C0),
          foregroundColor: Colors.white,
          shape: const CircleBorder(),
          elevation: 4,
          tooltip: 'Scan Barcode',
          child: const Icon(Icons.qr_code_scanner, size: 26),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        color: Colors.white,
        elevation: 8,
        height: 60,
        padding: EdgeInsets.zero,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _NavItem(icon: Icons.inventory_2, label: 'Barang', selected: _currentIndex == 0, onTap: () => setState(() => _currentIndex = 0)),
            _NavItem(icon: Icons.history, label: 'Histori', selected: _currentIndex == 1, onTap: () => setState(() => _currentIndex = 1)),
            const SizedBox(width: 56),
            _NavItem(icon: Icons.notifications, label: 'Notifikasi', selected: _currentIndex == 2, onTap: () => setState(() => _currentIndex = 2)),
            _NavItem(icon: Icons.person, label: 'Profil', selected: _currentIndex == 3, onTap: () => setState(() => _currentIndex = 3)),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = selected ? const Color(0xFF1565C0) : Colors.grey.shade600;
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 20),
            Text(label, style: TextStyle(color: color, fontSize: 10, fontWeight: selected ? FontWeight.bold : FontWeight.normal)),
          ],
        ),
      ),
    );
  }
}

class _PlaceholderBody extends StatelessWidget {
  final String group;
  final String fitur;
  final IconData icon;
  const _PlaceholderBody({required this.group, required this.fitur, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF5F7FA),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 80, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(fitur, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Fitur Kelompok $group — coming soon.', style: TextStyle(color: Colors.grey.shade600)),
          ],
        ),
      ),
    );
  }
}
