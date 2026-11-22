import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/models/experience.dart';
import 'package:myportofolio_mobile/utils/validators.dart';
import 'package:myportofolio_mobile/widgets/app_text_form_field.dart';
import 'package:myportofolio_mobile/widgets/date_form_field.dart';
import 'package:myportofolio_mobile/widgets/experience_summary_dialog.dart';
import 'package:myportofolio_mobile/widgets/left_drawer.dart';

/// Halaman formulir untuk menambahkan sebuah [Experience] ke portofolio.
///
/// Alur: pengguna mengisi kolom, menekan **Simpan**, lalu `FormState.validate()`
/// memeriksa semua kolom sekaligus. Jika ada yang tidak valid, pesan kesalahan
/// tampil di kolom terkait dan halaman menggulir ke kolom pertama yang salah.
/// Jika semuanya valid, ringkasan isian tampil di [ExperienceSummaryDialog];
/// setelah dialog ditutup, formulir dikosongkan untuk isian berikutnya.
///
/// Data belum disimpan ke database. Aturan validasi tidak ditulis di sini,
/// melainkan dipanggil dari `utils/validators.dart`.
class ExperienceFormPage extends StatefulWidget {
  const ExperienceFormPage({super.key});

  @override
  State<ExperienceFormPage> createState() => _ExperienceFormPageState();
}

class _ExperienceFormPageState extends State<ExperienceFormPage> {
  // Batas panjang isian.
  static const int _positionMaxLength = 100;
  static const int _companyMaxLength = 100;
  static const int _descriptionMaxLength = 1000;
  static const int _linkMaxLength = 200;

  /// Nilai awal dropdown. Harus konstanta: `reset()` mengembalikan dropdown
  /// ke `initialValue`, jadi memberinya variabel state akan membuat reset
  /// "kembali" ke pilihan terakhir.
  static const EmploymentType _defaultEmploymentType = EmploymentType.fullTime;

  /// Tanggal paling awal yang bisa dipilih pada date picker.
  static final DateTime _earliestDate = DateTime(1970);

  // Kunci untuk mengakses state Form (validasi dan reset).
  final _formKey = GlobalKey<FormState>();

  // Kunci kolom tanggal selesai: dipakai untuk memvalidasi ulang atau
  // mengosongkannya ketika tanggal mulai / status "masih berlangsung" berubah.
  final _endDateKey = GlobalKey<FormFieldState<DateTime>>();

  // Kolom teks memakai controller (di-dispose di bawah); sisanya memakai state.
  final _positionController = TextEditingController();
  final _companyController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _linkController = TextEditingController();

  EmploymentType _employmentType = _defaultEmploymentType;
  DateTime? _startDate;
  DateTime? _endDate;
  bool _isOngoing = false;

  @override
  void dispose() {
    _positionController.dispose();
    _companyController.dispose();
    _descriptionController.dispose();
    _linkController.dispose();
    super.dispose();
  }

  /// Menyusun [Experience] dari isian saat ini. Hanya dipanggil setelah
  /// validasi lolos, sehingga tanggal mulai dipastikan tidak null.
  Experience _buildExperience() {
    return Experience(
      position: _positionController.text.trim(),
      company: _companyController.text.trim(),
      employmentType: _employmentType,
      startDate: _startDate!,
      // Pengalaman yang masih berlangsung tidak punya tanggal selesai.
      endDate: _isOngoing ? null : _endDate,
      description: _descriptionController.text.trim(),
      link: _linkController.text.trim(),
    );
  }

  /// Menangani tombol Simpan.
  Future<void> _submit() async {
    final form = _formKey.currentState!;

    if (!form.validate()) {
      _revealFirstError(form);
      return;
    }

    await showDialog<void>(
      context: context,
      builder: (_) => ExperienceSummaryDialog(experience: _buildExperience()),
    );

    // Layar bisa saja sudah ditutup selama dialog terbuka.
    if (!mounted) return;
    _resetForm();
  }

  /// Menggulir halaman ke kolom pertama yang tidak valid.
  ///
  /// Pada layar sempit, kolom yang salah bisa berada di luar layar sehingga
  /// pengguna menekan Simpan tanpa melihat apa pun berubah.
  void _revealFirstError(FormState form) {
    final invalidFields = form.validateGranularly();
    if (invalidFields.isEmpty) return;

    Scrollable.ensureVisible(
      invalidFields.first.context,
      alignment: 0.1,
      duration: const Duration(milliseconds: 250),
    );
  }

  /// Mengosongkan seluruh isian dan mengembalikan nilai awal.
  ///
  /// `reset()` sudah mengosongkan kolom teks, tanggal, dan dropdown; variabel
  /// state yang tidak dikelola [Form] dikembalikan secara manual.
  void _resetForm() {
    _formKey.currentState!.reset();
    setState(() {
      _employmentType = _defaultEmploymentType;
      _startDate = null;
      _endDate = null;
      _isOngoing = false;
    });
  }

