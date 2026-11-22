import 'package:flutter/services.dart' show MaxLengthEnforcement;
import 'package:material_ui/material_ui.dart';

/// Kolom teks formulir dengan tampilan seragam di seluruh aplikasi.
///
/// Membungkus [TextFormField] dengan border bersudut, label, dan hint yang
/// sama, sehingga halaman formulir cukup menyebutkan hal yang berbeda
/// (label, aturan [validator], dan jenis papan ketik) tanpa mengulang blok
/// dekorasi yang panjang.
///
/// Widget ini **tidak** mengetahui aturan validasi apa pun; aturan diberikan
/// pemanggil lewat [validator] (biasanya fungsi dari `utils/validators.dart`).
class AppTextFormField extends StatelessWidget {
  const AppTextFormField({
    super.key,
    required this.controller,
    required this.label,
    this.hint,
    this.validator,
    this.maxLines = 1,
    this.maxLength,
    this.keyboardType,
    this.textCapitalization = TextCapitalization.none,
  });

  /// Pengendali isi kolom; dimiliki dan di-`dispose` oleh halaman pemanggil.
  final TextEditingController controller;

  /// Label yang melayang di atas kolom saat diisi.
  final String label;

  /// Contoh isian yang tampil samar saat kolom kosong dan sedang difokuskan.
  final String? hint;

  /// Aturan validasi: mengembalikan pesan kesalahan, atau `null` jika valid.
  final FormFieldValidator<String>? validator;

  /// Jumlah baris tampilan; nilai lebih dari 1 membuat kolom bersifat multibaris.
  final int maxLines;

  /// Batas karakter yang **hanya ditampilkan** sebagai penghitung (`12/200`).
  ///
  /// Ketikan sengaja tidak diblokir saat melebihi batas: penghitung berubah
  /// merah dan penolakan dilakukan oleh [validator] saat tombol Simpan
  /// ditekan. Dengan begitu pengguna tahu seberapa banyak yang harus dipangkas
  /// dan teks yang ditempel tidak terpotong diam-diam.
  final int? maxLength;

  /// Jenis papan ketik. Bila kosong, dipilih otomatis: multibaris atau teks.
  final TextInputType? keyboardType;

  /// Aturan huruf kapital otomatis (mis. [TextCapitalization.words] untuk nama).
  final TextCapitalization textCapitalization;

  @override
  Widget build(BuildContext context) {
    final isMultiline = maxLines > 1;

    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      maxLength: maxLength,
      maxLengthEnforcement: MaxLengthEnforcement.none,
      keyboardType:
          keyboardType ?? (isMultiline ? TextInputType.multiline : TextInputType.text),
      // Kolom satu baris pindah ke kolom berikutnya; multibaris menerima Enter.
      textInputAction:
          isMultiline ? TextInputAction.newline : TextInputAction.next,
      textCapitalization: textCapitalization,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        alignLabelWithHint: isMultiline,
        // Pesan kesalahan boleh turun ke baris berikutnya. Tanpa ini, pesan
        // panjang dipotong "..." pada layar ponsel (ditemukan saat uji manual
        // di lebar 360 px) sehingga petunjuk di ujung kalimat tidak terbaca.
        errorMaxLines: 3,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(5.0)),
      ),
      validator: validator,
    );
  }
}
