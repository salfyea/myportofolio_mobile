/// State sesi login yang dibagikan ke seluruh aplikasi lewat `provider`.
library;

import 'package:flutter/foundation.dart';
import 'package:myportofolio_mobile/services/api_client.dart';

/// Menyimpan token autentikasi sesi ini **di memori saja**.
///
/// Token tidak ditulis ke penyimpanan, jadi menutup aplikasi sama dengan
/// logout. Widget membaca [isLoggedIn] lewat `context.watch<AuthState>()`
/// supaya drawer dan kartu ikut berubah saat login atau logout, dan memakai
/// `context.read<AuthState>()` untuk memanggil aksi.
class AuthState extends ChangeNotifier {
  AuthState(this._apiClient, {String? initialToken}) : _token = initialToken;

  final ApiClient _apiClient;
  String? _token;

  /// Token untuk header `Authorization: Token <key>`, atau `null` bila belum login.
  String? get token => _token;

  bool get isLoggedIn => _token != null;

  /// Menukar [username] dan [password] menjadi token. Melempar [ApiException]
  /// bila ditolak (kredensial salah, terlalu banyak percobaan, atau jaringan).
  Future<void> login(String username, String password) async {
    _token = await _apiClient.obtainToken(username, password);
    notifyListeners();
  }

  /// Keluar: mencabut token di server lalu menghapusnya dari memori.
  ///
  /// Sesi lokal **selalu** dihapus, juga ketika permintaan ke server gagal.
  /// Pengguna yang menekan Logout tidak boleh tetap terlihat login hanya karena
  /// jaringan sedang bermasalah atau tokennya memang sudah dicabut.
  Future<void> logout() async {
    final current = _token;
    if (current == null) {
      return;
    }

    try {
      await _apiClient.logout(token: current);
    } on ApiException {
      // Token sudah tidak berlaku atau server tak terjangkau; tujuan akhirnya
      // (tidak lagi login di aplikasi ini) tetap tercapai di blok finally.
    } finally {
      _token = null;
      notifyListeners();
    }
  }

  /// Menghapus sesi lokal tanpa menghubungi server.
  ///
  /// Dipakai saat server menjawab 401: token sudah ditolak, jadi tidak ada
  /// yang perlu dicabut dan pengguna tinggal diminta login ulang.
  void clearSession() {
    if (_token == null) {
      return;
    }

    _token = null;
    notifyListeners();
  }
}
