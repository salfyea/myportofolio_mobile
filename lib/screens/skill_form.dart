import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/models/skill.dart';
import 'package:myportofolio_mobile/screens/skill_list.dart';
import 'package:myportofolio_mobile/services/api_client.dart';
import 'package:myportofolio_mobile/services/auth_state.dart';
import 'package:myportofolio_mobile/utils/validators.dart';
import 'package:myportofolio_mobile/widgets/app_text_form_field.dart';
import 'package:myportofolio_mobile/widgets/auth_guard.dart';
import 'package:myportofolio_mobile/widgets/left_drawer.dart';
import 'package:provider/provider.dart';

/// Halaman form untuk menambah atau mengubah skill lewat API Django.
///
/// Alur **Save**: validasi form, pastikan pengguna login (`ensureLoggedIn`),
/// lalu kirim permintaan dengan token dari `AuthState`:
///
/// - **Tambah** ([skill] kosong): `POST /api/v1/skills/`. Berhasil (201):
///   dialog konfirmasi dengan pilihan **Tambah Lagi** atau **Lihat Daftar**.
///   Daftar dimuat ulang dari server, jadi skill baru langsung tampil di sana.
/// - **Ubah** ([skill] diisi): `PATCH /api/v1/skills/<id>/`. Kolom terisi data
///   skill itu, dan berhasil berarti halaman ditutup dengan mengembalikan
///   [Skill] hasil server ke pemanggilnya.
///
/// Pada keduanya, 401 (token dicabut atau tidak berlaku) menghapus sesi lokal
/// dan meminta login ulang dengan isian tetap ada; galat lain (403 bukan
/// pemilik, 400 validasi server, jaringan) tampil di SnackBar.
///
/// Kolom mengikuti `SkillSerializer` di Django: name, icon_url, dan category.
class SkillFormPage extends StatefulWidget {
  const SkillFormPage({super.key, this.skill});

  /// Skill yang diubah; `null` berarti form membuat skill baru.
  final Skill? skill;

  @override
  State<SkillFormPage> createState() => _SkillFormPageState();
}

class _SkillFormPageState extends State<SkillFormPage> {
  // Batas panjang mengikuti model Skill di Django.
  static const int _nameMaxLength = 100;
  static const int _urlMaxLength = 200;
  static const int _categoryMaxLength = 50;

  // Kunci untuk mengakses state Form (validasi dan reset).
  final _formKey = GlobalKey<FormState>();

  // Pada mode ubah, kolom terisi data skill. `reset()` hanya dipakai pada mode
  // tambah, jadi nilai awal ini tidak ikut terhapus.
  late final _nameController = TextEditingController(text: widget.skill?.name);
  late final _iconUrlController = TextEditingController(
    text: widget.skill?.iconUrl,
  );
  late final _categoryController = TextEditingController(
    text: widget.skill?.category,
  );

  bool _isSubmitting = false;

  bool get _isEditing => widget.skill != null;