  /// Menangani perubahan tanggal mulai.
  void _onStartDateChanged(DateTime? date) {
    setState(() => _startDate = date);

    // Urutan tanggal bisa berubah menjadi salah; tampilkan pesannya segera.
    if (_endDate != null) {
      _endDateKey.currentState?.validate();
    }
  }

  /// Menangani sakelar "Masih berlangsung".
  void _onOngoingChanged(bool value) {
    setState(() {
      _isOngoing = value;
      if (value) _endDate = null;
    });

    // Tanggal selesai tidak berlaku lagi: kosongkan beserta pesan kesalahannya.
    if (value) _endDateKey.currentState?.reset();
  }

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();

    return Scaffold(
      // Warna AppBar mengikuti AppBarTheme di MyApp.
      appBar: AppBar(title: const Text('Add Experience Form')),
      drawer: const LeftDrawer(selected: DrawerDestination.addExperience),
      // SafeArea + SingleChildScrollView: semua kolom dan tombol Simpan tetap
      // terjangkau di layar sempit, dan Scaffold otomatis mengecilkan body saat
      // papan ketik tampil sehingga isi bisa digulir di atasnya.
      body: SafeArea(
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.all(16),
          // Batasi lebar agar formulir tidak melebar di layar lebar (Chrome).
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Form(
                key: _formKey,
                // Pesan kesalahan ikut diperbarui saat pengguna mengubah isian
                // setelah pertama kali berinteraksi dengan kolom itu.
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: 16,
                  children: [
                    // === Posisi ===
                    AppTextFormField(
                      controller: _positionController,
                      label: 'Posisi / Jabatan',
                      hint: 'Contoh: Frontend Developer Intern',
                      textCapitalization: TextCapitalization.words,
                      validator: (value) => validateRequired(
                        value,
                        'Posisi',
                        maxLength: _positionMaxLength,
                      ),
                    ),

                    // === Perusahaan ===
                    AppTextFormField(
                      controller: _companyController,
                      label: 'Perusahaan / Organisasi',
                      hint: 'Contoh: PT Teknologi Nusantara',
                      textCapitalization: TextCapitalization.words,
                      validator: (value) => validateRequired(
                        value,
                        'Perusahaan',
                        maxLength: _companyMaxLength,
                      ),
                    ),

                    // === Jenis pekerjaan ===
                    DropdownButtonFormField<EmploymentType>(
                      isExpanded: true,
                      decoration: InputDecoration(
                        labelText: 'Jenis Pekerjaan',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5.0),
                        ),
                      ),
                      initialValue: _defaultEmploymentType,
                      items: EmploymentType.values
                          .map(
                            (type) => DropdownMenuItem(
                              value: type,
                              child: Text(type.label),
                            ),
                          )
                          .toList(),
                      onChanged: (value) =>
                          setState(() => _employmentType = value!),
                    ),

                    // === Tanggal mulai ===
                    DateFormField(
                      label: 'Tanggal Mulai',
                      firstDate: _earliestDate,
                      lastDate: today,
                      onChanged: _onStartDateChanged,
                      validator: (date) => validateRequiredDate(
                        date,
                        'Tanggal mulai',
                        allowFuture: false,
                      ),
                    ),

                    // === Masih berlangsung ===
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Masih berlangsung'),
                      subtitle: const Text(
                        'Aktifkan jika posisi ini belum selesai',
                      ),
                      value: _isOngoing,
                      onChanged: _onOngoingChanged,
                    ),

                    // === Tanggal selesai ===
                    DateFormField(
                      key: _endDateKey,
                      label: 'Tanggal Selesai',
                      // Tanggal selesai tidak bisa dipilih sebelum tanggal mulai.
                      firstDate: _startDate ?? _earliestDate,
                      lastDate: DateTime(today.year + 10),
                      pickerStartDate: _startDate,
                      enabled: !_isOngoing,
                      onChanged: (date) => setState(() => _endDate = date),
                      validator: (date) => validateEndDate(
                        _startDate,
                        date,
                        isOngoing: _isOngoing,
                      ),
                    ),

                    // === Deskripsi ===
                    AppTextFormField(
                      controller: _descriptionController,
                      label: 'Deskripsi',
                      hint: 'Tugas utama dan pencapaianmu',
                      maxLines: 5,
                      maxLength: _descriptionMaxLength,
                      textCapitalization: TextCapitalization.sentences,
                      validator: (value) => validateRequired(
                        value,
                        'Deskripsi',
                        maxLength: _descriptionMaxLength,
                      ),
                    ),

                    // === Tautan (opsional) ===
                    AppTextFormField(
                      controller: _linkController,
                      label: 'Tautan Pendukung (opsional)',
                      hint: 'https://...',
                      keyboardType: TextInputType.url,
                      validator: (value) => validateOptionalUrl(
                        value,
                        'Tautan',
                        maxLength: _linkMaxLength,
                      ),
                    ),

                    // === Tombol aksi ===
                    Row(
                      spacing: 12,
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _resetForm,
                            child: const Text('Reset'),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: FilledButton.icon(
                            onPressed: _submit,
                            icon: const Icon(Icons.save),
                            label: const Text('Simpan'),
                          ),
                        ),
                      ],
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
