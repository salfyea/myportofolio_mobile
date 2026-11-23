import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/models/experience.dart';
import 'package:myportofolio_mobile/utils/formatters.dart';

/// Dialog yang merangkum seluruh isian sebuah [Experience].
///
/// Hanya bertugas menampilkan data (tanpa logika form), sehingga halaman
/// formulir cukup membuatnya setelah semua input lolos validasi. Durasi untuk
/// pengalaman yang masih berlangsung dihitung sampai [now].
class ExperienceSummaryDialog extends StatelessWidget {
  const ExperienceSummaryDialog({
    super.key,
    required this.experience,
    this.now,
  });

  /// Data yang diringkas.
  final Experience experience;

  /// Acuan "sekarang" untuk durasi pengalaman yang masih berlangsung.
  /// Bila kosong dipakai `DateTime.now()`; parameter ini ada demi pengujian.
  final DateTime? now;

  @override
  Widget build(BuildContext context) {
    final end = experience.endDate;
    final period =
        '${formatDate(experience.startDate)} - '
        '${end == null ? 'Sekarang' : formatDate(end)}';
    final duration = formatDuration(
      experience.startDate,
      end ?? now ?? DateTime.now(),
    );

    return AlertDialog(
      icon: Icon(
        Icons.check_circle_outline,
        color: Theme.of(context).colorScheme.primary,
        size: 40,
      ),
      title: const Text('Ringkasan Pengalaman'),
      // Konten bisa di-scroll agar uraian panjang tidak overflow di layar kecil.
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 12,
            children: [
              _SummaryRow(label: 'Posisi', value: experience.position),
              _SummaryRow(label: 'Perusahaan', value: experience.company),
              _SummaryRow(
                label: 'Jenis',
                value: experience.employmentType.label,
              ),
              _SummaryRow(label: 'Periode', value: period),
              _SummaryRow(label: 'Durasi', value: duration),
              _SummaryRow(label: 'Deskripsi', value: experience.description),
              if (experience.link.isNotEmpty)
                _SummaryRow(label: 'Tautan', value: experience.link),
              Text(
                'Catatan: data belum disimpan ke database.',
                style: Theme.of(context).textTheme.bodySmall
                    ?.copyWith(fontStyle: FontStyle.italic),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Tutup'),
        ),
      ],
    );
  }
}

/// Sepasang label kecil dan nilainya, disusun vertikal.
class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: textTheme.labelMedium?.copyWith(
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(value, style: textTheme.bodyLarge),
      ],
    );
  }
}
