import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/screens/experience_form.dart';
import 'package:myportofolio_mobile/screens/project_form.dart';
import 'package:myportofolio_mobile/screens/project_list.dart';
import 'package:myportofolio_mobile/services/auth_state.dart';
import 'package:myportofolio_mobile/widgets/auth_guard.dart';
import 'package:myportofolio_mobile/widgets/left_drawer.dart';
import 'package:myportofolio_mobile/widgets/project_card.dart';
import 'package:provider/provider.dart';

/// Halaman menu utama MyPortfolio Mobile.
///
/// Berupa [StatelessWidget] karena seluruh isinya statis (identitas pemilik dan
/// daftar tombol) sehingga tidak perlu menyimpan state yang berubah.
///
/// Susunan halaman: [InfoCard] identitas di bagian atas, pesan sambutan, lalu
/// kisi [ItemCard] untuk tiap menu portofolio.
class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  final String npm = "2506620280";
  final String nama = "Salwa Alifia Putri";
  final String kelas = "PBP A";

  /// Daftar menu aksi yang ditampilkan sebagai kisi tombol.
  ///
  /// Setiap [ItemHomepage] membawa nama, ikon, warna, dan (bila ada) halaman
  /// tujuan serta aturannya sendiri, sehingga menambah tombol baru cukup dengan
  /// menambah satu baris di daftar ini tanpa menyentuh [ItemCard].
  ///
  /// Tombol terakhir berganti sesuai sesi: **Login** saat belum masuk dan
  /// **Logout** saat sudah masuk.
  List<ItemHomepage> itemsFor({required bool isLoggedIn}) => [
    ItemHomepage("Lihat Experience", Icons.work, Colors.blue.shade700),
    ItemHomepage(
      "Lihat Proyek",
      Icons.folder,
      Colors.deepPurple.shade500,
      destination: (context) => const ProjectListPage(),
    ),
    ItemHomepage("Lihat Skills", Icons.code, Colors.brown.shade600),
    ItemHomepage(
      "Tambah Proyek",
      Icons.add_circle,
      Colors.green.shade700,
      destination: (context) => const ProjectFormPage(),
      requiresLogin: true,
    ),
    ItemHomepage(
      "Tambah Experience",
      Icons.work_history,
      Colors.teal.shade700,
      destination: (context) => const ExperienceFormPage(),
    ),
    ItemHomepage("Tambah Skill", Icons.playlist_add, Colors.orange.shade800),
    if (isLoggedIn)
      ItemHomepage("Logout", Icons.logout, Colors.red.shade700, onTap: _logout)
    else
      ItemHomepage("Login", Icons.login, Colors.red.shade700, onTap: _login),
  ];

  /// Aksi kartu Login: membuka layar login dan memberi kabar bila berhasil.
  static Future<void> _login(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);

    if (await ensureLoggedIn(context)) {
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(const SnackBar(content: Text('Login berhasil.')));
    }
  }

  /// Aksi kartu Logout: mencabut token lalu memberi kabar.
  static Future<void> _logout(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);

    await context.read<AuthState>().logout();

    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(const SnackBar(content: Text('Kamu telah logout.')));
  }

  @override
  Widget build(BuildContext context) {
    // watch: kisi tombol dibangun ulang saat login/logout (Login <-> Logout).
    final items = itemsFor(isLoggedIn: context.watch<AuthState>().isLoggedIn);

    // Scaffold menyediakan struktur visual dasar halaman (AppBar, Body, SnackBar).
    return Scaffold(
      // AppBar menampilkan bar bagian atas halaman aplikasi.
      // Warna AppBar (latar, judul, ikon drawer) berasal dari AppBarTheme di
      // MyApp, sehingga sama persis dengan halaman formulir.
      appBar: AppBar(
        title: const Text(
          'MyPortfolio',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      // Drawer menu untuk navigasi antarhalaman.
      drawer: const LeftDrawer(selected: DrawerDestination.home),
      // Body halaman utama dengan padding di sekelilingnya.
      // SingleChildScrollView agar halaman bisa di-scroll saat konten melebihi layar.
      body: SingleChildScrollView(
        // Center + ConstrainedBox membatasi lebar konten (maks. 600) agar kartu
        // tidak melebar berlebihan di layar lebar seperti browser/desktop.
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Baris horizontal untuk menampilkan 3 InfoCard secara sejajar.
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Flexible mencegah Row overflow di layar sempit (lebar kartu
                      // otomatis mengecil jika ruang tidak cukup).
                      Flexible(
                        child: InfoCard(title: 'NPM', content: npm),
                      ),
                      Flexible(
                        child: InfoCard(title: 'Name', content: nama),
                      ),
                      Flexible(
                        child: InfoCard(title: 'Class', content: kelas),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16.0),

                  // Bagian tengah: pesan sambutan dan kisi tombol menu portofolio.
                  Center(
                    child: Column(
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(top: 16.0),
                          child: Text(
                            'Selamat datang di MyPortfolio Mobile!',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18.0,
                            ),
                          ),
                        ),

                        // GridView menampilkan kartu tombol dalam tata letak kisi 3 kolom.
                        GridView.count(
                          // Scroll ditangani SingleChildScrollView di luar, bukan grid ini.
                          primary: false,
                          physics: const NeverScrollableScrollPhysics(),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 20,
                          ),
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          crossAxisCount: 3,
                          // Rasio lebar:tinggi tiap kartu agar isi (ikon + teks) muat.
                          childAspectRatio: 0.9,
                          // shrinkWrap agar ukuran kisi menyesuaikan tinggi konten anak.
                          shrinkWrap: true,
                          children: items.map((ItemHomepage item) {
                            return ItemCard(item);
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Kartu kecil yang menampilkan sepasang [title] dan [content].
///
/// Dipakai ulang (reusable) untuk NPM, nama, dan kelas agar tidak ada kode
/// kartu yang berulang.
class InfoCard extends StatelessWidget {
  // Kartu informasi yang menampilkan judul (title) dan isi (content).
  final String title;
  final String content;

  const InfoCard({super.key, required this.title, required this.content});

  @override
  Widget build(BuildContext context) {
    return Card(
      // Memberikan efek bayangan kartu elevasi 2 unit.
      elevation: 2.0,
      child: Container(
        // Menyesuaikan lebar kartu dengan proporsi layar (dibagi 3.5).
        width: MediaQuery.of(context).size.width / 3.5,
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 16.0),
        // Menyusun teks title dan content secara vertikal.
        child: Column(
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8.0),
            Text(content),
          ],
        ),
      ),
    );
  }
}

/// Model data untuk satu tombol menu: [name] sebagai teks, [icon] sebagai
/// ikon, dan [color] sebagai warna latar kartunya.
///
/// [destination] opsional: bila diisi, menekan kartu membuka halaman itu
/// dengan `Navigator.push()`; bila kosong, kartu hanya menampilkan SnackBar
/// (fitur tersebut belum dibuat).
///
/// [requiresLogin] membuat kartu meminta login lebih dulu (lewat
/// `ensureLoggedIn`) dan baru melanjutkan bila berhasil. [onTap] opsional
/// adalah aksi yang dijalankan sebelum [destination] dibuka, misalnya Logout.
class ItemHomepage {
  final String name;
  final IconData icon;
  final Color color;
  final WidgetBuilder? destination;
  final bool requiresLogin;
  final Future<void> Function(BuildContext context)? onTap;

  ItemHomepage(
    this.name,
    this.icon,
    this.color, {
    this.destination,
    this.requiresLogin = false,
    this.onTap,
  });
}
