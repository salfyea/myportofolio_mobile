// Test navigasi yang dijaga login: kartu menu dan drawer.

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/screens/login_screen.dart';
import 'package:myportofolio_mobile/screens/project_list.dart';
import 'package:myportofolio_mobile/screens/skill_list.dart';

import 'support/test_app.dart';

const homeText = 'Selamat datang di MyPortfolio Mobile!';

/// Backend palsu: login berhasil, logout 204, satu proyek.
Future<http.Response> backend(http.Request request) async {
  switch ('${request.method} ${request.url.path}') {
    case 'POST /api/v1/auth/token/':
      return jsonResponse({'token': 'tok'});
    case 'POST /api/v1/auth/logout/':
      return http.Response('', 204);
    case 'GET /api/v1/projects/':
      return jsonResponse([
        {
          'id': 'p1',
          'title': 'Proyek Satu',
          'description': 'Deskripsi satu',
          'category': 'Other',
          'link': '',
          'project_image_url': '',
          'star_count': 0,
          'is_starred': false,
          'starred_by_names': '',
        },
      ]);
    case 'GET /api/v1/skills/':
      return jsonResponse([
        {
          'id': 's1',
          'name': 'Skill Satu',
          'icon_url': 'https://example.com/s1.png',
          'category': 'Tool',
          'star_count': 0,
          'is_starred': false,
          'starred_by_names': '',
        },
      ]);
  }
  return jsonResponse({'detail': 'Data tidak ditemukan.'}, status: 404);
}

Future<void> openApp(
  WidgetTester tester, {
  String? loggedInToken,
  MockHandler handler = backend,
}) async {
  tester.view.devicePixelRatio = 1.0;
  tester.view.physicalSize = const Size(800, 1400);
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(
    fakeApp(handler: handler, loggedInToken: loggedInToken),
  );
}

typedef MockHandler = Future<http.Response> Function(http.Request request);

Future<void> logIn(WidgetTester tester) async {
  await tester.enterText(
    find.widgetWithText(TextFormField, 'Username'),
    'owner',
  );
  await tester.enterText(
    find.widgetWithText(TextFormField, 'Password'),
    'rahasia',
  );
  await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
  await tester.pumpAndSettle();
}

Future<void> openDrawer(WidgetTester tester) async {
  await tester.tap(find.byTooltip('Open navigation menu'));
  await tester.pumpAndSettle();
  // Font tes (Ahem) lebih lebar dari font asli sehingga header drawer overflow.
  while (tester.takeException() != null) {}
}

Future<void> tapDrawerItem(WidgetTester tester, String label) async {
  await openDrawer(tester);
  await tester.tap(find.widgetWithText(ListTile, label));
  await tester.pumpAndSettle();
}

Finder card(String label) => find.widgetWithText(InkWell, label);

