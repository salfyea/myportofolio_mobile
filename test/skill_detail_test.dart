// Test layar detail skill: semua field tampil, bagian kosong disembunyikan.

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/models/skill.dart';
import 'package:myportofolio_mobile/screens/skill_detail.dart';

import 'support/test_app.dart';

Future<void> openDetail(WidgetTester tester, Skill skill) {
  return tester.pumpWidget(
    testApp(
      client: fakeApiClient(emptyBackend),
      home: SkillDetailPage(skill: skill),
    ),
  );
}

void main() {
  const full = Skill(
    id: 's-1',
    name: 'Flutter',
    iconUrl: 'https://example.com/flutter.png',
    category: 'Framework',
    starCount: 3,
    starredByNames: 'owner, visitor',
  );

  testWidgets('menampilkan seluruh field skill', (tester) async {
    await openDetail(tester, full);

    expect(find.text('Detail Skill'), findsOneWidget);
    expect(find.text('Flutter'), findsOneWidget);
    expect(find.text('Framework'), findsOneWidget);
    expect(find.text('https://example.com/flutter.png'), findsOneWidget);
    expect(
      find.text('3 bintang, diberikan oleh owner, visitor'),
      findsOneWidget,
    );
  });

  testWidgets('ikon ditampilkan sebagai gambar', (tester) async {
    await openDetail(tester, full);

    expect(find.byType(Image), findsOneWidget);
  });

  testWidgets('URL ikon rusak tidak merusak halaman', (tester) async {
    await openDetail(tester, full);
    // Lingkungan tes menjawab semua permintaan gambar dengan galat.
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('Flutter'), findsOneWidget);
  });

  testWidgets('kategori kosong menyembunyikan chip kategori', (tester) async {
    await openDetail(
      tester,
      const Skill(name: 'Git', iconUrl: 'https://example.com/git.png'),
    );

    expect(find.byType(Chip), findsNothing);
    expect(find.text('Git'), findsOneWidget);
  });

  testWidgets('tanpa bintang hanya menampilkan jumlahnya', (tester) async {
    await openDetail(
      tester,
      const Skill(name: 'Sepi', iconUrl: 'https://example.com/s.png'),
    );

    expect(find.text('0 bintang'), findsOneWidget);
    expect(find.textContaining('diberikan oleh'), findsNothing);
  });

  testWidgets('nama dan URL yang panjang tidak overflow di layar ponsel', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(360, 640);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await openDetail(
      tester,
      Skill(
        name: 'Nama skill yang sangat panjang ' * 5,
        iconUrl: 'https://example.com/${'a' * 150}.png',
        category: 'Kategori',
      ),
    );

    expect(tester.takeException(), isNull);
  });
}
