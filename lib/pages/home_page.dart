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
    // Warna badge status
    Color warnaStatus(String s) {
      switch (s) {
        case 'Selesai Dibaca': return Colors.green;
        case 'Sedang Dibaca':  return Colors.orange;
        default:               return Colors.grey;
      }
    }

    showDialog(
      context: ctx,
      builder: (dialogCtx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header dengan ikon & status
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.menu_book_rounded,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          buku['judul'] ?? '',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: warnaStatus(buku['statusBaca'] ?? '')
                                .withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            buku['statusBaca'] ?? '',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: warnaStatus(buku['statusBaca'] ?? ''),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Divider(height: 24),
              // Detail field
              _detailRow(Icons.person_outline, 'Penulis', buku['penulis'] ?? ''),
              const SizedBox(height: 8),
              _detailRow(Icons.business_outlined, 'Penerbit', buku['penerbit'] ?? ''),
              const SizedBox(height: 8),
              _detailRow(Icons.calendar_today_outlined, 'Tahun', '${buku['tahunTerbit'] ?? ''}'),
              const SizedBox(height: 8),
              _detailRow(Icons.category_outlined, 'Kategori', buku['kategori'] ?? ''),
              const SizedBox(height: 8),
              _detailRow(Icons.library_books_outlined, 'Halaman', '${buku['jumlahHalaman'] ?? ''} halaman'),
              const Divider(height: 24),
              // Tombol aksi
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(dialogCtx),
                    child: const Text('Tutup'),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(dialogCtx);
                      _confirmHapus(index);
                    },
                    icon: const Icon(Icons.delete_outline, size: 18),
                    label: const Text('Hapus'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                    ),
                  ),
                  const SizedBox(width: 8),
                  FilledButton.icon(
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
                    icon: const Icon(Icons.edit_outlined, size: 18),
                    label: const Text('Edit'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _detailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 12),
        SizedBox(
          width: 70,
          child: Text(
            label,
            style: TextStyle(fontSize: 13, color: Colors.grey[500]),
          ),
        ),
        Expanded(
          child: Text(value, style: const TextStyle(fontSize: 15)),
        ),
      ],
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
        title: const Text('Data Buku Pribadi Saya'),
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

          return BookCard(
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
          );
        },
      ),
    );
  }
}
