/// Klien HTTP untuk backend Django REST Framework MyPortfolio.
///
/// Semua pemanggilan jaringan dikumpulkan di sini, bukan di dalam widget, agar
/// layar hanya mengurus tampilan. Kegagalan selalu dilempar sebagai
/// [ApiException] (bukan `null`), sehingga pemanggil wajib memutuskan
/// tampilannya: pesan error, tombol Retry, atau login ulang.
///
/// Kunci header memakai string biasa, bukan `HttpHeaders` dari `dart:io`,
/// karena mengimpor `dart:io` merusak build Flutter Web.
library;

import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:myportofolio_mobile/config.dart';
import 'package:myportofolio_mobile/models/project.dart';
import 'package:myportofolio_mobile/models/skill.dart';

/// Galat dari pemanggilan API.
///
/// [statusCode] adalah kode HTTP, atau [networkErrorCode] bila permintaan tidak
/// sampai ke server (tidak ada koneksi, server mati, atau kehabisan waktu).
/// [message] sudah berupa kalimat yang aman ditampilkan kepada pengguna: halaman
/// error HTML atau stack trace server (saat `DEBUG=True` di Django) tidak pernah
/// diteruskan mentah.
class ApiException implements Exception {
  const ApiException(this.statusCode, this.message);

  /// Membangun [ApiException] dari respons non-2xx.
  factory ApiException.fromResponse(http.Response response) {
    final status = response.statusCode;
    // DRF selalu mengirim UTF-8, sedangkan `response.body` memakai latin1 bila
    // header tidak menyebut charset.
    final body = utf8.decode(response.bodyBytes, allowMalformed: true);
    return ApiException(
      status,
      _messageFromBody(body) ?? _fallbackMessage(status),
    );
  }

  /// Nilai [statusCode] untuk permintaan yang gagal sebelum ada respons.
  static const int networkErrorCode = 0;

  final int statusCode;
  final String message;

  /// Token ditolak atau sudah dicabut sehingga pengguna harus login ulang.
  bool get isUnauthorized => statusCode == 401;

  @override
  String toString() => 'ApiException($statusCode): $message';
}

/// Mengambil pesan dari body galat DRF, atau `null` bila bukan JSON yang dikenal.
///
/// DRF mengirim `{"detail": "..."}` untuk galat umum dan
/// `{"field": ["pesan", ...]}` untuk galat validasi.
String? _messageFromBody(String body) {
  final Object? decoded;
  try {
    decoded = jsonDecode(body);
  } on FormatException {
    return null;
  }
  if (decoded is! Map<String, dynamic>) return null;

  final detail = decoded['detail'];
  if (detail is String && detail.isNotEmpty) return detail;

  final lines = <String>[];
  decoded.forEach((field, value) {
    final text = value is List ? value.join(' ') : '$value';
    lines.add(field == 'non_field_errors' ? text : '$field: $text');
  });
  return lines.isEmpty ? null : lines.join('\n');
}

String _fallbackMessage(int status) {
  if (status == 401) return 'Sesi login berakhir. Silakan login kembali.';
  if (status == 403) return 'Kamu tidak punya izin untuk tindakan ini.';
  if (status == 404) return 'Data tidak ditemukan.';
  if (status == 429) return 'Terlalu banyak permintaan. Coba lagi sebentar.';
  if (status >= 500) return 'Server sedang bermasalah. Coba lagi nanti.';
  return 'Permintaan gagal (kode $status).';
}

/// Klien HTTP untuk endpoint `/api/v1/` milik backend MyPortfolio.
class ApiClient {
  ApiClient({http.Client? client, this.baseUrl = apiBaseUrl})
    : _client = client ?? http.Client();

  /// Batas waktu tiap permintaan, supaya layar tidak menunggu selamanya.
  static const Duration requestTimeout = Duration(seconds: 20);

  final http.Client _client;
  final String baseUrl;

  Uri _uri(String path) => Uri.parse('$baseUrl$path');

  static Map<String, String> _jsonHeaders({String? token}) => {
    'Accept': 'application/json',
    'Content-Type': 'application/json; charset=UTF-8',
    if (token != null) 'Authorization': 'Token $token',
  };

  /// Mengambil semua proyek. Publik, tidak perlu login.
  Future<List<Project>> getProjects() =>
      _getList('/api/v1/projects/', Project.fromJson);

  /// Membuat proyek baru. Hanya pemilik portofolio (superuser) yang diizinkan,
  /// dan permintaan wajib membawa [token] hasil [obtainToken].
  Future<Project> createProject(Project project, {required String token}) =>
      _sendObject(
        () => _client.post(
          _uri('/api/v1/projects/'),
          headers: _jsonHeaders(token: token),
          body: jsonEncode(project.toJson()),
        ),
        Project.fromJson,
      );

