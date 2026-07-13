import 'package:flutter/material.dart';
import '../services/book_service.dart';
import '../widgets/book_card.dart';
import 'form_page.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, dynamic>> _semuaBuku = [];
  List<Map<String, dynamic>> _bukuTampil = [];

  String _filterKategori = 'Semua';
  String _filterStatus = 'Semua';

  final List<String> _daftarKategori = [
    'Semua',
    'Fiksi',
    'Non-Fiksi',
    'Pendidikan',
    'Komik',
    'Novel',
    'Biografi',
    'Lainnya',
  ];

  final List<String> _daftarStatus = [
    'Semua',
    'Belum Dibaca',
    'Sedang Dibaca',
    'Selesai Dibaca',
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    setState(() {
      _semuaBuku = ambilSemuaBuku();
    });
    _filterData();
  }

  void _filterData() {
    setState(() {
      _bukuTampil = _semuaBuku.where((buku) {
        final matchKategori = _filterKategori == 'Semua' ||
            buku['kategori'] == _filterKategori;
        final matchStatus = _filterStatus == 'Semua' ||
            buku['statusBaca'] == _filterStatus;
        return matchKategori && matchStatus;
      }).toList();
    });
  }

  void _showDetailDialog(BuildContext ctx, Map<String, dynamic> buku, int index) {
    showDialog(
      context: ctx,
      builder: (dialogCtx) => AlertDialog(
        title: Text(buku['judul'] ?? ''),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _detailItem('Penulis', buku['penulis'] ?? ''),
              _detailItem('Penerbit', buku['penerbit'] ?? ''),
              _detailItem('Tahun Terbit', '${buku['tahunTerbit'] ?? ''}'),
              _detailItem('Kategori', buku['kategori'] ?? ''),
              _detailItem('Jumlah Halaman', '${buku['jumlahHalaman'] ?? ''} halaman'),
              _detailItem('Status Baca', buku['statusBaca'] ?? ''),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogCtx);
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => FormScreen(index: index, data: buku),
                ),
              );
              if (result == true) _loadData();
            },
            child: const Text('Edit'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogCtx);
              _confirmHapus(index);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  Widget _detailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  void _confirmHapus(int index) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Buku'),
        content: Text(
          'Yakin ingin menghapus "${_semuaBuku[index]['judul'] ?? ''}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              hapusBuku(index);
              Navigator.pop(ctx);
              _loadData();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Buku berhasil dihapus!'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Data Buku'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Filter dropdown
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: _filterKategori,
                    decoration: const InputDecoration(
                      labelText: 'Kategori',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    isDense: true,
                    items: _daftarKategori
                        .map((k) => DropdownMenuItem(value: k, child: Text(k)))
                        .toList(),
                    onChanged: (v) {
                      if (v != null) {
                        setState(() => _filterKategori = v);
                        _filterData();
                      }
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: _filterStatus,
                    decoration: const InputDecoration(
                      labelText: 'Status',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    isDense: true,
                    items: _daftarStatus
                        .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                        .toList(),
                    onChanged: (v) {
                      if (v != null) {
                        setState(() => _filterStatus = v);
                        _filterData();
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _semuaBuku.isEmpty
                ? _buildEmptyState()
                : _bukuTampil.isEmpty
                    ? _buildNoMatchState()
                    : _buildList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const FormScreen()),
          );
          if (result == true) _loadData();
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.menu_book_outlined, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Belum ada data buku',
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            'Tekan tombol + untuk menambah buku',
            style: TextStyle(fontSize: 14, color: Colors.grey[400]),
          ),
        ],
      ),
    );
  }

  Widget _buildNoMatchState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.filter_list_off, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Tidak ada buku yang cocok',
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildList() {
    return RefreshIndicator(
      onRefresh: () async => _loadData(),
      child: ListView.builder(
        padding: const EdgeInsets.only(top: 8, bottom: 80),
        itemCount: _bukuTampil.length,
        itemBuilder: (context, i) {
          final buku = _bukuTampil[i];
          final indexAsli = _semuaBuku.indexOf(buku);

          return Dismissible(
            key: ValueKey(buku.hashCode),
            direction: DismissDirection.endToStart,
            background: Container(
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 20),
              color: Colors.red,
              child: const Icon(Icons.delete, color: Colors.white),
            ),
            confirmDismiss: (_) async {
              final hapus = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Hapus Buku'),
                  content: Text(
                    'Yakin ingin menghapus "${buku['judul'] ?? ''}"?',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: const Text('Batal'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      style: TextButton.styleFrom(foregroundColor: Colors.red),
                      child: const Text('Hapus'),
                    ),
                  ],
                ),
              );
              if (hapus == true) {
                hapusBuku(indexAsli);
                _loadData();
                if (!context.mounted) return false;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Buku berhasil dihapus!'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
              return false;
            },
            child: BookCard(
              buku: buku,
              index: indexAsli,
              onTap: () => _showDetailDialog(context, buku, indexAsli),
              onEdit: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => FormScreen(index: indexAsli, data: buku),
                  ),
                );
                if (result == true) _loadData();
              },
              onDelete: () => _confirmHapus(indexAsli),
            ),
          );
        },
      ),
    );
  }
}
