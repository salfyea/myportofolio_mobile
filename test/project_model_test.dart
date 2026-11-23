import 'package:flutter_test/flutter_test.dart';
import 'package:myportofolio_mobile/models/project.dart';

void main() {
  // Bentuk persis yang dikirim ProjectSerializer di backend Django.
  const apiJson = <String, dynamic>{
    'id': '0b6f6f0e-9c0a-4d7f-8d1e-2f7a5f4a9c11',
    'title': 'MyPortfolio Mobile',
    'description': 'Klien Flutter untuk portofolio.',
    'category': 'Mobile Development',
    'link': 'https://github.com/salfyea/myportofolio_mobile',
    'project_image_url': 'https://example.com/cover.png',
    'star_count': 3,
    'is_starred': true,
    'starred_by_names': 'owner, visitor',
  };

  group('Project.fromJson', () {
    test('memetakan kunci snake_case milik DRF ke properti camelCase', () {
      final project = Project.fromJson(apiJson);

      expect(project.id, '0b6f6f0e-9c0a-4d7f-8d1e-2f7a5f4a9c11');
      expect(project.title, 'MyPortfolio Mobile');
      expect(project.description, 'Klien Flutter untuk portofolio.');
      expect(project.category, 'Mobile Development');
      expect(project.link, 'https://github.com/salfyea/myportofolio_mobile');
      expect(project.projectImageUrl, 'https://example.com/cover.png');
      expect(project.starCount, 3);
      expect(project.isStarred, isTrue);
      expect(project.starredByNames, 'owner, visitor');
    });

    test('field opsional yang hilang atau null memakai nilai bawaan', () {
      final project = Project.fromJson(const {
        'id': 'abc',
        'title': 'Tanpa gambar',
        'description': 'd',
        'category': 'c',
        'link': null,
      });

      expect(project.link, '');
      expect(project.projectImageUrl, '');
      expect(project.starCount, 0);
      expect(project.isStarred, isFalse);
      expect(project.starredByNames, '');
    });

    test('gagal dengan jelas bila field wajib tidak ada', () {
      expect(
        () => Project.fromJson(const {'id': 'abc', 'description': 'd'}),
        throwsA(isA<TypeError>()),
      );
    });
  });

  group('Project.toJson', () {
    test('hanya mengirim field yang boleh ditulis klien, dengan kunci snake_case',
        () {
      final json = Project.fromJson(apiJson).toJson();

      expect(json, {
        'title': 'MyPortfolio Mobile',
        'description': 'Klien Flutter untuk portofolio.',
        'category': 'Mobile Development',
        'link': 'https://github.com/salfyea/myportofolio_mobile',
        'project_image_url': 'https://example.com/cover.png',
      });
    });

    test('id dari server dan data bintang tidak ikut dikirim', () {
      final json = Project.fromJson(apiJson).toJson();

      expect(json.containsKey('id'), isFalse);
      expect(json.containsKey('star_count'), isFalse);
      expect(json.containsKey('is_starred'), isFalse);
      expect(json.containsKey('starred_by_names'), isFalse);
    });

    test('proyek baru buatan form tidak punya id dan memakai default kosong', () {
      const project = Project(
        title: 'Baru',
        description: 'd',
        category: 'Other',
      );

      expect(project.id, isNull);
      expect(project.toJson()['link'], '');
      expect(project.toJson()['project_image_url'], '');
    });
  });
}
