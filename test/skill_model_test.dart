import 'package:flutter_test/flutter_test.dart';
import 'package:myportofolio_mobile/models/skill.dart';

void main() {
  // Bentuk persis yang dikirim SkillSerializer di backend Django.
  const apiJson = <String, dynamic>{
    'id': '7d1f6f0e-9c0a-4d7f-8d1e-2f7a5f4a9c22',
    'name': 'Flutter',
    'icon_url': 'https://example.com/flutter.png',
    'category': 'Framework',
    'star_count': 4,
    'is_starred': true,
    'starred_by_names': 'owner, visitor',
  };

  group('Skill.fromJson', () {
    test('memetakan kunci snake_case milik DRF ke properti camelCase', () {
      final skill = Skill.fromJson(apiJson);

      expect(skill.id, '7d1f6f0e-9c0a-4d7f-8d1e-2f7a5f4a9c22');
      expect(skill.name, 'Flutter');
      expect(skill.iconUrl, 'https://example.com/flutter.png');
      expect(skill.category, 'Framework');
      expect(skill.starCount, 4);
      expect(skill.isStarred, isTrue);
      expect(skill.starredByNames, 'owner, visitor');
    });

    test('kategori kosong, null, atau hilang menjadi string kosong', () {
      const base = {'id': 'a', 'name': 'Dart', 'icon_url': 'https://x.test/d'};

      expect(Skill.fromJson({...base, 'category': ''}).category, '');
      expect(Skill.fromJson({...base, 'category': null}).category, '');
      expect(Skill.fromJson(base).category, '');
    });

    test('data bintang yang hilang memakai nilai bawaan', () {
      final skill = Skill.fromJson(const {
        'id': 'a',
        'name': 'Dart',
        'icon_url': 'https://x.test/d',
      });

      expect(skill.starCount, 0);
      expect(skill.isStarred, isFalse);
      expect(skill.starredByNames, '');
    });

    test('gagal dengan jelas bila field wajib tidak ada', () {
      expect(
        () => Skill.fromJson(const {'id': 'a', 'name': 'Dart'}),
        throwsA(isA<TypeError>()),
      );
    });
  });

  group('Skill.toJson', () {
    test(
      'hanya mengirim field yang boleh ditulis, dengan kunci snake_case',
      () {
        expect(Skill.fromJson(apiJson).toJson(), {
          'name': 'Flutter',
          'icon_url': 'https://example.com/flutter.png',
          'category': 'Framework',
        });
      },
    );

    test('id dari server dan data bintang tidak ikut dikirim', () {
      final json = Skill.fromJson(apiJson).toJson();

      expect(json.containsKey('id'), isFalse);
      expect(json.containsKey('star_count'), isFalse);
      expect(json.containsKey('is_starred'), isFalse);
      expect(json.containsKey('starred_by_names'), isFalse);
    });

    test('skill baru buatan form tidak punya id dan kategorinya kosong', () {
      const skill = Skill(name: 'Baru', iconUrl: 'https://x.test/b.png');

      expect(skill.id, isNull);
      expect(skill.toJson()['category'], '');
    });
  });
}
