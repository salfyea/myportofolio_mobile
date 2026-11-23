import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/screens/menu.dart';
import 'package:myportofolio_mobile/widgets/auth_guard.dart';

/// Kartu tombol menu berwarna yang dibangun dari sebuah [ItemHomepage].
///
/// Saat ditekan, kartu menampilkan SnackBar berisi nama tombol, lalu membuka
/// [ItemHomepage.destination] bila ada. Warna dan tujuan kartu diambil dari
/// datanya sendiri, tanpa percabangan if-else per tombol.
class ItemCard extends StatelessWidget {
  final ItemHomepage item;

  const ItemCard(this.item, {super.key});

  /// Menjalankan aksi kartu: SnackBar, login bila diwajibkan, [ItemHomepage.onTap],
  /// lalu membuka [ItemHomepage.destination].
  Future<void> _handleTap(BuildContext context) async {
    // Menampilkan SnackBar dengan pesan interaktif.
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text("Kamu telah menekan tombol ${item.name}!")),
      );

    // Kartu yang menulis data tidak membuka tujuannya sebelum pengguna login.
    // Menekan Back di layar login membatalkan seluruh aksi.
    if (item.requiresLogin && !await ensureLoggedIn(context)) {
      return;
    }
    if (!context.mounted) {
      return;
    }

    await item.onTap?.call(context);
    if (!context.mounted) {
      return;
    }

    // Navigasi ke halaman tujuan kartu (jika ada). push() menumpuk
    // halaman baru di atas menu sehingga tombol Back sistem dapat
    // kembali ke menu.
    final destination = item.destination;
    if (destination != null) {
      Navigator.push(context, MaterialPageRoute<void>(builder: destination));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      // Menggunakan warna milik masing-masing item agar tiap tombol berbeda.
      color: item.color,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        // Aksi ketika kartu ditekan oleh pengguna.
        onTap: () => _handleTap(context),
        child: Container(
          padding: const EdgeInsets.all(8),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(item.icon, color: Colors.white, size: 30.0),
                const Padding(padding: EdgeInsets.all(3)),
                Text(
                  item.name,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
