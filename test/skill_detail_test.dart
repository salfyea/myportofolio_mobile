// Test layar detail skill: semua field tampil, bagian kosong disembunyikan,
// serta edit (PATCH) dan hapus (DELETE) yang hanya tersedia setelah login.

import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/models/skill.dart';
import 'package:myportofolio_mobile/screens/login_screen.dart';
import 'package:myportofolio_mobile/screens/skill_detail.dart';
import 'package:myportofolio_mobile/screens/skill_form.dart';
import 'package:myportofolio_mobile/screens/skill_list.dart';
import 'package:myportofolio_mobile/services/auth_state.dart';
import 'package:provider/provider.dart';

import 'support/test_app.dart';

Future<void> openDetail(
  WidgetTester tester,
  Skill skill, {
  String? loggedInToken,
}) {
  return tester.pumpWidget(
    testApp(
      client: fakeApiClient(emptyBackend),
      loggedInToken: loggedInToken,
      home: SkillDetailPage(skill: skill),
    ),
  );
}

/// Backend palsu berstatus: menyimpan skill, mencatat permintaan, dan menjawab
/// GET, PATCH, serta DELETE seperti DRF.
class FakeSkillBackend {
  FakeSkillBackend({this.deleteStatus = 204, this.patchStatus = 200}) {
    skills['s-1'] = {
      'id': 's-1',
      'name': 'Flutter',
      'icon_url': 'https://example.com/flutter.png',
      'category': 'Framework',
      'star_count': 2,
      'is_starred': false,
      'starred_by_names': 'owner',
    };
  }

  final int deleteStatus;
  final int patchStatus;
  final skills = <String, Map<String, dynamic>>{};
  final requests = <http.Request>[];

  /// Balasan yang menahan permintaan sampai tes menyelesaikannya.
  Completer<void>? hold;

  Future<http.Response> call(http.Request request) async {
    requests.add(request);
    await hold?.future;

    switch ('${request.method} ${request.url.path}') {
      case 'GET /api/v1/skills/':
        return jsonResponse(skills.values.toList());
      case 'PATCH /api/v1/skills/s-1/':
        if (patchStatus != 200) {
          return jsonResponse(_error(patchStatus), status: patchStatus);
        }
        skills['s-1']!.addAll(jsonDecode(request.body) as Map<String, dynamic>);
        return jsonResponse(skills['s-1']!);
      case 'DELETE /api/v1/skills/s-1/':
        if (deleteStatus != 204) {
          return jsonResponse(_error(deleteStatus), status: deleteStatus);
        }
        skills.remove('s-1');
        return http.Response('', 204);
    }
    return jsonResponse({'detail': 'Data tidak ditemukan.'}, status: 404);
  }

  static Map<String, dynamic> _error(int status) => switch (status) {
    401 => {'detail': 'Invalid token.'},
    403 => {'detail': 'Hanya pemilik portofolio yang dapat mengubah data.'},
    _ => {'detail': 'Galat $status.'},
  };

  http.Request lastOf(String method) =>
      requests.lastWhere((request) => request.method == method);

  bool sent(String method) => requests.any((r) => r.method == method);
}

/// Membuka daftar, lalu mengetuk skill pertama hingga detailnya terbuka.
Future<AuthState> openDetailFromList(
  WidgetTester tester,
  FakeSkillBackend backend, {
  String? loggedInToken = 'tok',
}) async {
  useTallScreen(tester);
  await tester.pumpWidget(
    testApp(
      client: fakeApiClient(backend.call),
      loggedInToken: loggedInToken,
      home: const SkillListPage(),
    ),
  );
  await tester.pumpAndSettle();
  await tester.tap(find.byType(ListTile).first);
  await tester.pumpAndSettle();
  return tester.element(find.byType(SkillDetailPage)).read<AuthState>();
}

Finder get editButton => find.byTooltip('Edit skill');
Finder get deleteButton => find.byTooltip('Hapus skill');

