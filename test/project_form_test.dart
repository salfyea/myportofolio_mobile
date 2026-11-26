// Test form Add Project: validasi, POST terautentikasi, dan penanganan galat.

import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/screens/login_screen.dart';
import 'package:myportofolio_mobile/screens/project_form.dart';
import 'package:myportofolio_mobile/screens/project_list.dart';
import 'package:myportofolio_mobile/services/auth_state.dart';
import 'package:provider/provider.dart';

import 'support/test_app.dart';

Map<String, dynamic> createdJson({String title = 'Burhanpedia'}) => {
  'id': 'new-id',
  'title': title,
  'description': 'Toko online',
  'category': 'Web Development',
  'link': 'https://github.com/salfyea',
  'project_image_url': '',
  'star_count': 0,
  'is_starred': false,
  'starred_by_names': '',
};

Finder field(String label) => find.widgetWithText(TextFormField, label);

Future<void> fillValidForm(WidgetTester tester) async {
  await tester.enterText(field('Nama Proyek'), 'Burhanpedia');
  await tester.enterText(field('Deskripsi Proyek'), 'Toko online');
  await tester.enterText(field('Tautan Proyek'), 'https://github.com/salfyea');
}

Future<void> tapSave(WidgetTester tester) async {
  await tester.tap(find.text('Save'));
  await tester.pumpAndSettle();
}

/// Membuka form langsung (tanpa lewat menu) dengan backend [handler].
Future<AuthState> openForm(
  WidgetTester tester,
  MockHandler handler, {
  String? loggedInToken = 'tok',
}) async {
  useTallScreen(tester);
  await tester.pumpWidget(
    testApp(
      client: fakeApiClient(handler),
      loggedInToken: loggedInToken,
      home: const ProjectFormPage(),
    ),
  );
  return tester.element(find.byType(ProjectFormPage)).read<AuthState>();
}

typedef MockHandler = Future<http.Response> Function(http.Request request);

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

      await tester.enterText(field('Nama Proyek'), '   ');
      await tester.enterText(field('Deskripsi Proyek'), '   ');
      await tapSave(tester);

      expect(find.text('Nama proyek tidak boleh kosong!'), findsOneWidget);
      expect(find.text('Deskripsi proyek tidak boleh kosong!'), findsOneWidget);
      expect(requests, 0);
    });

    testWidgets('nama lebih dari 200 karakter dan URL tanpa skema ditolak', (
      tester,
    ) async {
      var requests = 0;
      await openForm(tester, (_) async {
        requests++;
        return jsonResponse(createdJson(), status: 201);
      });

      await tester.enterText(field('Nama Proyek'), 'a' * 201);
      await tester.enterText(field('Deskripsi Proyek'), 'Toko online');
      await tester.enterText(field('Tautan Proyek'), 'github.com/salfyea');
      await tester.enterText(field('URL Gambar Proyek'), 'ftp://x.com/a.png');
      await tapSave(tester);

      expect(
        find.text('Nama proyek terlalu panjang (maksimal 200 karakter).'),
        findsOneWidget,
      );
      expect(find.textContaining('Tautan proyek tidak valid'), findsOneWidget);
      expect(find.textContaining('URL gambar tidak valid'), findsOneWidget);
      expect(requests, 0);
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
      await tester.enterText(
        field('URL Gambar Proyek'),
        'https://example.com/a.png',
      );
      await tapSave(tester);

      expect(seen.method, 'POST');
      expect(seen.url.path, '/api/v1/projects/');
      expect(seen.headers['Authorization'], 'Token tok');
      expect(jsonDecode(seen.body), {
        'title': 'Burhanpedia',
        'description': 'Toko online',
        'category': 'Web Development',
        'link': 'https://github.com/salfyea',
        'project_image_url': 'https://example.com/a.png',
      });
      expect(find.text('Proyek berhasil ditambahkan!'), findsOneWidget);
      expect(find.text('Nama Proyek: Burhanpedia'), findsOneWidget);
    });

    testWidgets('Tambah Lagi mengosongkan form dan mengembalikan kategori', (
      tester,
    ) async {
      await openForm(
        tester,
        (_) async => jsonResponse(createdJson(), status: 201),
      );

      await fillValidForm(tester);
      await tester.tap(find.byType(DropdownButtonFormField<String>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Other').last);
      await tester.pumpAndSettle();
      await tapSave(tester);

      await tester.tap(find.text('Tambah Lagi'));
      await tester.pumpAndSettle();

      expect(find.text('Proyek berhasil ditambahkan!'), findsNothing);
      expect(find.text('Burhanpedia'), findsNothing);
      // Dropdown kembali ke pilihan awal, dan variabel state ikut kembali.
      expect(find.text('Web Development'), findsOneWidget);
    });

    testWidgets('kategori yang dipilih ikut terkirim', (tester) async {
      late Map<String, dynamic> sent;
      await openForm(tester, (request) async {
        sent = jsonDecode(request.body) as Map<String, dynamic>;
        return jsonResponse(createdJson(), status: 201);
      });

      await fillValidForm(tester);
      await tester.tap(find.byType(DropdownButtonFormField<String>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Mobile Development').last);
      await tester.pumpAndSettle();
      await tapSave(tester);

      expect(sent['category'], 'Mobile Development');
    });

    testWidgets('Lihat Daftar membuka daftar yang memuat proyek baru', (
      tester,
    ) async {
      var created = false;
      await openForm(tester, (request) async {
        if (request.method == 'POST') {
          created = true;
          return jsonResponse(createdJson(title: 'Burhanpedia'), status: 201);
        }
        return jsonResponse([if (created) createdJson(title: 'Burhanpedia')]);
      });

      await fillValidForm(tester);
      await tapSave(tester);
      await tester.tap(find.text('Lihat Daftar'));
      await tester.pumpAndSettle();

      expect(find.byType(ProjectListPage), findsOneWidget);
      expect(find.text('Burhanpedia'), findsOneWidget);
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
      expect(find.text('Proyek berhasil ditambahkan!'), findsOneWidget);
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
      expect(find.text('Proyek berhasil ditambahkan!'), findsNothing);
      expect(auth.isLoggedIn, isTrue);
      // Isian tidak hilang, jadi pengguna tidak perlu mengetik ulang.
      expect(find.text('Burhanpedia'), findsOneWidget);
    });

    testWidgets('400 validasi dari server ditampilkan di SnackBar', (
      tester,
    ) async {
      await openForm(
        tester,
        (_) async => jsonResponse({
          'link': ['Enter a valid URL.'],
        }, status: 400),
      );

      await fillValidForm(tester);
      await tapSave(tester);

      expect(find.textContaining('Enter a valid URL.'), findsOneWidget);
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
      expect(find.text('Burhanpedia'), findsOneWidget);
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
      expect(find.byType(ProjectFormPage), findsOneWidget);
      expect(find.text('Burhanpedia'), findsOneWidget);
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
      expect(find.text('Proyek berhasil ditambahkan!'), findsNothing);
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
      expect(find.text('Proyek berhasil ditambahkan!'), findsOneWidget);
    });
  });
}
