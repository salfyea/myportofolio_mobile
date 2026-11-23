// Test autentikasi token: AuthState, LoginScreen, dan guard ensureLoggedIn.

import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/screens/login_screen.dart';
import 'package:myportofolio_mobile/services/api_client.dart';
import 'package:myportofolio_mobile/services/auth_state.dart';
import 'package:myportofolio_mobile/widgets/auth_guard.dart';

import 'support/test_app.dart';

/// Wadah hasil `ensureLoggedIn`; `null` berarti guard belum selesai.
class GuardResult {
  bool? value;
}

void main() {
  group('AuthState', () {
    test('login menyimpan token dan memberi tahu listener', () async {
      final auth = AuthState(
        fakeApiClient((_) async => jsonResponse({'token': 'key-1'})),
      );
      var notified = 0;
      auth.addListener(() => notified++);

      expect(auth.isLoggedIn, isFalse);
      await auth.login('owner', 'rahasia');

      expect(auth.isLoggedIn, isTrue);
      expect(auth.token, 'key-1');
      expect(notified, 1);
    });

    test('login yang ditolak melempar ApiException dan tetap logout', () async {
      final auth = AuthState(
        fakeApiClient(
          (_) async => jsonResponse({
            'non_field_errors': ['Unable to log in.'],
          }, status: 400),
        ),
      );

      await expectLater(
        auth.login('owner', 'salah'),
        throwsA(isA<ApiException>()),
      );
      expect(auth.isLoggedIn, isFalse);
      expect(auth.token, isNull);
    });

    test('logout mencabut token di server lalu menghapusnya', () async {
      late http.Request seen;
      final auth = AuthState(
        fakeApiClient((request) async {
          seen = request;
          return http.Response('', 204);
        }),
        initialToken: 'key-1',
      );

      await auth.logout();

      expect(seen.url.path, '/api/v1/auth/logout/');
      expect(seen.headers['Authorization'], 'Token key-1');
      expect(auth.isLoggedIn, isFalse);
    });

    test('logout tetap menghapus sesi walau server gagal', () async {
      final auth = AuthState(
        fakeApiClient(
          (_) async => throw http.ClientException('Connection refused'),
        ),
        initialToken: 'key-1',
      );
      var notified = 0;
      auth.addListener(() => notified++);

      await auth.logout();

      expect(auth.isLoggedIn, isFalse);
      expect(notified, 1);
    });

    test('logout saat belum login tidak mengirim permintaan apa pun', () async {
      var requests = 0;
      final auth = AuthState(
        fakeApiClient((_) async {
          requests++;
          return http.Response('', 204);
        }),
      );

      await auth.logout();

      expect(requests, 0);
    });

    test('clearSession menghapus sesi tanpa menghubungi server', () {
      var requests = 0;
      final auth = AuthState(
        fakeApiClient((_) async {
          requests++;
          return http.Response('', 204);
        }),
        initialToken: 'key-1',
      );
      var notified = 0;
      auth.addListener(() => notified++);

      auth.clearSession();
      auth.clearSession(); // kedua kali: tidak ada yang berubah

      expect(auth.isLoggedIn, isFalse);
      expect(notified, 1);
      expect(requests, 0);
    });
  });

  group('LoginScreen', () {
    Future<void> openLogin(WidgetTester tester, ApiClient client) async {
      await tester.pumpWidget(
        testApp(client: client, home: const LoginScreen()),
      );
    }

    testWidgets('isian kosong menampilkan pesan dan tidak mengirim apa pun', (
      tester,
    ) async {
      var requests = 0;
      await openLogin(
        tester,
        fakeApiClient((_) async {
          requests++;
          return jsonResponse({'token': 'x'});
        }),
      );

      await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
      await tester.pump();

      expect(find.text('Username tidak boleh kosong!'), findsOneWidget);
      expect(find.text('Password tidak boleh kosong!'), findsOneWidget);
      expect(requests, 0);
    });

    testWidgets('password disamarkan', (tester) async {
      await openLogin(tester, fakeApiClient((_) async => jsonResponse({})));

      final password = tester.widget<TextField>(
        find.descendant(
          of: find.widgetWithText(TextFormField, 'Password'),
          matching: find.byType(TextField),
        ),
      );

      expect(password.obscureText, isTrue);
    });

    testWidgets('kredensial salah menampilkan SnackBar dan tetap di layar', (
      tester,
    ) async {
      await openLogin(
        tester,
        fakeApiClient(
          (_) async => jsonResponse({
            'non_field_errors': ['Unable to log in.'],
          }, status: 400),
        ),
      );

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Username'),
        'owner',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Password'),
        'salah',
      );
      await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
      await tester.pumpAndSettle();

      expect(find.text('Username atau password salah.'), findsOneWidget);
      expect(find.byType(LoginScreen), findsOneWidget);
      // Tombol aktif lagi setelah gagal.
      expect(
        tester
            .widget<ElevatedButton>(
              find.widgetWithText(ElevatedButton, 'Login'),
            )
            .onPressed,
        isNotNull,
      );
    });

    testWidgets(
      'mengirim username yang sudah dipangkas dan password apa adanya',
      (tester) async {
        late Map<String, dynamic> sent;
        await openLogin(
          tester,
          fakeApiClient((request) async {
            sent = jsonDecode(request.body) as Map<String, dynamic>;
            return jsonResponse({'token': 'key-9'});
          }),
        );

        await tester.enterText(
          find.widgetWithText(TextFormField, 'Username'),
          '  owner  ',
        );
        await tester.enterText(
          find.widgetWithText(TextFormField, 'Password'),
          ' pass word ',
        );
        await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
        await tester.pump();
        await tester.pumpAndSettle();

        expect(sent, {'username': 'owner', 'password': ' pass word '});
      },
    );

    testWidgets('tombol menampilkan spinner dan nonaktif selagi mengirim', (
      tester,
    ) async {
      final reply = Completer<http.Response>();
      await openLogin(tester, fakeApiClient((_) => reply.future));

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Username'),
        'owner',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Password'),
        'rahasia',
      );
      await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(
        tester.widget<ElevatedButton>(find.byType(ElevatedButton)).onPressed,
        isNull,
      );

      reply.complete(jsonResponse({'token': 'k'}));
      await tester.pumpAndSettle();
    });
  });

  group('ensureLoggedIn', () {
    /// Memasang halaman dengan satu tombol yang memanggil guard; hasil guard
    /// disimpan di [GuardResult.value] (`null` selama belum selesai).
    Future<GuardResult> pumpGuardPage(
      WidgetTester tester, {
      required ApiClient client,
      String? loggedInToken,
    }) async {
      final result = GuardResult();
      await tester.pumpWidget(
        testApp(
          client: client,
          loggedInToken: loggedInToken,
          home: Builder(
            builder: (context) => Scaffold(
              body: ElevatedButton(
                onPressed: () async =>
                    result.value = await ensureLoggedIn(context),
                child: const Text('Aksi terlindungi'),
              ),
            ),
          ),
        ),
      );
      return result;
    }

    testWidgets('sudah login: langsung true tanpa membuka layar login', (
      tester,
    ) async {
      final result = await pumpGuardPage(
        tester,
        client: fakeApiClient((_) async => jsonResponse({})),
        loggedInToken: 'key-1',
      );
      await tester.pump();

      await tester.tap(find.text('Aksi terlindungi'));
      await tester.pumpAndSettle();

      expect(find.byType(LoginScreen), findsNothing);
      expect(result.value, isTrue);
    });

    testWidgets('belum login: membuka layar login dan true setelah berhasil', (
      tester,
    ) async {
      final result = await pumpGuardPage(
        tester,
        client: fakeApiClient((_) async => jsonResponse({'token': 'key-1'})),
      );
      await tester.pump();

      await tester.tap(find.text('Aksi terlindungi'));
      await tester.pumpAndSettle();
      expect(find.byType(LoginScreen), findsOneWidget);

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

      expect(find.byType(LoginScreen), findsNothing);
      expect(result.value, isTrue);
    });

    testWidgets('belum login lalu Back: hasilnya false', (tester) async {
      final result = await pumpGuardPage(
        tester,
        client: fakeApiClient((_) async => jsonResponse({})),
      );
      await tester.pump();

      await tester.tap(find.text('Aksi terlindungi'));
      await tester.pumpAndSettle();
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();

      expect(find.byType(LoginScreen), findsNothing);
      expect(result.value, isFalse);
    });
  });
}
