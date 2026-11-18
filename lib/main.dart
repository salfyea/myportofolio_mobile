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
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MyPortfolio',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.indigo,
          secondary: Colors.amber[700],
        ),
        useMaterial3: true,
      ),
      home: MyHomePage(),
    );
  }
}
