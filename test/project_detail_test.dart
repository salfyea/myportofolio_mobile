// Test layar detail proyek: semua field tampil, bagian kosong disembunyikan.

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/models/project.dart';
import 'package:myportofolio_mobile/screens/project_detail.dart';

Future<void> openDetail(WidgetTester tester, Project project) {
  return tester.pumpWidget(
    MaterialApp(home: ProjectDetailPage(project: project)),
  );
}

void main() {
  const full = Project(
    id: 'p-1',
    title: 'MyPortfolio Mobile',
    description: 'Klien Flutter untuk portofolio.',
    category: 'Mobile Development',
    link: 'https://github.com/salfyea/myportofolio_mobile',
    projectImageUrl: 'https://example.com/cover.png',
    starCount: 3,
    starredByNames: 'owner, visitor',
  );

  testWidgets('menampilkan seluruh field proyek', (tester) async {
    await openDetail(tester, full);

    expect(find.text('Detail Proyek'), findsOneWidget);
    expect(find.text('MyPortfolio Mobile'), findsOneWidget);
    expect(find.text('Mobile Development'), findsOneWidget);
    expect(find.text('Klien Flutter untuk portofolio.'), findsOneWidget);
    expect(
      find.text('https://github.com/salfyea/myportofolio_mobile'),
      findsOneWidget,
    );
    expect(
      find.text('3 bintang, diberikan oleh owner, visitor'),
      findsOneWidget,
    );
  });

  testWidgets('gambar ditampilkan bila URL-nya tidak kosong', (tester) async {
    await openDetail(tester, full);

    expect(find.byType(Image), findsOneWidget);
  });

  testWidgets('gambar tidak ditampilkan bila URL kosong', (tester) async {
    await openDetail(
      tester,
      const Project(title: 'Tanpa gambar', description: 'd', category: 'c'),
    );

    expect(find.byType(Image), findsNothing);
  });

  testWidgets('URL gambar rusak tidak merusak halaman', (tester) async {
    await openDetail(tester, full);
    // Lingkungan tes menjawab semua permintaan gambar dengan galat.
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('MyPortfolio Mobile'), findsOneWidget);
  });

  testWidgets('tautan kosong menyembunyikan bagian Tautan', (tester) async {
    await openDetail(
      tester,
      const Project(title: 'Tanpa tautan', description: 'd', category: 'c'),
    );

    expect(find.text('Tautan'), findsNothing);
    expect(find.text('Deskripsi'), findsOneWidget);
  });

  testWidgets('tanpa bintang hanya menampilkan jumlahnya', (tester) async {
    await openDetail(
      tester,
      const Project(title: 'Sepi', description: 'd', category: 'c'),
    );

    expect(find.text('0 bintang'), findsOneWidget);
    expect(find.textContaining('diberikan oleh'), findsNothing);
  });

  testWidgets('deskripsi panjang bisa digulir tanpa overflow', (tester) async {
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(360, 640);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await openDetail(
      tester,
      Project(title: 'Panjang', description: 'kata ' * 600, category: 'c'),
    );

    expect(tester.takeException(), isNull);
    await tester.drag(
      find.byType(SingleChildScrollView),
      const Offset(0, -800),
    );
    await tester.pumpAndSettle();
    expect(find.text('Bintang'), findsOneWidget);
  });
}
