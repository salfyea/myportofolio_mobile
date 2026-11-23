import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/services/api_client.dart';

/// Pesan galat pemuatan daftar beserta tombol **Retry**.
///
/// Dipakai semua layar daftar. [subject] adalah nama data yang gagal dimuat
/// (misalnya `"proyek"`), sehingga pesannya terbaca `Gagal memuat proyek: ...`.
/// Hanya [ApiException] yang membawa pesan ramah pengguna; galat lain
/// ditampilkan sebagai pesan umum agar detail teknis tidak bocor ke layar.
class LoadErrorView extends StatelessWidget {
  const LoadErrorView({
    super.key,
    required this.subject,
    required this.error,
    required this.onRetry,
  });

  final String subject;
  final Object error;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    final failure = error;
    final message = failure is ApiException
        ? failure.message
        : 'Terjadi kesalahan tak terduga.';

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 12,
          children: [
            Text(
              'Gagal memuat $subject: $message',
              textAlign: TextAlign.center,
            ),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