/// `byTooltip` menemukan widget Tooltip; untuk membaca `onPressed`, yang
/// dibutuhkan adalah IconButton-nya.
VoidCallback? onPressedOf(WidgetTester tester, IconData icon) =>
    tester.widget<IconButton>(find.widgetWithIcon(IconButton, icon)).onPressed;

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

  group('tombol edit dan hapus', () {
    testWidgets('tidak tampil saat belum login', (tester) async {
      await openDetail(tester, full);

      expect(editButton, findsNothing);
      expect(deleteButton, findsNothing);
    });

    testWidgets('tampil setelah login', (tester) async {
      await openDetail(tester, full, loggedInToken: 'tok');

      expect(editButton, findsOneWidget);
      expect(deleteButton, findsOneWidget);
    });

    testWidgets('tombol hilang begitu pengguna logout', (tester) async {
      await openDetail(tester, full, loggedInToken: 'tok');
      final auth = tester
          .element(find.byType(SkillDetailPage))
          .read<AuthState>();

      auth.clearSession();
      await tester.pump();

      expect(editButton, findsNothing);
      expect(deleteButton, findsNothing);
    });
  });

  group('hapus (DELETE)', () {
    testWidgets('meminta konfirmasi; Batal tidak mengirim permintaan', (
      tester,
    ) async {
      final backend = FakeSkillBackend();
      await openDetailFromList(tester, backend);

      await tester.tap(deleteButton);
      await tester.pumpAndSettle();
      expect(find.text('Hapus skill?'), findsOneWidget);

      await tester.tap(find.text('Batal'));
      await tester.pumpAndSettle();

      expect(find.byType(SkillDetailPage), findsOneWidget);
      expect(backend.sent('DELETE'), isFalse);
    });

    testWidgets('Hapus mengirim DELETE bertoken lalu daftar memuat ulang', (
      tester,
    ) async {
      final backend = FakeSkillBackend();
      await openDetailFromList(tester, backend);

      await tester.tap(deleteButton);
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, 'Hapus'));
      await tester.pumpAndSettle();

      final sent = backend.lastOf('DELETE');
      expect(sent.url.path, '/api/v1/skills/s-1/');
      expect(sent.headers['Authorization'], 'Token tok');
      // Kembali ke daftar yang sudah dimuat ulang: skill itu tidak ada lagi.
      expect(find.byType(SkillDetailPage), findsNothing);
      expect(find.byType(SkillListPage), findsOneWidget);
      expect(find.text('Belum ada skill.'), findsOneWidget);
      expect(find.text('Skill "Flutter" dihapus.'), findsOneWidget);
    });

    testWidgets('tombol dinonaktifkan selama permintaan berjalan', (
      tester,
    ) async {
      final backend = FakeSkillBackend();
      await openDetailFromList(tester, backend);
      backend.hold = Completer<void>();

      await tester.tap(deleteButton);
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, 'Hapus'));
      await tester.pump();

      expect(onPressedOf(tester, Icons.delete_outline), isNull);
      expect(onPressedOf(tester, Icons.edit_outlined), isNull);

      backend.hold!.complete();
      await tester.pumpAndSettle();
      expect(find.byType(SkillDetailPage), findsNothing);
    });

    testWidgets('403 (bukan pemilik) menampilkan pesan dan tetap di detail', (
      tester,
    ) async {
      final backend = FakeSkillBackend(deleteStatus: 403);
      final auth = await openDetailFromList(tester, backend);

      await tester.tap(deleteButton);
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, 'Hapus'));
      await tester.pumpAndSettle();

      expect(find.textContaining('Hanya pemilik portofolio'), findsOneWidget);
      expect(find.byType(SkillDetailPage), findsOneWidget);
      expect(auth.isLoggedIn, isTrue);
      // Setelah gagal, tombol bisa dipakai lagi.
      expect(onPressedOf(tester, Icons.delete_outline), isNotNull);
    });

    testWidgets('401 menghapus sesi dan meminta login ulang', (tester) async {
      final backend = FakeSkillBackend(deleteStatus: 401);
      final auth = await openDetailFromList(tester, backend);

      await tester.tap(deleteButton);
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, 'Hapus'));
      await tester.pumpAndSettle();

      expect(auth.isLoggedIn, isFalse);
      expect(find.byType(LoginScreen), findsOneWidget);

      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.byType(SkillDetailPage), findsOneWidget);
      // Tanpa sesi, tombol edit dan hapus tidak tampil lagi.
      expect(deleteButton, findsNothing);
    });

    testWidgets('jaringan putus menampilkan pesan yang bisa dibaca', (
      tester,
    ) async {
      useTallScreen(tester);
      await tester.pumpWidget(
        testApp(
          client: fakeApiClient(
            (_) async => throw http.ClientException('Connection refused'),
          ),
          loggedInToken: 'tok',
          home: SkillDetailPage(skill: full),
        ),
      );

      await tester.tap(deleteButton);
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, 'Hapus'));
      await tester.pumpAndSettle();

      expect(find.textContaining('Tidak dapat terhubung'), findsOneWidget);
      expect(find.byType(SkillDetailPage), findsOneWidget);
    });
  });

  group('edit (PATCH)', () {
    testWidgets('membuka form berisi data skill tanpa drawer', (tester) async {
      await openDetailFromList(tester, FakeSkillBackend());

      await tester.tap(editButton);
      await tester.pumpAndSettle();

      expect(find.byType(SkillFormPage), findsOneWidget);
      expect(find.text('Edit Skill Form'), findsOneWidget);
      expect(find.text('Flutter'), findsOneWidget);
      expect(find.text('https://example.com/flutter.png'), findsOneWidget);
      expect(find.text('Framework'), findsOneWidget);
      expect(find.byTooltip('Open navigation menu'), findsNothing);
    });

    testWidgets(
      'Save mengirim PATCH bertoken lalu daftar menampilkan hasilnya',
      (tester) async {
        final backend = FakeSkillBackend();
        await openDetailFromList(tester, backend);

        await tester.tap(editButton);
        await tester.pumpAndSettle();
        await tester.enterText(
          find.widgetWithText(TextFormField, 'Nama Skill'),
          'Flutter 3',
        );
        await tester.tap(find.text('Save'));
        await tester.pumpAndSettle();

        final sent = backend.lastOf('PATCH');
        expect(sent.url.path, '/api/v1/skills/s-1/');
        expect(sent.headers['Authorization'], 'Token tok');
        expect(jsonDecode(sent.body), {
          'name': 'Flutter 3',
          'icon_url': 'https://example.com/flutter.png',
          'category': 'Framework',
        });
        expect(find.byType(SkillListPage), findsOneWidget);
        expect(find.text('Flutter 3'), findsOneWidget);
        expect(find.text('Skill diperbarui.'), findsOneWidget);
      },
    );

    testWidgets('403 (Editor tak berhak) menampilkan pesan dan tetap di form', (
      tester,
    ) async {
      final backend = FakeSkillBackend(patchStatus: 403);
      await openDetailFromList(tester, backend);

      await tester.tap(editButton);
      await tester.pumpAndSettle();
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Nama Skill'),
        'Flutter 3',
      );
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(find.textContaining('Hanya pemilik portofolio'), findsOneWidget);
      expect(find.byType(SkillFormPage), findsOneWidget);
      expect(find.text('Flutter 3'), findsOneWidget);
    });
  });
}
