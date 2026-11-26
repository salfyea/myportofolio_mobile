import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/models/project.dart';
import 'package:myportofolio_mobile/screens/project_list.dart';
import 'package:myportofolio_mobile/services/api_client.dart';
import 'package:myportofolio_mobile/services/auth_state.dart';
import 'package:myportofolio_mobile/utils/validators.dart';
import 'package:myportofolio_mobile/widgets/app_text_form_field.dart';
import 'package:myportofolio_mobile/widgets/auth_guard.dart';
import 'package:myportofolio_mobile/widgets/left_drawer.dart';
import 'package:provider/provider.dart';

/// Halaman form untuk menambahkan proyek baru ke portofolio lewat API Django.
///
/// Alur **Save**: validasi form, pastikan pengguna login (`ensureLoggedIn`),
/// lalu kirim `POST /api/v1/projects/` dengan token dari `AuthState`.
///
/// - Berhasil (201): dialog konfirmasi dengan pilihan **Tambah Lagi** atau
///   **Lihat Daftar**. Daftar dimuat ulang dari server, jadi proyek baru
///   langsung tampil di sana.
/// - 401 (token dicabut atau tidak berlaku): sesi lokal dihapus dan pengguna
///   diminta login ulang; isian form tetap ada.
/// - Galat lain (403 bukan pemilik, 400 validasi server, jaringan): SnackBar.
///
/// Kolom mengikuti `ProjectSerializer` di Django: title, description,
/// category, link, dan project_image_url.
class ProjectFormPage extends StatefulWidget {
  const ProjectFormPage({super.key});

  @override
  State<ProjectFormPage> createState() => _ProjectFormPageState();
}

class _ProjectFormPageState extends State<ProjectFormPage> {
  // Batas panjang mengikuti model Project di Django.
  static const int _titleMaxLength = 200;
  static const int _categoryMaxLength = 100;
  static const int _urlMaxLength = 200;

  static const List<String> _categories = [
    'Web Development',
    'Mobile Development',
    'Machine Learning',
    'Data Science',
    'Other',
  ];

  // Kunci untuk mengakses state Form (validasi dan reset).
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _linkController = TextEditingController();
  final _imageUrlController = TextEditingController();

  // Nilai awal dropdown harus konstanta: reset() mengembalikan dropdown ke
  // initialValue, bukan ke pilihan terakhir.
  String _category = _categories.first;

  bool _isSubmitting = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _linkController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  /// Menyusun [Project] dari isian saat ini (hanya dipanggil setelah validasi).
  Project _buildProject() {
    return Project(
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      category: _category,
      link: _linkController.text.trim(),
      projectImageUrl: _imageUrlController.text.trim(),
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

    Project? created;
    ApiException? failure;
    try {
      created = await api.createProject(_buildProject(), token: token);
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
    if (created != null) {
      await _showCreatedDialog(created);
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
  Future<void> _showCreatedDialog(Project created) async {
    final viewList = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Proyek berhasil ditambahkan!'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Nama Proyek: ${created.title}'),
              Text('Deskripsi: ${created.description}'),
              Text('Kategori: ${created.category}'),
              Text('Tautan: ${created.link}'),
              Text('Gambar: ${created.projectImageUrl}'),
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
      // Halaman daftar baru memuat ulang dari server sehingga proyek yang baru
      // dibuat sudah ada di dalamnya.
      await Navigator.pushReplacement(
        context,
        MaterialPageRoute<void>(builder: (_) => const ProjectListPage()),
      );
    } else {
      _resetForm();
    }
  }

  /// Mengosongkan seluruh isian dan mengembalikan nilai awal.
  void _resetForm() {
    _formKey.currentState!.reset();
    // reset() mengosongkan tampilan kolom, tetapi variabel state yang tidak
    // dikelola Form dikembalikan manual.
    setState(() => _category = _categories.first);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Warna AppBar mengikuti AppBarTheme di MyApp.
      appBar: AppBar(title: const Center(child: Text('Add Project Form'))),
      drawer: const LeftDrawer(selected: DrawerDestination.addProject),
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
                    // === Title ===
                    AppTextFormField(
                      controller: _titleController,
                      label: 'Nama Proyek',
                      hint: 'Nama Proyek',
                      maxLength: _titleMaxLength,
                      textCapitalization: TextCapitalization.words,
                      validator: (value) => validateRequired(
                        value,
                        'Nama proyek',
                        maxLength: _titleMaxLength,
                      ),
                    ),

                    // === Description ===
                    AppTextFormField(
                      controller: _descriptionController,
                      label: 'Deskripsi Proyek',
                      hint: 'Deskripsi Proyek',
                      maxLines: 5,
                      textCapitalization: TextCapitalization.sentences,
                      validator: (value) =>
                          validateRequired(value, 'Deskripsi proyek'),
                    ),

                    // === Category ===
                    DropdownButtonFormField<String>(
                      isExpanded: true,
                      decoration: InputDecoration(
                        labelText: 'Kategori Proyek',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5.0),
                        ),
                      ),
                      initialValue: _categories.first,
                      items: _categories
                          .map(
                            (category) => DropdownMenuItem(
                              value: category,
                              child: Text(category),
                            ),
                          )
                          .toList(),
                      validator: (value) => validateMaxLength(
                        value,
                        'Kategori',
                        _categoryMaxLength,
                      ),
                      onChanged: (value) => setState(() => _category = value!),
                    ),

                    // === Project Link (opsional) ===
                    AppTextFormField(
                      controller: _linkController,
                      label: 'Tautan Proyek',
                      hint: 'URL Proyek (opsional)',
                      keyboardType: TextInputType.url,
                      // Opsional, tetapi jika diisi harus berupa URL http/https.
                      validator: (value) => validateOptionalUrl(
                        value,
                        'Tautan proyek',
                        maxLength: _urlMaxLength,
                      ),
                    ),

                    // === Project Image URL (opsional) ===
                    AppTextFormField(
                      controller: _imageUrlController,
                      label: 'URL Gambar Proyek',
                      hint: 'https://... (opsional)',
                      keyboardType: TextInputType.url,
                      validator: (value) => validateOptionalUrl(
                        value,
                        'URL gambar',
                        maxLength: _urlMaxLength,
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