  @override
  void dispose() {
    _nameController.dispose();
    _iconUrlController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  /// Menyusun [Skill] dari isian saat ini (hanya dipanggil setelah validasi).
  Skill _buildSkill() {
    return Skill(
      // id hanya ada pada mode ubah; ia menentukan alamat PATCH, bukan isi body.
      id: widget.skill?.id,
      name: _nameController.text.trim(),
      iconUrl: _iconUrlController.text.trim(),
      category: _categoryController.text.trim(),
    );
  }

  /// Menangani tombol Save.
  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Diambil sebelum await: context tidak boleh dipakai sesudahnya tanpa
    // memeriksa `mounted`.
    final api = context.read<ApiClient>();
    final auth = context.read<AuthState>();

    // Token bisa saja sudah dihapus sejak form dibuka (logout dari drawer).
    if (!await ensureLoggedIn(context)) {
      return;
    }
    final token = auth.token;
    if (!mounted || token == null) {
      return;
    }

    setState(() => _isSubmitting = true);

    Skill? saved;
    ApiException? failure;
    try {
      final skill = _buildSkill();
      saved = _isEditing
          ? await api.updateSkill(skill, token: token)
          : await api.createSkill(skill, token: token);
    } on ApiException catch (error) {
      failure = error;
    } finally {
      // Spinner berhenti begitu permintaan selesai, sebelum dialog atau login
      // ulang ditampilkan; kalau tidak, ia terus berputar di belakang dialog.
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }

    if (!mounted) {
      return;
    }
    if (saved != null) {
      if (_isEditing) {
        // Pemanggil (layar detail) yang memberi kabar dan memuat ulang daftar.
        Navigator.pop(context, saved);
      } else {
        await _showCreatedDialog(saved);
      }
    } else if (failure != null) {
      // Pada 401 sesi dihapus dan login diminta ulang; isian form tetap ada.
      await handleApiFailure(
        context,
        failure,
        retryHint: 'Login berhasil. Tekan Save sekali lagi untuk mengirim.',
      );
    }
  }

  /// Dialog sukses: tambah lagi (form dikosongkan) atau lihat daftar.
  Future<void> _showCreatedDialog(Skill created) async {
    final viewList = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Skill berhasil ditambahkan!'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Nama Skill: ${created.name}'),
              Text('URL Ikon: ${created.iconUrl}'),
              Text('Kategori: ${created.category}'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Tambah Lagi'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Lihat Daftar'),
          ),
        ],
      ),
    );

    if (!mounted) {
      return;
    }

    if (viewList ?? false) {
      // Halaman daftar baru memuat ulang dari server sehingga skill yang baru
      // dibuat sudah ada di dalamnya.
      await Navigator.pushReplacement(
        context,
        MaterialPageRoute<void>(builder: (_) => const SkillListPage()),
      );
    } else {
      _formKey.currentState!.reset();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Warna AppBar mengikuti AppBarTheme di MyApp.
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Skill Form' : 'Add Skill Form'),
      ),
      // Form ubah dibuka di atas layar detail; ia punya tombol kembali, bukan
      // drawer, supaya pengguna tidak "pindah halaman" di tengah penyuntingan.
      drawer: _isEditing
          ? null
          : const LeftDrawer(selected: DrawerDestination.addSkill),
      body: SafeArea(
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.all(16),
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Form(
                key: _formKey,
                // Pesan kesalahan ikut diperbarui setelah pengguna berinteraksi.
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: 16,
                  children: [
                    // === Name ===
                    AppTextFormField(
                      controller: _nameController,
                      label: 'Nama Skill',
                      hint: 'Contoh: Flutter',
                      maxLength: _nameMaxLength,
                      textCapitalization: TextCapitalization.words,
                      validator: (value) => validateRequired(
                        value,
                        'Nama skill',
                        maxLength: _nameMaxLength,
                      ),
                    ),

                    // === Icon URL (wajib di Django) ===
                    AppTextFormField(
                      controller: _iconUrlController,
                      label: 'URL Ikon',
                      hint: 'https://...',
                      keyboardType: TextInputType.url,
                      validator: (value) => validateRequiredUrl(
                        value,
                        'URL ikon',
                        maxLength: _urlMaxLength,
                      ),
                    ),

                    // === Category (opsional) ===
                    AppTextFormField(
                      controller: _categoryController,
                      label: 'Kategori (opsional)',
                      hint: 'Contoh: Framework, Language, Tool',
                      maxLength: _categoryMaxLength,
                      textCapitalization: TextCapitalization.words,
                      validator: (value) => validateMaxLength(
                        value,
                        'Kategori',
                        _categoryMaxLength,
                      ),
                    ),

                    // === Tombol Simpan ===
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: _isSubmitting ? null : _submit,
                      child: _isSubmitting
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Save'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