void main() {
  group('kartu menu', () {
    testWidgets('Tambah Proyek saat logout membuka layar login lebih dulu', (
      tester,
    ) async {
      await openApp(tester);

      await tester.tap(find.text('Tambah Proyek'));
      await tester.pumpAndSettle();

      expect(find.byType(LoginScreen), findsOneWidget);
      expect(find.text('Add Project Form'), findsNothing);
    });

    testWidgets('login berhasil dari kartu melanjutkan ke form proyek', (
      tester,
    ) async {
      await openApp(tester);

      await tester.tap(find.text('Tambah Proyek'));
      await tester.pumpAndSettle();
      await logIn(tester);

      expect(find.byType(LoginScreen), findsNothing);
      expect(find.text('Add Project Form'), findsOneWidget);
    });

    testWidgets('Back dari layar login membatalkan dan tetap di menu', (
      tester,
    ) async {
      await openApp(tester);

      await tester.tap(find.text('Tambah Proyek'));
      await tester.pumpAndSettle();
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();

      expect(find.text(homeText), findsOneWidget);
      expect(find.text('Add Project Form'), findsNothing);
    });

    testWidgets('sudah login: Tambah Proyek langsung membuka form', (
      tester,
    ) async {
      await openApp(tester, loggedInToken: 'tok');

      await tester.tap(find.text('Tambah Proyek'));
      await tester.pumpAndSettle();

      expect(find.byType(LoginScreen), findsNothing);
      expect(find.text('Add Project Form'), findsOneWidget);
    });

    testWidgets('Lihat Proyek membuka daftar dari server tanpa login', (
      tester,
    ) async {
      await openApp(tester);

      await tester.tap(find.text('Lihat Proyek'));
      await tester.pumpAndSettle();

      expect(find.byType(ProjectListPage), findsOneWidget);
      expect(find.text('Proyek Satu'), findsOneWidget);
    });

    testWidgets('Tambah Skill saat logout membuka layar login lebih dulu', (
      tester,
    ) async {
      await openApp(tester);

      await tester.tap(find.text('Tambah Skill'));
      await tester.pumpAndSettle();

      expect(find.byType(LoginScreen), findsOneWidget);
      expect(find.text('Add Skill Form'), findsNothing);
    });

    testWidgets('login berhasil dari kartu melanjutkan ke form skill', (
      tester,
    ) async {
      await openApp(tester);

      await tester.tap(find.text('Tambah Skill'));
      await tester.pumpAndSettle();
      await logIn(tester);

      expect(find.byType(LoginScreen), findsNothing);
      expect(find.text('Add Skill Form'), findsOneWidget);
    });

    testWidgets('sudah login: Tambah Skill langsung membuka form', (
      tester,
    ) async {
      await openApp(tester, loggedInToken: 'tok');

      await tester.tap(find.text('Tambah Skill'));
      await tester.pumpAndSettle();

      expect(find.byType(LoginScreen), findsNothing);
      expect(find.text('Add Skill Form'), findsOneWidget);
    });

    testWidgets('Lihat Skills membuka daftar dari server tanpa login', (
      tester,
    ) async {
      await openApp(tester);

      await tester.tap(find.text('Lihat Skills'));
      await tester.pumpAndSettle();

      expect(find.byType(SkillListPage), findsOneWidget);
      expect(find.text('Skill Satu'), findsOneWidget);
    });

    testWidgets('kartu Login masuk, lalu berganti menjadi Logout', (
      tester,
    ) async {
      await openApp(tester);
      expect(find.text('Logout'), findsNothing);

      await tester.tap(find.text('Login'));
      await tester.pumpAndSettle();
      await logIn(tester);

      expect(find.text(homeText), findsOneWidget);
      expect(find.text('Login berhasil.'), findsOneWidget);
      expect(find.text('Logout'), findsOneWidget);
      expect(find.text('Login'), findsNothing);
    });

    testWidgets('kartu Logout mencabut token dan kembali menjadi Login', (
      tester,
    ) async {
      final calls = <String>[];
      await openApp(
        tester,
        loggedInToken: 'tok',
        handler: (request) {
          calls.add('${request.method} ${request.url.path}');
          return backend(request);
        },
      );

      await tester.tap(find.text('Logout'));
      await tester.pumpAndSettle();

      expect(calls, contains('POST /api/v1/auth/logout/'));
      expect(find.text('Kamu telah logout.'), findsOneWidget);
      expect(find.text('Login'), findsOneWidget);
      expect(find.text('Logout'), findsNothing);
    });

    testWidgets('Logout tetap berhasil secara lokal walau server gagal', (
      tester,
    ) async {
      await openApp(
        tester,
        loggedInToken: 'tok',
        handler: (request) async =>
            throw http.ClientException('Connection refused'),
      );

      await tester.tap(find.text('Logout'));
      await tester.pumpAndSettle();

      expect(find.text('Login'), findsOneWidget);
      expect(find.text('Logout'), findsNothing);
    });
  });

  group('drawer', () {
    testWidgets('menawarkan Login saat logout dan Logout saat login', (
      tester,
    ) async {
      await openApp(tester);
      await openDrawer(tester);
      expect(find.widgetWithText(ListTile, 'Login'), findsOneWidget);
      expect(find.widgetWithText(ListTile, 'Logout'), findsNothing);
    });

    testWidgets('Projects membuka daftar proyek', (tester) async {
      await openApp(tester);

      await tapDrawerItem(tester, 'Projects');

      expect(find.byType(ProjectListPage), findsOneWidget);
      expect(find.text('Proyek Satu'), findsOneWidget);
    });

    testWidgets('Skills membuka daftar skill', (tester) async {
      await openApp(tester);

      await tapDrawerItem(tester, 'Skills');

      expect(find.byType(SkillListPage), findsOneWidget);
      expect(find.text('Skill Satu'), findsOneWidget);
    });

    testWidgets('Add Skill saat logout meminta login, lalu membuka form', (
      tester,
    ) async {
      await openApp(tester);

      await tapDrawerItem(tester, 'Add Skill');
      expect(find.byType(LoginScreen), findsOneWidget);

      await logIn(tester);

      expect(find.text('Add Skill Form'), findsOneWidget);
    });

    testWidgets('Back dari login membatalkan perpindahan ke Add Skill', (
      tester,
    ) async {
      await openApp(tester);

      await tapDrawerItem(tester, 'Add Skill');
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();

      expect(find.text(homeText), findsOneWidget);
      expect(find.text('Add Skill Form'), findsNothing);
    });

    testWidgets('Add Project saat logout meminta login, lalu membuka form', (
      tester,
    ) async {
      await openApp(tester);

      await tapDrawerItem(tester, 'Add Project');
      expect(find.byType(LoginScreen), findsOneWidget);

      await logIn(tester);

      expect(find.text('Add Project Form'), findsOneWidget);
    });

    testWidgets('Back dari login membatalkan perpindahan halaman', (
      tester,
    ) async {
      await openApp(tester);

      await tapDrawerItem(tester, 'Add Project');
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();

      expect(find.text(homeText), findsOneWidget);
      expect(find.text('Add Project Form'), findsNothing);
    });

    testWidgets('Login dari drawer menutup drawer dan memberi kabar', (
      tester,
    ) async {
      await openApp(tester);

      await tapDrawerItem(tester, 'Login');
      await logIn(tester);

      expect(find.byType(Drawer), findsNothing);
      expect(find.text('Login berhasil.'), findsOneWidget);
      expect(find.text('Logout'), findsOneWidget);
    });

    testWidgets('Logout dari drawer mencabut token dan memberi kabar', (
      tester,
    ) async {
      await openApp(tester, loggedInToken: 'tok');

      await tapDrawerItem(tester, 'Logout');

      expect(find.byType(Drawer), findsNothing);
      expect(find.text('Kamu telah logout.'), findsOneWidget);
      expect(find.text('Login'), findsOneWidget);
    });
  });
}
