import 'package:flutter_svg/flutter_svg.dart';
import 'package:material_ui/material_ui.dart';

/// Gambar dari URL, dengan penanda saat memuat dan saat gagal.
///
/// URL berasal dari data pengguna, jadi bisa salah atau tidak terjangkau.
/// Keduanya tidak boleh merusak halaman: yang tampil hanya ikon gambar rusak
/// seukuran gambar, sehingga tata letak di sekitarnya tidak bergeser.
///
/// **Format.** `Image.network` hanya memahami gambar raster, sedangkan ikon
/// skill di backend umumnya SVG (mis. `https://cdn.simpleicons.org/django`).
/// Karena itu format dipilih dari URL-nya:
///
/// - ekstensi `.svg`: langsung digambar sebagai SVG;
/// - ekstensi raster (`.png`, `.jpg`, ...): digambar sebagai gambar biasa;
/// - tanpa ekstensi atau ekstensi lain: dicoba sebagai gambar biasa lebih
///   dulu, lalu sebagai SVG bila gagal. Itu kasus `cdn.simpleicons.org/django`,
///   yang tidak punya ekstensi tetapi menyajikan `image/svg+xml`.
class RemoteImage extends StatelessWidget {
  const RemoteImage({
    super.key,
    required this.url,
    required this.semanticLabel,
    this.height = 200,
    this.width,
    this.fit = BoxFit.cover,
  });

  /// Ekstensi yang pasti raster, sehingga tidak perlu dicoba sebagai SVG.
  static const Set<String> _rasterExtensions = {
    'png',
    'jpg',
    'jpeg',
    'gif',
    'webp',
    'bmp',
    'avif',
  };

  final String url;

  /// Deskripsi gambar untuk pembaca layar.
  final String semanticLabel;

  final double height;

  /// Bila kosong, gambar memakai lebar yang tersedia.
  final double? width;

  final BoxFit fit;

  /// Ekstensi berkas pada path URL (huruf kecil), atau string kosong. Query
  /// string seperti `?v=2` tidak ikut dihitung.
  static String _extensionOf(String url) {
    final path = Uri.tryParse(url)?.path.toLowerCase() ?? '';
    final name = path.split('/').last;
    final dot = name.lastIndexOf('.');
    return dot < 0 ? '' : name.substring(dot + 1);
  }

  @override
  Widget build(BuildContext context) {
    final extension = _extensionOf(url);

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: extension == 'svg'
          ? _svg()
          : _raster(trySvgOnError: !_rasterExtensions.contains(extension)),
    );
  }

  Widget _raster({required bool trySvgOnError}) {
    return Image.network(
      url,
      height: height,
      width: width,
      fit: fit,
      semanticLabel: semanticLabel,
      loadingBuilder: (context, child, progress) =>
          progress == null ? child : _loading(),
      errorBuilder: (context, error, stackTrace) =>
          trySvgOnError ? _svg() : _broken(),
    );
  }

  Widget _svg() {
    return SvgPicture.network(
      url,
      height: height,
      width: width,
      fit: fit,
      semanticsLabel: semanticLabel,
      placeholderBuilder: (context) => _loading(),
      errorBuilder: (context, error, stackTrace) => _broken(),
    );
  }

  Widget _loading() => SizedBox(
    height: height,
    width: width,
    child: const Center(child: CircularProgressIndicator()),
  );

  Widget _broken() {
    // Ikon galat ikut mengecil pada gambar kecil, tetapi tetap terbaca.
    final iconSize = (height * 0.24).clamp(24.0, 48.0);

    return SizedBox(
      height: height,
      width: width,
      child: Center(child: Icon(Icons.broken_image_outlined, size: iconSize)),
    );
  }
}
