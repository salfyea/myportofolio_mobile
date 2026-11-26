import 'package:material_ui/material_ui.dart';

/// Gambar dari URL, dengan penanda saat memuat dan saat gagal.
///
/// URL berasal dari data pengguna, jadi bisa salah atau tidak terjangkau.
/// Keduanya tidak boleh merusak halaman: yang tampil hanya ikon gambar rusak
/// seukuran gambar, sehingga tata letak di sekitarnya tidak bergeser.
class RemoteImage extends StatelessWidget {
  const RemoteImage({
    super.key,
    required this.url,
    required this.semanticLabel,
    this.height = 200,
    this.width,
    this.fit = BoxFit.cover,
  });

  final String url;

  /// Deskripsi gambar untuk pembaca layar.
  final String semanticLabel;

  final double height;

  /// Bila kosong, gambar memakai lebar yang tersedia.
  final double? width;

  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    // Ikon galat ikut mengecil pada gambar kecil, tetapi tetap terbaca.
    final iconSize = (height * 0.24).clamp(24.0, 48.0);

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.network(
        url,
        height: height,
        width: width,
        fit: fit,
        semanticLabel: semanticLabel,
        loadingBuilder: (context, child, progress) {
          if (progress == null) {
            return child;
          }
          return SizedBox(
            height: height,
            width: width,
            child: const Center(child: CircularProgressIndicator()),
          );
        },
        errorBuilder: (context, error, stackTrace) => SizedBox(
          height: height,
          width: width,
          child: Center(
            child: Icon(Icons.broken_image_outlined, size: iconSize),
          ),
        ),
      ),
    );
  }
}