  /// Mengambil semua skill. Publik, tidak perlu login.
  Future<List<Skill>> getSkills() =>
      _getList('/api/v1/skills/', Skill.fromJson);

  /// Membuat skill baru (`POST /api/v1/skills/`). Hanya pemilik portofolio
  /// yang diizinkan, dan permintaan wajib membawa [token] hasil [obtainToken].
  Future<Skill> createSkill(Skill skill, {required String token}) =>
      _sendObject(
        () => _client.post(
          _uri('/api/v1/skills/'),
          headers: _jsonHeaders(token: token),
          body: jsonEncode(skill.toJson()),
        ),
        Skill.fromJson,
      );

  /// Mengubah skill yang sudah ada (`PATCH /api/v1/skills/<id>/`).
  ///
  /// [skill] harus berasal dari server (punya `id`). Hanya pemilik atau Editor
  /// yang diizinkan; akun lain mendapat 403.
  Future<Skill> updateSkill(Skill skill, {required String token}) async {
    final id = skill.id;
    if (id == null) {
      throw ArgumentError.value(
        skill,
        'skill',
        'Skill yang diubah harus sudah punya id dari server.',
      );
    }

    return await _sendObject(
      () => _client.patch(
        _uri('/api/v1/skills/${Uri.encodeComponent(id)}/'),
        headers: _jsonHeaders(token: token),
        body: jsonEncode(skill.toJson()),
      ),
      Skill.fromJson,
    );
  }

  /// Menghapus skill ber-[id] (`DELETE /api/v1/skills/<id>/`, 204 No Content).
  /// Hanya pemilik portofolio yang diizinkan.
  Future<void> deleteSkill(String id, {required String token}) async {
    await _send(
      () => _client.delete(
        _uri('/api/v1/skills/${Uri.encodeComponent(id)}/'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Token $token',
        },
      ),
    );
  }

  /// Menukar [username] dan [password] menjadi token API.
  Future<String> obtainToken(String username, String password) async {
    final http.Response response;
    try {
      response = await _send(
        () => _client.post(
          _uri('/api/v1/auth/token/'),
          headers: _jsonHeaders(),
          body: jsonEncode({'username': username, 'password': password}),
        ),
      );
    } on ApiException catch (error) {
      // DRF menjawab 400 dengan kalimat Inggris untuk kredensial yang salah.
      if (error.statusCode == 400) {
        throw const ApiException(400, 'Username atau password salah.');
      }
      rethrow;
    }

    final decoded = _decodeJson(response);
    final token = decoded is Map<String, dynamic> ? decoded['token'] : null;
    if (token is! String) throw _unreadable(response.statusCode);
    return token;
  }

  /// Mencabut [token] di server (204 No Content).
  Future<void> logout({required String token}) async {
    await _send(
      () => _client.post(
        _uri('/api/v1/auth/logout/'),
        headers: _jsonHeaders(token: token),
      ),
    );
  }

  /// GET publik ke [path] yang menjawab daftar objek, dipetakan lewat [fromJson].
  Future<List<T>> _getList<T>(
    String path,
    T Function(Map<String, dynamic> json) fromJson,
  ) async {
    final response = await _send(
      () => _client.get(
        _uri(path),
        headers: const {'Accept': 'application/json'},
      ),
    );

    final decoded = _decodeJson(response);
    if (decoded is! List<dynamic>) throw _unreadable(response.statusCode);
    return [for (final item in decoded) fromJson(item as Map<String, dynamic>)];
  }

  /// Menjalankan [request] yang menjawab satu objek JSON, dipetakan lewat
  /// [fromJson].
  Future<T> _sendObject<T>(
    Future<http.Response> Function() request,
    T Function(Map<String, dynamic> json) fromJson,
  ) async {
    final response = await _send(request);

    final decoded = _decodeJson(response);
    if (decoded is! Map<String, dynamic>) {
      throw _unreadable(response.statusCode);
    }
    return fromJson(decoded);
  }

  /// Menjalankan [request], mengubah kegagalan jaringan dan respons non-2xx
  /// menjadi [ApiException].
  Future<http.Response> _send(Future<http.Response> Function() request) async {
    final http.Response response;
    try {
      response = await request().timeout(requestTimeout);
    } on Exception {
      // Tidak ada koneksi, server mati, DNS gagal, atau kehabisan waktu.
      throw const ApiException(
        ApiException.networkErrorCode,
        'Tidak dapat terhubung ke server. Periksa koneksi lalu coba lagi.',
      );
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException.fromResponse(response);
    }
    return response;
  }

  Object? _decodeJson(http.Response response) {
    try {
      return jsonDecode(utf8.decode(response.bodyBytes));
    } on FormatException {
      throw _unreadable(response.statusCode);
    }
  }

  ApiException _unreadable(int status) =>
      ApiException(status, 'Respons server tidak dapat dibaca.');
}
