// Unit test untuk fungsi validasi murni di lib/utils/validators.dart.

import 'package:flutter_test/flutter_test.dart';
import 'package:myportofolio_mobile/utils/validators.dart';

void main() {
  group('validateRequired', () {
    test('menolak null, kosong, dan hanya spasi', () {
      expect(validateRequired(null, 'Judul'), 'Judul tidak boleh kosong!');
      expect(validateRequired('', 'Judul'), 'Judul tidak boleh kosong!');
      expect(validateRequired('   ', 'Judul'), 'Judul tidak boleh kosong!');
      expect(validateRequired('\n\t ', 'Judul'), 'Judul tidak boleh kosong!');
    });

    test('menerima teks biasa', () {
      expect(validateRequired('Burhanpedia', 'Judul'), isNull);
    });

    test('batas panjang dihitung setelah spasi pinggir dipangkas', () {
      expect(validateRequired('  abc  ', 'Judul', maxLength: 3), isNull);
      expect(
        validateRequired('abcd', 'Judul', maxLength: 3),
        'Judul terlalu panjang (maksimal 3 karakter).',
      );
    });
  });

  group('validateMaxLength', () {
    test('tanpa batas selalu valid', () {
      expect(validateMaxLength('x' * 1000, 'Teks', null), isNull);
    });

    test('tepat di batas valid, satu lebih ditolak', () {
      expect(validateMaxLength('x' * 5, 'Teks', 5), isNull);
      expect(validateMaxLength('x' * 6, 'Teks', 5), isNotNull);
    });

    test('tidak mewajibkan isian', () {
      expect(validateMaxLength(null, 'Teks', 5), isNull);
      expect(validateMaxLength('', 'Teks', 5), isNull);
    });
  });

  group('validateOptionalUrl', () {
    test('kosong dan hanya spasi dianggap valid (opsional)', () {
      expect(validateOptionalUrl(null, 'Tautan'), isNull);
      expect(validateOptionalUrl('', 'Tautan'), isNull);
      expect(validateOptionalUrl('   ', 'Tautan'), isNull);
    });

    test('menerima http dan https', () {
      expect(
        validateOptionalUrl('https://github.com/salfyea', 'Tautan'),
        isNull,
      );
      expect(validateOptionalUrl('http://contoh.id/a?b=1', 'Tautan'), isNull);
    });

    test('menolak yang bukan URL web', () {
      for (final bad in [
        'abc',
        'github.com',
        'ftp://situs.com',
        'http://',
        'https:///path',
        'javascript:alert(1)',
        'https://ada spasi.com',
      ]) {
        expect(validateOptionalUrl(bad, 'Tautan'), isNotNull, reason: bad);
      }
    });

    test('menolak URL yang melebihi batas panjang', () {
      final long = 'https://contoh.id/${'a' * 50}';
      expect(
        validateOptionalUrl(long, 'URL icon', maxLength: 20),
        'URL icon terlalu panjang (maksimal 20 karakter).',
      );
    });
  });

  group('validateRequiredUrl', () {
    test('kosong atau hanya spasi ditolak sebagai wajib diisi', () {
      expect(
        validateRequiredUrl(null, 'URL ikon'),
        'URL ikon tidak boleh kosong!',
      );
      expect(
        validateRequiredUrl('', 'URL ikon'),
        'URL ikon tidak boleh kosong!',
      );
      expect(
        validateRequiredUrl('   ', 'URL ikon'),
        'URL ikon tidak boleh kosong!',
      );
    });

    test('URL http dan https yang valid diterima', () {
      expect(validateRequiredUrl('https://x.com/a.png', 'URL ikon'), isNull);
      expect(validateRequiredUrl('http://x.com/a.png', 'URL ikon'), isNull);
      expect(
        validateRequiredUrl('  https://x.com/a.png  ', 'URL ikon'),
        isNull,
      );
    });

    test('skema selain http(s), tanpa host, atau berspasi ditolak', () {
      for (final bad in [
        'abc',
        'ftp://x.com/a.png',
        'http://',
        'https://x .com',
      ]) {
        expect(
          validateRequiredUrl(bad, 'URL ikon'),
          contains('URL ikon tidak valid'),
          reason: bad,
        );
      }
    });

    test('URL yang melebihi batas panjang ditolak', () {
      final tooLong = 'https://x.com/${'a' * 200}';

      expect(
        validateRequiredUrl(tooLong, 'URL ikon', maxLength: 200),
        'URL ikon terlalu panjang (maksimal 200 karakter).',
      );
    });
  });

  group('validateDateOrder', () {
    final start = DateTime(2026, 5, 10);

    test('selesai setelah atau sama dengan mulai valid', () {
      expect(validateDateOrder(start, DateTime(2026, 5, 11)), isNull);
      expect(validateDateOrder(start, DateTime(2026, 5, 10)), isNull);
    });

    test('selesai sebelum mulai ditolak', () {
      expect(
        validateDateOrder(start, DateTime(2026, 5, 9)),
        'Tanggal selesai tidak boleh sebelum tanggal mulai.',
      );
    });

    test('jam diabaikan: hari yang sama dengan jam lebih awal tetap valid', () {
      expect(
        validateDateOrder(DateTime(2026, 5, 10, 18), DateTime(2026, 5, 10, 6)),
        isNull,
      );
    });

    test('salah satu null dianggap valid', () {
      expect(validateDateOrder(null, DateTime(2026, 1, 1)), isNull);
      expect(validateDateOrder(start, null), isNull);
      expect(validateDateOrder(null, null), isNull);
    });
  });

  group('validateRequiredDate', () {
    // "Hari ini" dibekukan agar test tidak bergantung pada tanggal sebenarnya.
    final today = DateTime(2026, 11, 23, 15, 30);

    test('menolak tanggal yang belum dipilih', () {
      expect(
        validateRequiredDate(null, 'Tanggal mulai'),
        'Tanggal mulai wajib dipilih!',
      );
    });

    test('tanggal masa depan diterima jika diizinkan (bawaan)', () {
      expect(validateRequiredDate(DateTime(2030, 1, 1), 'Tanggal'), isNull);
    });

    test('tanggal masa depan ditolak jika allowFuture false', () {
      expect(
        validateRequiredDate(
          DateTime(2026, 11, 24),
          'Tanggal mulai',
          allowFuture: false,
          now: today,
        ),
        'Tanggal mulai tidak boleh di masa depan.',
      );
    });

    test('hari ini dan masa lalu diterima meskipun jam berbeda', () {
      for (final ok in [DateTime(2026, 11, 23, 23, 59), DateTime(2020, 1, 1)]) {
        expect(
          validateRequiredDate(
            ok,
            'Tanggal mulai',
            allowFuture: false,
            now: today,
          ),
          isNull,
          reason: '$ok',
        );
      }
    });
  });

  group('validateEndDate', () {
    final start = DateTime(2026, 5, 10);

    test('masih berlangsung: tanggal selesai tidak diperlukan', () {
      expect(validateEndDate(start, null, isOngoing: true), isNull);
    });

    test('tidak berlangsung tetapi tanggal selesai kosong ditolak', () {
      expect(validateEndDate(start, null, isOngoing: false), isNotNull);
    });

    test('tanggal selesai sebelum mulai ditolak, setelahnya diterima', () {
      expect(
        validateEndDate(start, DateTime(2026, 5, 9), isOngoing: false),
        'Tanggal selesai tidak boleh sebelum tanggal mulai.',
      );
      expect(
        validateEndDate(start, DateTime(2026, 8, 1), isOngoing: false),
        isNull,
      );
    });
  });
}
