import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/models/skill.dart';
import 'package:myportofolio_mobile/screens/skill_form.dart';
import 'package:myportofolio_mobile/services/api_client.dart';
import 'package:myportofolio_mobile/services/auth_state.dart';
import 'package:myportofolio_mobile/utils/formatters.dart';
import 'package:myportofolio_mobile/widgets/auth_guard.dart';
import 'package:myportofolio_mobile/widgets/detail_section.dart';
import 'package:myportofolio_mobile/widgets/remote_image.dart';
import 'package:provider/provider.dart';

/// Halaman detail satu [Skill]: menampilkan seluruh field yang dikirim API.
///
/// Dibuka saat sebuah item pada `SkillListPage` diketuk. Data diteruskan lewat
/// konstruktor, jadi halaman ini tidak perlu memanggil API lagi untuk membaca.
///
/// Kategori yang kosong tidak digambar sebagai chip kosong.
///
/// Setelah login, AppBar menampilkan dua aksi tulis:
///
/// - **Edit** membuka [SkillFormPage] (`PATCH /api/v1/skills/<id>/`).
/// - **Hapus** meminta konfirmasi lalu mengirim `DELETE /api/v1/skills/<id>/`.
///
/// Setelah salah satunya berhasil, halaman ini ditutup dengan hasil `true`
/// supaya daftar memuat ulang dari server. Server tetap penentu hak akses:
/// akun yang bukan pemilik mendapat 403 yang tampil di SnackBar.
class SkillDetailPage extends StatefulWidget {
  const SkillDetailPage({super.key, required this.skill});

  final Skill skill;

  @override
  State<SkillDetailPage> createState() => _SkillDetailPageState();
}

class _SkillDetailPageState extends State<SkillDetailPage> {
  /// Permintaan hapus sedang berjalan; menonaktifkan kedua aksi agar tidak
  /// terkirim dua kali.
  bool _isBusy = false;

  /// Membuka form ubah. Bila tersimpan, kabari pengguna lalu kembali ke daftar.
  Future<void> _edit() async {
    // Diambil sebelum await: context tidak boleh dipakai sesudahnya tanpa
    // memeriksa `mounted`.
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);

    final updated = await navigator.push<Skill>(
      MaterialPageRoute<Skill>(
        builder: (_) => SkillFormPage(skill: widget.skill),
      ),
    );
    if (updated == null || !mounted) {
      return;
    }

    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(const SnackBar(content: Text('Skill diperbarui.')));
    navigator.pop(true);
  }

  /// Meminta konfirmasi, lalu menghapus skill ini di server.
  Future<void> _delete() async {
    final skill = widget.skill;
    final id = skill.id;
    if (id == null) {
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Hapus skill?'),
        content: Text(
          'Skill "${skill.name}" akan dihapus permanen dan tidak bisa '
          'dikembalikan.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (!(confirmed ?? false) || !mounted) {
      return;
    }

    final api = context.read<ApiClient>();
    final auth = context.read<AuthState>();
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    // Token bisa saja sudah dihapus sejak halaman dibuka.
    if (!await ensureLoggedIn(context)) {
      return;
    }
    final token = auth.token;
    if (!mounted || token == null) {
      return;
    }

    setState(() => _isBusy = true);

    ApiException? failure;
    try {
      await api.deleteSkill(id, token: token);
    } on ApiException catch (error) {
      failure = error;
    } finally {
      if (mounted) {
        setState(() => _isBusy = false);
      }
    }

    if (!mounted) {
      return;
    }
    if (failure != null) {
      // Pada 401 sesi dihapus dan login diminta ulang.
      await handleApiFailure(
        context,
        failure,
        retryHint: 'Login berhasil. Tekan Hapus sekali lagi.',
      );
      return;
    }

    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text('Skill "${skill.name}" dihapus.')));
    navigator.pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final skill = widget.skill;
    final textTheme = Theme.of(context).textTheme;
    // watch: tombol muncul dan hilang saat login atau logout.
    final canManage = context.watch<AuthState>().isLoggedIn && skill.id != null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Skill'),
        actions: [
          if (canManage) ...[
            IconButton(
              tooltip: 'Edit skill',
              icon: const Icon(Icons.edit_outlined),
              onPressed: _isBusy ? null : _edit,
            ),
            IconButton(
              tooltip: 'Hapus skill',
              icon: const Icon(Icons.delete_outline),
              onPressed: _isBusy ? null : _delete,
            ),
          ],
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: 16,
                children: [
                  Center(
                    child: RemoteImage(
                      url: skill.iconUrl,
                      semanticLabel: 'Ikon ${skill.name}',
                      height: 120,
                      width: 120,
                      fit: BoxFit.contain,
                    ),
                  ),

                  Text(skill.name, style: textTheme.headlineSmall),

                  if (skill.category.isNotEmpty)
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Chip(label: Text(skill.category)),
                    ),

                  DetailSection(
                    label: 'URL Ikon',
                    child: SelectableText(skill.iconUrl),
                  ),

                  DetailSection(
                    label: 'Bintang',
                    child: Text(
                      formatStarSummary(skill.starCount, skill.starredByNames),
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
