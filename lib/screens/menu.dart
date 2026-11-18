import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/widgets/left_drawer.dart';
import 'package:myportofolio_mobile/widgets/project_card.dart';

/// Halaman menu utama MyPortfolio Mobile.
///
/// Berupa [StatelessWidget] karena seluruh isinya statis (identitas pemilik dan
/// daftar tombol) sehingga tidak perlu menyimpan state yang berubah.
///
/// Susunan halaman: [InfoCard] identitas di bagian atas, pesan sambutan, lalu
/// kisi [ItemCard] untuk tiap menu portofolio.
class MyHomePage extends StatelessWidget {
  MyHomePage({super.key});

  final String npm = "2506620280";
  final String nama = "Salwa Alifia Putri";
  final String kelas = "PBP A";

  /// Daftar menu aksi yang ditampilkan sebagai kisi tombol.
  ///
  /// Setiap [ItemHomepage] membawa nama, ikon, dan warnanya sendiri, sehingga
  /// menambah tombol baru cukup dengan menambah satu baris di daftar ini.
  final List<ItemHomepage> items = [
    ItemHomepage("Lihat Experience", Icons.work, Colors.blue.shade700),
    ItemHomepage("Lihat Proyek", Icons.folder, Colors.deepPurple.shade500),
    ItemHomepage("Lihat Skills", Icons.code, Colors.brown.shade600),
    ItemHomepage("Tambah Proyek", Icons.add_circle, Colors.green.shade700),
    ItemHomepage("Tambah Skill", Icons.playlist_add, Colors.orange.shade800),
    ItemHomepage("Logout", Icons.logout, Colors.red.shade700),
  ];

  @override
  Widget build(BuildContext context) {
    // Scaffold menyediakan struktur visual dasar halaman (AppBar, Body, SnackBar).
    return Scaffold(
      // AppBar menampilkan bar bagian atas halaman aplikasi.
      appBar: AppBar(
        title: const Text(
          'MyPortfolio',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        // Ikon drawer (hamburger) dibuat putih agar kontras dengan AppBar.
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      // Drawer menu untuk navigasi antarhalaman.
      drawer: const LeftDrawer(),
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
class ItemHomepage {
  final String name;
  final IconData icon;
  final Color color;

  ItemHomepage(this.name, this.icon, this.color);
}
