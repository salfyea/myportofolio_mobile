/// Model data untuk bagian **Experience** pada portofolio.
///
/// Berkas ini hanya berisi data murni (tanpa widget) sehingga bisa dipakai oleh
/// formulir, dialog ringkasan, maupun test tanpa menarik dependensi UI.
library;

/// Jenis hubungan kerja pada sebuah [Experience].
///
/// Tiap nilai membawa [label] berbahasa Indonesia yang dipakai langsung oleh
/// dropdown dan dialog ringkasan, sehingga teks tampilan tidak tersebar di
/// banyak tempat.
enum EmploymentType {
  fullTime('Penuh Waktu'),
  partTime('Paruh Waktu'),
  internship('Magang'),
  freelance('Freelance'),
  volunteer('Sukarelawan');

  const EmploymentType(this.label);

  /// Nama yang ditampilkan kepada pengguna.
  final String label;
}

/// Satu pengalaman kerja, magang, atau kegiatan pada portofolio.
///
/// Semua teks diasumsikan sudah dipangkas (`trim`) oleh pembuatnya; validasi
/// isian dilakukan lebih dulu oleh fungsi di `utils/validators.dart`.
class Experience {
  const Experience({
    required this.position,
    required this.company,
    required this.employmentType,
    required this.startDate,
    required this.description,
    this.endDate,
    this.link = '',
  });

  /// Jabatan atau peran, misalnya `"Frontend Developer Intern"`.
  final String position;

  /// Nama perusahaan atau organisasi tempat pengalaman itu terjadi.
  final String company;

  /// Jenis hubungan kerja.
  final EmploymentType employmentType;

  /// Tanggal mulai.
  final DateTime startDate;

  /// Tanggal selesai. `null` berarti pengalaman ini masih berlangsung.
  ///
  /// Status "masih berlangsung" sengaja diturunkan dari nilai ini ([isOngoing])
  /// dan tidak disimpan sebagai boolean terpisah, supaya kedua informasi itu
  /// tidak pernah bisa saling bertentangan.
  final DateTime? endDate;

  /// Uraian singkat tugas dan pencapaian.
  final String description;

  /// Tautan pendukung (opsional); string kosong berarti tidak ada.
  final String link;

  /// Apakah pengalaman ini masih berlangsung (belum ada tanggal selesai).
  bool get isOngoing => endDate == null;
}
