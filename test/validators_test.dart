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
      expect(validateOptionalUrl('https://github.com/salfyea', 'Tautan'), isNull);
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
}
