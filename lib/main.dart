import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'pages/splash_screen.dart';
import 'pages/home_page.dart';

void main() async {
  // Inisialisasi Hive Flutter sebelum runApp
  await Hive.initFlutter();
  await Hive.openBox('bukuBox');

  runApp(const BukuApp());
}

class BukuApp extends StatelessWidget {
  const BukuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Data Buku',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.teal, // Warna utama teal
        useMaterial3: true,
        brightness: Brightness.light,
      ),
      // Named routes
      initialRoute: '/',
      routes: {
        '/': (_) => const SplashScreen(),
        '/home': (_) => const HomeScreen(),
      },
    );
  }
}
