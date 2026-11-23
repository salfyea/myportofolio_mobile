import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/models/skill.dart';
import 'package:myportofolio_mobile/screens/skill_detail.dart';
import 'package:myportofolio_mobile/services/api_client.dart';
import 'package:myportofolio_mobile/widgets/left_drawer.dart';
import 'package:myportofolio_mobile/widgets/load_error_view.dart';
import 'package:myportofolio_mobile/widgets/refreshable_message.dart';
import 'package:myportofolio_mobile/widgets/remote_image.dart';
import 'package:provider/provider.dart';

/// Daftar skill yang dibaca dari API Django (publik, tanpa login).
///
/// Future pengambilan data dibuat di [State.initState], **bukan** di `build()`.
/// `build()` bisa dipanggil berkali-kali (rotasi layar, papan ketik, tema), dan
/// membuat Future di sana akan mengirim ulang permintaan HTTP tiap kali.
///
/// Empat keadaan ditangani: memuat, galat (dengan tombol Retry), kosong, dan
/// berisi. Tarik ke bawah (RefreshIndicator) memuat ulang di semua keadaan
/// yang bisa digulir.
class SkillListPage extends StatefulWidget {
  const SkillListPage({super.key});

  @override
  State<SkillListPage> createState() => _SkillListPageState();
}

class _SkillListPageState extends State<SkillListPage> {
  late Future<List<Skill>> _skillsFuture;

  @override
  void initState() {
    super.initState();
    _skillsFuture = context.read<ApiClient>().getSkills();
  }

  /// Memuat ulang daftar. Dipakai tombol Retry dan tarik-untuk-muat-ulang.
  Future<void> _reload() async {
    final future = context.read<ApiClient>().getSkills();
    // Body berblok, bukan `=>`: setState melarang callback yang mengembalikan
    // Future, dan `=> _skillsFuture = future` justru mengembalikannya.
    setState(() {
      _skillsFuture = future;
    });

    try {
      await future;
    } on ApiException {
      // Galatnya sudah ditampilkan oleh FutureBuilder; jangan dilempar lagi ke
      // RefreshIndicator.
    }
  }

  /// Membuka detail [skill]. Detail menutup dirinya dengan `true` setelah skill
  /// diubah atau dihapus, dan saat itu daftar dimuat ulang dari server.
  Future<void> _openDetail(Skill skill) async {
    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute<bool>(builder: (_) => SkillDetailPage(skill: skill)),
    );

    if ((changed ?? false) && mounted) {
      await _reload();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Skills')),
      drawer: const LeftDrawer(selected: DrawerDestination.skills),
      body: FutureBuilder<List<Skill>>(
        future: _skillsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return LoadErrorView(
              subject: 'skill',
              error: snapshot.error!,
              onRetry: _reload,
            );
          }

          final skills = snapshot.data ?? const <Skill>[];

          if (skills.isEmpty) {
            // Tetap bisa digulir agar tarik-untuk-muat-ulang berfungsi.
            return RefreshableMessage(
              message: 'Belum ada skill.',
              onRefresh: _reload,
            );
          }

          return RefreshIndicator(
            onRefresh: _reload,
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(12),
              itemCount: skills.length,
              itemBuilder: (context, index) => _SkillTile(
                skill: skills[index],
                onTap: () => _openDetail(skills[index]),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Satu baris skill; [onTap] dipanggil saat baris diketuk.
class _SkillTile extends StatelessWidget {
  const _SkillTile({required this.skill, required this.onTap});

  final Skill skill;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: Card(
          child: ListTile(
            leading: RemoteImage(
              url: skill.iconUrl,
              semanticLabel: 'Ikon ${skill.name}',
              height: 40,
              width: 40,
              fit: BoxFit.contain,
            ),
            title: Text(skill.name),
            // Skill tanpa kategori tidak diberi baris kosong.
            subtitle: skill.category.isEmpty
                ? null
                : Text(
                    skill.category,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.star, size: 16),
                const SizedBox(width: 2),
                Text('${skill.starCount}'),
              ],
            ),
            onTap: onTap,
          ),
        ),
      ),
    );
  }
}
