// Test form Add Skill: validasi, POST terautentikasi, dan penanganan galat.

import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/screens/login_screen.dart';
import 'package:myportofolio_mobile/screens/skill_form.dart';
import 'package:myportofolio_mobile/screens/skill_list.dart';
import 'package:myportofolio_mobile/services/auth_state.dart';
import 'package:provider/provider.dart';

import 'support/test_app.dart';

Map<String, dynamic> createdJson({
  String name = 'Flutter',
  String category = 'Framework',
}) => {
  'id': 'new-id',
  'name': name,
  'icon_url': 'https://example.com/flutter.png',
  'category': category,
  'star_count': 0,
  'is_starred': false,
  'starred_by_names': '',
};

Finder field(String label) => find.widgetWithText(TextFormField, label);

Future<void> fillValidForm(WidgetTester tester) async {
  await tester.enterText(field('Nama Skill'), 'Flutter');
  await tester.enterText(field('URL Ikon'), 'https://example.com/flutter.png');
  await tester.enterText(field('Kategori (opsional)'), 'Framework');
}

Future<void> tapSave(WidgetTester tester) async {
  await tester.tap(find.text('Save'));
  await tester.pumpAndSettle();
}

/// Membuka form langsung (tanpa lewat menu) dengan backend [handler].
Future<AuthState> openForm(
  WidgetTester tester,
  MockClientHandler handler, {
  String? loggedInToken = 'tok',
}) async {
  useTallScreen(tester);
  await tester.pumpWidget(
    testApp(
      client: fakeApiClient(handler),
      loggedInToken: loggedInToken,
      home: const SkillFormPage(),
    ),
  );
  return tester.element(find.byType(SkillFormPage)).read<AuthState>();
}

