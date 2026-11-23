// Test layar daftar proyek: memuat, galat + Retry, kosong, tarik-muat-ulang,
// dan membuka detail.

import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/screens/project_detail.dart';
import 'package:myportofolio_mobile/screens/project_list.dart';

import 'support/test_app.dart';

Map<String, dynamic> projectJson(String title, {int stars = 0}) => {
  'id': 'id-$title',
  'title': title,
  'description': 'Deskripsi $title',
  'category': 'Web Development',
  'link': 'https://example.com/$title',
  'project_image_url': '',
  'star_count': stars,
  'is_starred': false,
  'starred_by_names': '',
};

Future<void> openList(
  WidgetTester tester,
  Future<http.Response> Function(http.Request) handler,
) async {
  await tester.pumpWidget(
    testApp(client: fakeApiClient(handler), home: const ProjectListPage()),
  );
}

void main() {
  testWidgets('menampilkan indikator memuat lalu daftar proyek', (
    tester,
  ) async {
    final reply = Completer<http.Response>();
    await openList(tester, (_) => reply.future);

    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    reply.complete(
      jsonResponse([projectJson('Alpha', stars: 3), projectJson('Beta')]),
    );
    await tester.pumpAndSettle();

    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.text('Alpha'), findsOneWidget);
    expect(find.text('Deskripsi Alpha'), findsOneWidget);
    expect(find.text('Beta'), findsOneWidget);
    expect(find.text('3'), findsOneWidget); // jumlah bintang Alpha
  });

  testWidgets('hanya satu permintaan walau layar dibangun ulang', (
    tester,
  ) async {
    var requests = 0;
    await openList(tester, (_) async {
      requests++;
      return jsonResponse([projectJson('Alpha')]);
    });
    await tester.pumpAndSettle();

    // Mengubah ukuran layar memicu build() ulang. Bila Future dibuat di build(),
    // permintaan akan dikirim lagi.
    tester.view.physicalSize = const Size(500, 900);
    addTearDown(tester.view.resetPhysicalSize);
    await tester.pumpAndSettle();
    tester.view.physicalSize = const Size(800, 1200);
    await tester.pumpAndSettle();

    expect(requests, 1);
  });

  testWidgets('daftar publik: tidak mengirim header Authorization', (
    tester,
  ) async {
    late http.Request seen;
    await openList(tester, (request) async {
      seen = request;
      return jsonResponse(<Object>[]);
    });
    await tester.pumpAndSettle();

    expect(seen.url.path, '/api/v1/projects/');
    expect(seen.headers.containsKey('Authorization'), isFalse);
  });

  testWidgets('daftar kosong menampilkan pesan, bukan layar kosong', (
    tester,
  ) async {
    await openList(tester, (_) async => jsonResponse(<Object>[]));
    await tester.pumpAndSettle();

    expect(find.text('Belum ada proyek.'), findsOneWidget);
  });

  testWidgets('daftar kosong tetap bisa ditarik untuk dimuat ulang', (
    tester,
  ) async {
    var requests = 0;
    await openList(tester, (_) async {
      requests++;
      return jsonResponse(<Object>[if (requests > 1) projectJson('Baru')]);
    });
    await tester.pumpAndSettle();
    expect(find.text('Belum ada proyek.'), findsOneWidget);

    await tester.fling(
      find.text('Belum ada proyek.'),
      const Offset(0, 400),
      1000,
    );
    await tester.pumpAndSettle();

    expect(requests, 2);
    expect(find.text('Baru'), findsOneWidget);
  });

  testWidgets('tarik ke bawah memuat ulang daftar', (tester) async {
    var requests = 0;
    await openList(tester, (_) async {
      requests++;
      return jsonResponse([
        projectJson('Alpha'),
        if (requests > 1) projectJson('Gamma'),
      ]);
    });
    await tester.pumpAndSettle();
    expect(find.text('Gamma'), findsNothing);

    await tester.fling(find.text('Alpha'), const Offset(0, 400), 1000);
    await tester.pumpAndSettle();

    expect(requests, 2);
    expect(find.text('Gamma'), findsOneWidget);
  });

  testWidgets('galat menampilkan pesan dan Retry memuat ulang', (tester) async {
    var requests = 0;
    await openList(tester, (_) async {
      requests++;
      if (requests == 1) {
        return jsonResponse({'detail': 'Server sibuk.'}, status: 503);
      }
      return jsonResponse([projectJson('Alpha')]);
    });
    await tester.pumpAndSettle();

    expect(find.textContaining('Gagal memuat proyek'), findsOneWidget);
    expect(find.textContaining('Server sibuk.'), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);

    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();

    expect(find.text('Alpha'), findsOneWidget);
    expect(find.text('Retry'), findsNothing);
  });

  testWidgets('galat jaringan ditampilkan sebagai pesan yang bisa dibaca', (
    tester,
  ) async {
    await openList(
      tester,
      (_) async => throw http.ClientException('Connection refused'),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('Tidak dapat terhubung'), findsOneWidget);
    // Detail teknis tidak bocor ke pengguna.
    expect(find.textContaining('Connection refused'), findsNothing);
  });

  testWidgets('Retry yang gagal lagi tidak melempar galat tak tertangani', (
    tester,
  ) async {
    await openList(
      tester,
      (_) async => jsonResponse({'detail': 'Server sibuk.'}, status: 503),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();

    expect(find.text('Retry'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('mengetuk item membuka detail proyek yang dipilih', (
    tester,
  ) async {
    await openList(
      tester,
      (_) async => jsonResponse([projectJson('Alpha'), projectJson('Beta')]),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Beta'));
    await tester.pumpAndSettle();

    expect(find.byType(ProjectDetailPage), findsOneWidget);
    expect(find.text('Detail Proyek'), findsOneWidget);
    expect(find.text('Beta'), findsOneWidget);
    expect(find.text('Alpha'), findsNothing);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.byType(ProjectListPage), findsOneWidget);
  });
}
