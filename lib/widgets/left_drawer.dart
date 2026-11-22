import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/screens/experience_form.dart';
import 'package:myportofolio_mobile/screens/menu.dart';
import 'package:myportofolio_mobile/screens/project_form.dart';

/// Halaman tujuan yang dapat dibuka dari [LeftDrawer].
///
/// Setiap halaman memberi tahu drawer-nya halaman mana yang sedang aktif lewat
/// [LeftDrawer.selected], sehingga satu drawer yang sama bisa dipakai di semua
/// halaman sambil menandai posisi pengguna.
enum DrawerDestination { home, addProject, addExperience }

/// Drawer menu yang muncul dari sisi kiri layar untuk berpindah halaman.
///
/// Komponen ini dipakai bersama oleh halaman utama dan setiap halaman
/// formulir. Daftar pilihannya berbasis data (lihat `_entries`), jadi
/// menambah halaman baru cukup dengan satu entri di sana.
class LeftDrawer extends StatelessWidget {
  const LeftDrawer({super.key, required this.selected});

  /// Halaman yang sedang ditampilkan; pilihannya ditandai di drawer.
  final DrawerDestination selected;

  /// Daftar pilihan drawer, berurutan dari atas ke bawah.
  List<_DrawerEntry> get _entries => [
    _DrawerEntry(
      destination: DrawerDestination.home,
      label: 'Home',
      icon: Icons.home_outlined,
      selectedIcon: Icons.home,
      pageBuilder: (context) => MyHomePage(),
    ),
    _DrawerEntry(
      destination: DrawerDestination.addProject,
      label: 'Add Project',
      icon: Icons.add_circle_outline,
      selectedIcon: Icons.add_circle,
      pageBuilder: (context) => const ProjectFormPage(),
    ),
    _DrawerEntry(
      destination: DrawerDestination.addExperience,
      label: 'Add Experience',
      icon: Icons.work_outline,
      selectedIcon: Icons.work,
      pageBuilder: (context) => const ExperienceFormPage(),
    ),
  ];

  /// Membuka halaman tujuan [entry] dari drawer.
  ///
  /// - Halaman yang sedang aktif: drawer cukup ditutup. Berpindah ke halaman
  ///   yang sama akan membangun ulang form dan menghapus isian pengguna.
  /// - Home: `pushAndRemoveUntil` membuang seluruh tumpukan halaman. Jika
  ///   `pushReplacement` dipakai, form yang dibuka lewat `push` dari kartu
  ///   akan meninggalkan dua halaman utama bertumpuk (Home, Home).
  /// - Halaman formulir: `pushReplacement` menggantikan halaman saat ini
  ///   sehingga pindah antarformulir lewat drawer tidak menumpuk halaman.
  void _open(BuildContext context, _DrawerEntry entry) {
    if (entry.destination == selected) {
      Navigator.pop(context);
      return;
    }

    final route = MaterialPageRoute<void>(builder: entry.pageBuilder);

    if (entry.destination == DrawerDestination.home) {
      Navigator.pushAndRemoveUntil(context, route, (route) => false);
    } else {
      Navigator.pushReplacement(context, route);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Drawer(
      child: ListView(
        children: [
          // Header drawer: judul dan deskripsi singkat aplikasi. Warnanya
          // diambil dari tema agar sama dengan AppBar di setiap halaman.
          DrawerHeader(
            decoration: BoxDecoration(color: colorScheme.primary),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'My Portfolio',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onPrimary,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Explore personal projects and experiences!',
                  style: TextStyle(fontSize: 15, color: colorScheme.onPrimary),
                ),
              ],
            ),
          ),
          for (final entry in _entries)
            ListTile(
              leading: Icon(
                entry.destination == selected ? entry.selectedIcon : entry.icon,
              ),
              title: Text(entry.label),
              // Halaman aktif diberi warna tema dan latar tipis.
              selected: entry.destination == selected,
              selectedTileColor: colorScheme.primary.withValues(alpha: 0.08),
              onTap: () => _open(context, entry),
            ),
        ],
      ),
    );
  }
}

/// Satu pilihan pada [LeftDrawer]: tujuan, tampilan, dan pembuat halamannya.
class _DrawerEntry {
  const _DrawerEntry({
    required this.destination,
    required this.label,
    required this.icon,
    required this.selectedIcon,
    required this.pageBuilder,
  });

  final DrawerDestination destination;
  final String label;

  /// Ikon biasa dan ikon terisi untuk keadaan terpilih.
  final IconData icon;
  final IconData selectedIcon;

  /// Membuat halaman tujuan saat pilihan ini ditekan.
  final WidgetBuilder pageBuilder;
}
