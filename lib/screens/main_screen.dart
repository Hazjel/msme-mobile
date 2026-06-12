import 'package:flutter/material.dart';
import 'barang/daftar_barang_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final _screens = const [
    DaftarBarangScreen(),
    _PlaceholderScreen(group: '5', fitur: 'Histori Stok', icon: Icons.history),
    _PlaceholderScreen(group: '4', fitur: 'Notifikasi', icon: Icons.notifications),
    _PlaceholderScreen(group: '1', fitur: 'Profil Pengguna', icon: Icons.person),
  ];

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
      body: _screens[_currentIndex],
      floatingActionButton: FloatingActionButton(
        onPressed: _openScan,
        tooltip: 'Scan Barcode (Grup 3)',
        child: const Icon(Icons.qr_code_scanner),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 6,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _navItem(0, Icons.inventory_2, 'Barang'),
            _navItem(1, Icons.history, 'Histori'),
            const SizedBox(width: 40),
            _navItem(2, Icons.notifications, 'Notifikasi'),
            _navItem(3, Icons.person, 'Profil'),
          ],
        ),
      ),
    );
  }

  Widget _navItem(int index, IconData icon, String label) {
    final selected = _currentIndex == index;
    return IconButton(
      onPressed: () => setState(() => _currentIndex = index),
      tooltip: label,
      icon: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: selected ? Colors.blue : Colors.grey, size: 22),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: selected ? Colors.blue : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}

class _PlaceholderScreen extends StatelessWidget {
  final String group;
  final String fitur;
  final IconData icon;
  const _PlaceholderScreen({required this.group, required this.fitur, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(fitur)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 80, color: Colors.grey),
            const SizedBox(height: 16),
            Text(fitur, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Fitur Kelompok $group — coming soon.', style: const TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}