void main() {
  group('validasi', () {
    testWidgets('spasi saja dianggap kosong dan tidak ada permintaan', (
      tester,
    ) async {
      var requests = 0;
      await openForm(tester, (_) async {
        requests++;
        return jsonResponse(createdJson(), status: 201);
      });

      await tester.enterText(field('Nama Skill'), '   ');
      await tester.enterText(field('URL Ikon'), '   ');
      await tapSave(tester);

      expect(find.text('Nama skill tidak boleh kosong!'), findsOneWidget);
      expect(find.text('URL ikon tidak boleh kosong!'), findsOneWidget);
      expect(requests, 0);
    });

    testWidgets('nama > 100, URL tanpa skema, dan kategori > 50 ditolak', (
      tester,
    ) async {
      var requests = 0;
      await openForm(tester, (_) async {
        requests++;
        return jsonResponse(createdJson(), status: 201);
      });

      await tester.enterText(field('Nama Skill'), 'a' * 101);
      await tester.enterText(field('URL Ikon'), 'example.com/a.png');
      await tester.enterText(field('Kategori (opsional)'), 'k' * 51);
      await tapSave(tester);

      expect(
        find.text('Nama skill terlalu panjang (maksimal 100 karakter).'),
        findsOneWidget,
      );
      expect(find.textContaining('URL ikon tidak valid'), findsOneWidget);
      expect(
        find.text('Kategori terlalu panjang (maksimal 50 karakter).'),
        findsOneWidget,
      );
      expect(requests, 0);
    });

    testWidgets('kategori boleh kosong', (tester) async {
      late Map<String, dynamic> sent;
      await openForm(tester, (request) async {
        sent = jsonDecode(request.body) as Map<String, dynamic>;
        return jsonResponse(createdJson(category: ''), status: 201);
      });

      await tester.enterText(field('Nama Skill'), 'Git');
      await tester.enterText(field('URL Ikon'), 'https://example.com/git.png');
      await tapSave(tester);

      expect(sent['category'], '');
      expect(find.text('Skill berhasil ditambahkan!'), findsOneWidget);
    });
  });

  group('POST terautentikasi', () {
    testWidgets('mengirim token dan JSON snake_case lalu menampilkan dialog', (
      tester,
    ) async {
      late http.Request seen;
      await openForm(tester, (request) async {
        seen = request;
        return jsonResponse(createdJson(), status: 201);
      });

      await fillValidForm(tester);
      await tapSave(tester);

      expect(seen.method, 'POST');
      expect(seen.url.path, '/api/v1/skills/');
      expect(seen.headers['Authorization'], 'Token tok');
      expect(jsonDecode(seen.body), {
        'name': 'Flutter',
        'icon_url': 'https://example.com/flutter.png',
        'category': 'Framework',
      });
      expect(find.text('Skill berhasil ditambahkan!'), findsOneWidget);
      expect(find.text('Nama Skill: Flutter'), findsOneWidget);
    });

    testWidgets('spasi di awal dan akhir isian dipangkas sebelum dikirim', (
      tester,
    ) async {
      late Map<String, dynamic> sent;
      await openForm(tester, (request) async {
        sent = jsonDecode(request.body) as Map<String, dynamic>;
        return jsonResponse(createdJson(), status: 201);
      });

      await tester.enterText(field('Nama Skill'), '  Flutter  ');
      await tester.enterText(
        field('URL Ikon'),
        '  https://example.com/flutter.png ',
      );
      await tapSave(tester);

      expect(sent['name'], 'Flutter');
      expect(sent['icon_url'], 'https://example.com/flutter.png');
    });

    testWidgets('Tambah Lagi mengosongkan form', (tester) async {
      await openForm(
        tester,
        (_) async => jsonResponse(createdJson(), status: 201),
      );

      await fillValidForm(tester);
      await tapSave(tester);

      await tester.tap(find.text('Tambah Lagi'));
      await tester.pumpAndSettle();

      expect(find.text('Skill berhasil ditambahkan!'), findsNothing);
      expect(find.text('Flutter'), findsNothing);
      expect(find.text('Framework'), findsNothing);
    });

    testWidgets('Lihat Daftar membuka daftar yang memuat skill baru', (
      tester,
    ) async {
      var created = false;
      await openForm(tester, (request) async {
        if (request.method == 'POST') {
          created = true;
          return jsonResponse(createdJson(), status: 201);
        }
        return jsonResponse([if (created) createdJson()]);
      });

      await fillValidForm(tester);
      await tapSave(tester);
      await tester.tap(find.text('Lihat Daftar'));
      await tester.pumpAndSettle();

      expect(find.byType(SkillListPage), findsOneWidget);
      expect(find.text('Flutter'), findsOneWidget);
    });

    testWidgets('tombol nonaktif dan berputar selama permintaan berjalan', (
      tester,
    ) async {
      final reply = Completer<http.Response>();
      await openForm(tester, (_) => reply.future);

      await fillValidForm(tester);
      await tester.tap(find.text('Save'));
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(
        tester.widget<ElevatedButton>(find.byType(ElevatedButton)).onPressed,
        isNull,
      );

      reply.complete(jsonResponse(createdJson(), status: 201));
      await tester.pumpAndSettle();
      expect(find.text('Skill berhasil ditambahkan!'), findsOneWidget);
    });
  });

  group('galat', () {
    testWidgets('403 (bukan pemilik) menampilkan pesan server, tetap login', (
      tester,
    ) async {
      final auth = await openForm(
        tester,
        (_) async => jsonResponse({
          'detail': 'Hanya pemilik portofolio yang dapat menambah data.',
        }, status: 403),
      );

      await fillValidForm(tester);
      await tapSave(tester);

      expect(find.textContaining('Hanya pemilik portofolio'), findsOneWidget);
      expect(find.text('Skill berhasil ditambahkan!'), findsNothing);
      expect(auth.isLoggedIn, isTrue);
      // Isian tidak hilang, jadi pengguna tidak perlu mengetik ulang.
      expect(find.text('Flutter'), findsOneWidget);
    });

    testWidgets('400 validasi dari server ditampilkan di SnackBar', (
      tester,
    ) async {
      await openForm(
        tester,
        (_) async => jsonResponse({
          'icon_url': ['URL icon tidak valid.'],
        }, status: 400),
      );

      await fillValidForm(tester);
      await tapSave(tester);

      expect(find.textContaining('URL icon tidak valid.'), findsOneWidget);
    });

    testWidgets('jaringan putus menampilkan pesan dan form tetap utuh', (
      tester,
    ) async {
      await openForm(
        tester,
        (_) async => throw http.ClientException('Connection refused'),
      );

      await fillValidForm(tester);
      await tapSave(tester);

      expect(find.textContaining('Tidak dapat terhubung'), findsOneWidget);
      expect(find.text('Flutter'), findsOneWidget);
    });

    testWidgets('401 menghapus sesi dan meminta login ulang', (tester) async {
      final auth = await openForm(
        tester,
        (_) async => jsonResponse({'detail': 'Invalid token.'}, status: 401),
      );

      await fillValidForm(tester);
      await tapSave(tester);

      expect(auth.isLoggedIn, isFalse);
      expect(find.byType(LoginScreen), findsOneWidget);

      // Kembali dari layar login: form dan isiannya masih ada.
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.byType(SkillFormPage), findsOneWidget);
      expect(find.text('Flutter'), findsOneWidget);
    });
  });

  group('belum login', () {
    testWidgets('Save membuka layar login; Back membatalkan tanpa permintaan', (
      tester,
    ) async {
      var requests = 0;
      await openForm(tester, (_) async {
        requests++;
        return jsonResponse(createdJson(), status: 201);
      }, loggedInToken: null);

      await fillValidForm(tester);
      await tapSave(tester);
      expect(find.byType(LoginScreen), findsOneWidget);

      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();

      expect(find.byType(LoginScreen), findsNothing);
      expect(find.text('Skill berhasil ditambahkan!'), findsNothing);
      expect(requests, 0);
    });

    testWidgets('login berhasil dari Save langsung melanjutkan pengiriman', (
      tester,
    ) async {
      late http.Request posted;
      await openForm(tester, (request) async {
        if (request.url.path == '/api/v1/auth/token/') {
          return jsonResponse({'token': 'fresh-token'});
        }
        posted = request;
        return jsonResponse(createdJson(), status: 201);
      }, loggedInToken: null);

      await fillValidForm(tester);
      await tapSave(tester);

      await tester.enterText(field('Username'), 'owner');
      await tester.enterText(field('Password'), 'rahasia');
      await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
      await tester.pumpAndSettle();

      expect(posted.headers['Authorization'], 'Token fresh-token');
      expect(find.text('Skill berhasil ditambahkan!'), findsOneWidget);
    });
  });
}
