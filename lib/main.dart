import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/screens/menu.dart';
import 'package:myportofolio_mobile/services/api_client.dart';
import 'package:myportofolio_mobile/services/auth_state.dart';
import 'package:provider/provider.dart';

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
///
/// [MultiProvider] menyediakan [ApiClient] dan [AuthState] ke seluruh widget
/// tree, jadi layar tidak membuat klien HTTP sendiri dan tes bisa memasang
/// [apiClient] palsu lewat parameter ini.
class MyApp extends StatefulWidget {
  const MyApp({super.key, this.apiClient});

  /// Klien API yang dipakai aplikasi; bila kosong, dibuat dengan `ApiClient()`.
  final ApiClient? apiClient;

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // Dibuat sekali di sini (bukan di build) supaya AuthState dan seluruh layar
  // memakai objek yang sama walau MyApp dibangun ulang.
  late final ApiClient _apiClient = widget.apiClient ?? ApiClient();

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: Colors.indigo,
      secondary: Colors.amber[700],
    );

    return MultiProvider(
      providers: [
        Provider<ApiClient>.value(value: _apiClient),
        ChangeNotifierProvider<AuthState>(create: (_) => AuthState(_apiClient)),
      ],
      child: MaterialApp(
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
      ),
    );
  }
}
