/// Fungsi pemformat tampilan (tanggal, durasi, dan bintang) berbahasa Indonesia.
///
/// Ditulis manual tanpa paket `intl` agar tidak menambah dependensi hanya untuk
/// beberapa format sederhana. Semua fungsi murni sehingga mudah diuji.
library;

const List<String> _monthNames = [
  'Januari',
  'Februari',
  'Maret',
  'April',
  'Mei',
  'Juni',
  'Juli',
  'Agustus',
  'September',
  'Oktober',
  'November',
  'Desember',
];

/// Meringkas data bintang dari API menjadi satu kalimat, misalnya
/// `"3 bintang, diberikan oleh owner, visitor"`.
///
/// [names] adalah nama pengguna pemberi bintang yang dipisah koma; bila kosong,
/// hanya jumlahnya ([count]) yang ditampilkan.
String formatStarSummary(int count, String names) {
  final total = '$count bintang';
  return names.isEmpty ? total : '$total, diberikan oleh $names';
}

/// Memformat [date] menjadi teks seperti `"5 Januari 2025"`.
String formatDate(DateTime date) =>
    '${date.day} ${_monthNames[date.month - 1]} ${date.year}';

/// Menyatakan selisih [start] sampai [end] sebagai teks, misalnya
/// `"1 tahun 3 bulan"`.
///
/// Yang dihitung adalah **bulan penuh**: satu bulan baru dihitung bila hari
/// pada [end] sudah mencapai (atau melewati) hari pada [start]. Selisih kurang
/// dari satu bulan, juga [end] yang lebih awal dari [start], dinyatakan sebagai
/// `"Kurang dari 1 bulan"`.
String formatDuration(DateTime start, DateTime end) {
  var months = (end.year - start.year) * 12 + (end.month - start.month);
  if (end.day < start.day) {
    months -= 1;
  }

  if (months < 1) {
    return 'Kurang dari 1 bulan';
  }

  final years = months ~/ 12;
  final remainingMonths = months % 12;

  return [
    if (years > 0) '$years tahun',
    if (remainingMonths > 0) '$remainingMonths bulan',
  ].join(' ');
}
