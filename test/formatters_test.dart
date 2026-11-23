// Unit test untuk pemformat di lib/utils/formatters.dart dan model Experience.

import 'package:flutter_test/flutter_test.dart';
import 'package:myportofolio_mobile/models/experience.dart';
import 'package:myportofolio_mobile/utils/formatters.dart';

void main() {
  group('formatStarSummary', () {
    test('tanpa pemberi bintang hanya menampilkan jumlahnya', () {
      expect(formatStarSummary(0, ''), '0 bintang');
    });

    test('menyebut pemberi bintang bila ada', () {
      expect(
        formatStarSummary(3, 'owner, visitor'),
        '3 bintang, diberikan oleh owner, visitor',
      );
    });
  });

  group('formatDate', () {
    test('memakai nama bulan bahasa Indonesia', () {
      expect(formatDate(DateTime(2025, 1, 5)), '5 Januari 2025');
      expect(formatDate(DateTime(2026, 8, 17)), '17 Agustus 2026');
      expect(formatDate(DateTime(2026, 12, 31)), '31 Desember 2026');
    });
  });

  group('formatDuration', () {
    test('menyatakan tahun dan bulan penuh', () {
      expect(
        formatDuration(DateTime(2024, 1, 10), DateTime(2025, 4, 10)),
        '1 tahun 3 bulan',
      );
    });

    test('hanya tahun atau hanya bulan bila sisanya nol', () {
      expect(
        formatDuration(DateTime(2023, 6, 1), DateTime(2025, 6, 1)),
        '2 tahun',
      );
      expect(
        formatDuration(DateTime(2025, 6, 1), DateTime(2025, 9, 1)),
        '3 bulan',
      );
    });

    test('bulan baru dihitung setelah hari mencapai hari mulai', () {
      expect(
        formatDuration(DateTime(2025, 1, 15), DateTime(2025, 3, 14)),
        '1 bulan',
      );
      expect(
        formatDuration(DateTime(2025, 1, 15), DateTime(2025, 3, 15)),
        '2 bulan',
      );
    });

    test('kurang dari sebulan atau urutan terbalik', () {
      expect(
        formatDuration(DateTime(2025, 5, 1), DateTime(2025, 5, 20)),
        'Kurang dari 1 bulan',
      );
      expect(
        formatDuration(DateTime(2025, 5, 20), DateTime(2025, 5, 1)),
        'Kurang dari 1 bulan',
      );
    });
  });

  group('Experience', () {
    test('isOngoing diturunkan dari endDate', () {
      final ongoing = Experience(
        position: 'Intern',
        company: 'Acme',
        employmentType: EmploymentType.internship,
        startDate: DateTime(2026, 1, 1),
        description: 'Membangun fitur.',
      );
      final finished = Experience(
        position: 'Intern',
        company: 'Acme',
        employmentType: EmploymentType.internship,
        startDate: DateTime(2026, 1, 1),
        endDate: DateTime(2026, 6, 1),
        description: 'Membangun fitur.',
      );

      expect(ongoing.isOngoing, isTrue);
      expect(finished.isOngoing, isFalse);
      expect(ongoing.link, isEmpty);
    });

    test('setiap EmploymentType punya label unik', () {
      final labels = EmploymentType.values.map((t) => t.label).toSet();
      expect(labels.length, EmploymentType.values.length);
    });
  });
}
