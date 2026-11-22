import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/screens/menu.dart';

/// Titik masuk aplikasi: fungsi pertama yang dijalankan Flutter.
void main() {
  runApp(const MyApp());
}

/// Widget akar aplikasi.
///
/// Membungkus aplikasi dengan [MaterialApp] yang menyediakan tema Material 3
/// (skema warna dari seed indigo) dan menetapkan [MyHomePage] sebagai halaman
/// awal.
///
/// Warna AppBar ditetapkan satu kali di [AppBarTheme], bukan per halaman.
/// Dengan begitu halaman utama dan semua halaman formulir otomatis memakai
/// warna yang sama (`colorScheme.primary`), dan mengganti warna portofolio
/// cukup dengan mengubah `seedColor` di sini.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: Colors.indigo,
      secondary: Colors.amber[700],
    );

    return MaterialApp(
      title: 'MyPortfolio',
      theme: ThemeData(
        colorScheme: colorScheme,
        useMaterial3: true,
        // foregroundColor mewarnai judul sekaligus ikon hamburger drawer.
        appBarTheme: AppBarTheme(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
        ),
      ),
      home: MyHomePage(),
    );
  }
}
