import 'package:hive/hive.dart';

// Nama box Hive untuk menyimpan data buku
const String _boxName = 'bukuBox';

// Mengembalikan referensi ke box 'bukuBox'
// Box ini menyimpan data sebagai Map<String, dynamic> (tanpa adapter)
Box<dynamic> _getBox() {
  return Hive.box(_boxName);
}

// Menambahkan data buku baru ke dalam box
// box.add() mengembalikan int sebagai key otomatis
void tambahBuku(Map<String, dynamic> data) {
  _getBox().add(data);
}

// Mengupdate data buku pada index tertentu
// Menggunakan box.putAt(index, data) sesuai materi Pertemuan 10
void updateBuku(int index, Map<String, dynamic> data) {
  _getBox().putAt(index, data);
}

// Menghapus data buku pada index tertentu
// Menggunakan box.deleteAt(index) sesuai materi Pertemuan 10
void hapusBuku(int index) {
  _getBox().deleteAt(index);
}

// Mengambil semua data buku sebagai List<Map<String, dynamic>>
List<Map<String, dynamic>> ambilSemuaBuku() {
  final box = _getBox();
  List<Map<String, dynamic>> daftar = [];
  for (int i = 0; i < box.length; i++) {
    final data = box.getAt(i);
    if (data != null) {
      daftar.add(Map<String, dynamic>.from(data as Map));
    }
  }
  return daftar;
}

// Mengambil satu data buku berdasarkan index
Map<String, dynamic>? ambilBukuByIndex(int index) {
  final data = _getBox().getAt(index);
  if (data != null) {
    return Map<String, dynamic>.from(data as Map);
  }
  return null;
}

// Mengembalikan jumlah total data di box
int totalBuku() {
  return _getBox().length;
}
