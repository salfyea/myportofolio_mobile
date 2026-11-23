// Alat bantu tes: membungkus layar dengan provider yang sama seperti MyApp,
// tetapi memakai ApiClient berbasis MockClient sehingga tidak ada jaringan.

import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:flutter_test/flutter_test.dart';
import 'package:http/testing.dart';
import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/main.dart';
import 'package:myportofolio_mobile/services/api_client.dart';
import 'package:myportofolio_mobile/services/auth_state.dart';
import 'package:provider/provider.dart';

const jsonHeaders = {'content-type': 'application/json; charset=utf-8'};

/// Respons JSON bergaya DRF.
http.Response jsonResponse(Object body, {int status = 200}) =>
    http.Response(jsonEncode(body), status, headers: jsonHeaders);

/// [ApiClient] yang semua permintaannya dijawab oleh [handler].
ApiClient fakeApiClient(MockClientHandler handler) =>
    ApiClient(client: MockClient(handler), baseUrl: 'http://api.test');

/// Layar 800x1400 agar seluruh form dan tombolnya terlihat tanpa menggulir.
void useTallScreen(WidgetTester tester) {
  tester.view.devicePixelRatio = 1.0;
  tester.view.physicalSize = const Size(800, 1400);
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

/// Handler bawaan: daftar proyek kosong; endpoint lain tidak ditemukan.
Future<http.Response> emptyBackend(http.Request request) async {
  if (request.method == 'GET' && request.url.path == '/api/v1/projects/') {
    return jsonResponse(<Object>[]);
  }
  return jsonResponse({'detail': 'Data tidak ditemukan.'}, status: 404);
}

/// Aplikasi utuh ([MyApp]) dengan backend palsu, tanpa jaringan.
///
/// [handler] menjawab semua permintaan HTTP; bawaannya [emptyBackend]. Isi
/// [loggedInToken] untuk memulai dalam keadaan sudah login.
Widget fakeApp({MockClientHandler? handler, String? loggedInToken}) => MyApp(
  apiClient: fakeApiClient(handler ?? emptyBackend),
  initialToken: loggedInToken,
);

/// Membungkus [home] dengan [MaterialApp] dan provider [ApiClient]/[AuthState].
///
/// Bila [auth] tidak diberikan, dibuat [AuthState] baru dari [client]. Isi
/// [loggedInToken] untuk memulai tes dalam keadaan sudah login.
Widget testApp({
  required ApiClient client,
  required Widget home,
  AuthState? auth,
  String? loggedInToken,
}) {
  final state = auth ?? AuthState(client, initialToken: loggedInToken);

  return MultiProvider(
    providers: [
      Provider<ApiClient>.value(value: client),
      ChangeNotifierProvider<AuthState>.value(value: state),
    ],
    child: MaterialApp(home: home),
  );
}
