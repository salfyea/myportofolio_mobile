// Alat bantu tes: membungkus layar dengan provider yang sama seperti MyApp,
// tetapi memakai ApiClient berbasis MockClient sehingga tidak ada jaringan.

import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:material_ui/material_ui.dart';
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
