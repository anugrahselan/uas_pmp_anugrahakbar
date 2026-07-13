import 'package:flutter/material.dart';
import '../services/book_service.dart';

class FormScreen extends StatefulWidget {
  // Jika index == null => mode tambah, jika ada => mode edit
  final int? index;
  final Map<String, dynamic>? data;

  const FormScreen({super.key, this.index, this.data});

  @override
  State<FormScreen> createState() => _FormScreenState();
}

class _FormScreenState extends State<FormScreen> {
  final _formKey = GlobalKey<FormState>();

  final _judulController = TextEditingController();
  final _penulisController = TextEditingController();
  final _penerbitController = TextEditingController();
  final _tahunController = TextEditingController();
  final _halamanController = TextEditingController();

  String _kategori = 'Fiksi';
  String _statusBaca = 'Belum Dibaca';

  final List<String> _daftarKategori = [
    'Fiksi',
    'Non-Fiksi',
    'Pendidikan',
    'Komik',
    'Novel',
    'Biografi',
    'Lainnya',
  ];

  final List<String> _daftarStatus = [
    'Belum Dibaca',
    'Sedang Dibaca',
    'Selesai Dibaca',
  ];

  bool _isEdit = false;

  @override
  void initState() {
    super.initState();
    // Jika data sudah ada (mode edit), isi otomatis field-nya
    if (widget.data != null) {
      _isEdit = true;
      _judulController.text = widget.data!['judul'] ?? '';
      _penulisController.text = widget.data!['penulis'] ?? '';
      _penerbitController.text = widget.data!['penerbit'] ?? '';
      _tahunController.text = '${widget.data!['tahunTerbit'] ?? ''}';
      _halamanController.text = '${widget.data!['jumlahHalaman'] ?? ''}';
      _kategori = widget.data!['kategori'] ?? 'Fiksi';
      _statusBaca = widget.data!['statusBaca'] ?? 'Belum Dibaca';
    }
  }

  @override
  void dispose() {
    _judulController.dispose();
    _penulisController.dispose();
    _penerbitController.dispose();
    _tahunController.dispose();
    _halamanController.dispose();
    super.dispose();
  }

  void _simpan() {
    if (!_formKey.currentState!.validate()) return;

    final dataBaru = {
      'judul': _judulController.text.trim(),
      'penulis': _penulisController.text.trim(),
      'penerbit': _penerbitController.text.trim(),
      'tahunTerbit': int.parse(_tahunController.text.trim()),
      'kategori': _kategori,
      'jumlahHalaman': int.parse(_halamanController.text.trim()),
      'statusBaca': _statusBaca,
    };

    if (_isEdit) {
      // Update data pada index yang sama
      updateBuku(widget.index!, dataBaru);
    } else {
      // Tambah data baru
      tambahBuku(dataBaru);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_isEdit ? 'Buku berhasil diperbarui!' : 'Buku berhasil ditambahkan!'),
        backgroundColor: Colors.green,
      ),
    );

    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? 'Edit Buku' : 'Tambah Buku'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _judulController,
                decoration: const InputDecoration(
                  labelText: 'Judul',
                  prefixIcon: Icon(Icons.book_outlined),
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Judul harus diisi' : null,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _penulisController,
                decoration: const InputDecoration(
                  labelText: 'Penulis',
                  prefixIcon: Icon(Icons.person_outline),
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Penulis harus diisi' : null,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _penerbitController,
                decoration: const InputDecoration(
                  labelText: 'Penerbit',
                  prefixIcon: Icon(Icons.business_outlined),
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Penerbit harus diisi' : null,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _tahunController,
                decoration: const InputDecoration(
                  labelText: 'Tahun Terbit',
                  prefixIcon: Icon(Icons.calendar_today_outlined),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Tahun harus diisi';
                  final tahun = int.tryParse(v.trim());
                  if (tahun == null) return 'Harus berupa angka';
                  if (tahun < 1000) return 'Minimal tahun 1000';
                  if (tahun > DateTime.now().year) return 'Tidak boleh melebihi tahun sekarang';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _halamanController,
                decoration: const InputDecoration(
                  labelText: 'Jumlah Halaman',
                  prefixIcon: Icon(Icons.library_books_outlined),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Jumlah halaman harus diisi';
                  if (int.tryParse(v.trim()) == null) return 'Harus berupa angka';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Dropdown Kategori
              DropdownButtonFormField<String>(
                initialValue: _kategori,
                decoration: const InputDecoration(
                  labelText: 'Kategori',
                  prefixIcon: Icon(Icons.category_outlined),
                  border: OutlineInputBorder(),
                ),
                items: _daftarKategori
                    .map((k) => DropdownMenuItem(value: k, child: Text(k)))
                    .toList(),
                onChanged: (v) {
                  if (v != null) _kategori = v;
                },
              ),
              const SizedBox(height: 16),

              // Dropdown Status Baca
              DropdownButtonFormField<String>(
                initialValue: _statusBaca,
                decoration: const InputDecoration(
                  labelText: 'Status Baca',
                  prefixIcon: Icon(Icons.check_circle_outline),
                  border: OutlineInputBorder(),
                ),
                items: _daftarStatus
                    .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                    .toList(),
                onChanged: (v) {
                  if (v != null) _statusBaca = v;
                },
              ),
              const SizedBox(height: 24),

              FilledButton.icon(
                onPressed: _simpan,
                icon: const Icon(Icons.save),
                label: Text(_isEdit ? 'Perbarui' : 'Simpan'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
