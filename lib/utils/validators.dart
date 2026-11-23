/// Kumpulan fungsi validasi murni untuk input formulir.
///
/// Setiap fungsi mengembalikan pesan kesalahan (`String`) jika input ditolak,
/// atau `null` jika input valid. Bentuk ini sama dengan yang diharapkan
/// parameter `validator` pada `TextFormField`, sehingga dapat dipasang
/// langsung. Karena tidak bergantung pada widget, fungsi-fungsi ini mudah diuji
/// dan dipakai ulang oleh semua halaman formulir.
library;

/// Menolak isian yang kosong atau hanya berisi spasi, dan (opsional) yang
/// melebihi [maxLength] karakter.
///
/// [label] adalah nama kolom yang disebut pada pesan kesalahan, misalnya
/// `"Nama proyek"`. Spasi di awal dan akhir diabaikan saat memeriksa panjang.
String? validateRequired(String? value, String label, {int? maxLength}) {
  final text = value?.trim() ?? '';

  if (text.isEmpty) {
    return '$label tidak boleh kosong!';
  }

  return validateMaxLength(text, label, maxLength);
}

/// Menolak isian yang lebih panjang dari [maxLength] karakter.
///
/// Mengembalikan `null` jika [maxLength] tidak ditentukan atau isian masih
/// dalam batas. Tidak mewajibkan isian, jadi aman dipakai pada kolom opsional.
String? validateMaxLength(String? value, String label, int? maxLength) {
  if (maxLength == null) {
    return null;
  }

  final text = value?.trim() ?? '';

  if (text.length > maxLength) {
    return '$label terlalu panjang (maksimal $maxLength karakter).';
  }

  return null;
}

/// Memeriksa kolom URL yang bersifat opsional.
///
/// Isian kosong dianggap valid. Jika diisi, harus berupa URL `http` atau
/// `https` dengan nama host, tanpa spasi, dan tidak lebih panjang dari
/// [maxLength] karakter bila ditentukan. Contoh yang ditolak: `"abc"`,
/// `"ftp://situs.com"`, dan `"http://"`.
String? validateOptionalUrl(String? value, String label, {int? maxLength}) {
  final text = value?.trim() ?? '';

  if (text.isEmpty) {
    return null;
  }

  final tooLong = validateMaxLength(text, label, maxLength);
  if (tooLong != null) {
    return tooLong;
  }

  final uri = Uri.tryParse(text);
  final isWebScheme =
      uri != null && (uri.scheme == 'http' || uri.scheme == 'https');
  final hasHost = uri != null && uri.host.isNotEmpty;

  if (text.contains(RegExp(r'\s')) || !isWebScheme || !hasHost) {
    return '$label tidak valid. Gunakan format http:// atau https://.';
  }

  return null;
}

/// Mewajibkan sebuah tanggal dipilih, dan (opsional) melarang tanggal di masa
/// depan.
///
/// Dipakai untuk kolom tanggal yang wajib diisi, misalnya tanggal mulai.
/// Jika [allowFuture] bernilai `false`, tanggal setelah hari ini ditolak;
/// hanya tanggalnya yang dibandingkan, jam diabaikan. Parameter [now] ada agar
/// "hari ini" bisa ditetapkan saat pengujian.
String? validateRequiredDate(
  DateTime? value,
  String label, {
  bool allowFuture = true,
  DateTime? now,
}) {
  if (value == null) {
    return '$label wajib dipilih!';
  }

  if (!allowFuture) {
    final reference = now ?? DateTime.now();
    final today = DateTime(reference.year, reference.month, reference.day);
    final day = DateTime(value.year, value.month, value.day);

    if (day.isAfter(today)) {
      return '$label tidak boleh di masa depan.';
    }
  }

  return null;
}

/// Memeriksa tanggal selesai pada pasangan tanggal mulai-selesai.
///
/// - Jika [isOngoing] `true` (kegiatan masih berjalan), tanggal selesai tidak
///   diperlukan sehingga selalu valid.
/// - Jika tidak, tanggal selesai wajib diisi dan tidak boleh lebih awal dari
///   [start] (lihat [validateDateOrder]).
String? validateEndDate(
  DateTime? start,
  DateTime? end, {
  required bool isOngoing,
}) {
  if (isOngoing) {
    return null;
  }

  if (end == null) {
    return 'Tanggal selesai wajib dipilih, atau aktifkan "Masih berlangsung".';
  }

  return validateDateOrder(start, end);
}

/// Memeriksa urutan tanggal: [end] tidak boleh lebih awal dari [start].
///
/// Hanya tanggalnya yang dibandingkan (jam diabaikan). Jika salah satu
/// bernilai `null`, urutan belum dapat diperiksa dan dianggap valid; kewajiban
/// mengisi tanggal ditangani terpisah oleh pemanggil.
String? validateDateOrder(DateTime? start, DateTime? end) {
  if (start == null || end == null) {
    return null;
  }

  final startDay = DateTime(start.year, start.month, start.day);
  final endDay = DateTime(end.year, end.month, end.day);

  if (endDay.isBefore(startDay)) {
    return 'Tanggal selesai tidak boleh sebelum tanggal mulai.';
  }

  return null;
}
