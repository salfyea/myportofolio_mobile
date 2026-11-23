import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:myportofolio_mobile/models/project.dart';
import 'package:myportofolio_mobile/services/api_client.dart';

const _base = 'http://api.test';
const _json = {'content-type': 'application/json; charset=utf-8'};

const _projectJson = <String, dynamic>{
  'id': 'p-1',
  'title': 'Portfolio',
  'description': 'Situs saya',
  'category': 'Web Development',
  'link': 'https://example.com/',
  'project_image_url': '',
  'star_count': 2,
  'is_starred': false,
  'starred_by_names': 'owner',
};

http.Response _ok(Object body, {int status = 200}) =>
    http.Response(jsonEncode(body), status, headers: _json);

ApiClient _clientWith(MockClientHandler handler) =>
    ApiClient(client: MockClient(handler), baseUrl: _base);

/// Menjalankan [action] dan mengembalikan [ApiException] yang dilemparnya.
Future<ApiException> _failureOf(Future<Object?> Function() action) async {
  try {
    await action();
  } on ApiException catch (error) {
    return error;
  }
  fail('ApiException seharusnya dilempar');
}

void main() {
  group('getProjects', () {
    test(
      'GET publik ke /api/v1/projects/ tanpa header Authorization',
      () async {
        late http.Request seen;
        final client = _clientWith((request) async {
          seen = request;
          return _ok([_projectJson]);
        });

        final projects = await client.getProjects();

        expect(seen.method, 'GET');
        expect(seen.url.toString(), '$_base/api/v1/projects/');
        expect(seen.headers['Accept'], 'application/json');
        expect(seen.headers.containsKey('Authorization'), isFalse);
        expect(projects, hasLength(1));
        expect(projects.single.title, 'Portfolio');
        expect(projects.single.starCount, 2);
      },
    );

    test('daftar kosong menghasilkan list kosong, bukan galat', () async {
      final client = _clientWith((_) async => _ok(<Object>[]));

      expect(await client.getProjects(), isEmpty);
    });

    test(
      'respons non-2xx melempar ApiException, bukan mengembalikan null',
      () async {
        final client = _clientWith(
          (_) async => _ok({'detail': 'Data tidak ditemukan.'}, status: 404),
        );

        final error = await _failureOf(client.getProjects);

        expect(error.statusCode, 404);
        expect(error.message, 'Data tidak ditemukan.');
      },
    );

    test('halaman error HTML tidak diteruskan mentah ke pengguna', () async {
      final client = _clientWith(
        (_) async => http.Response(
          '<html><body>Traceback (most recent call last) ...</body></html>',
          500,
        ),
      );

      final error = await _failureOf(client.getProjects);

      expect(error.statusCode, 500);
      expect(error.message, isNot(contains('Traceback')));
      expect(error.message, contains('Server'));
    });

    test('200 dengan body bukan JSON dianggap tidak terbaca', () async {
      final client = _clientWith((_) async => http.Response('bukan json', 200));

      final error = await _failureOf(client.getProjects);

      expect(error.message, 'Respons server tidak dapat dibaca.');
    });

    test('kegagalan jaringan menjadi ApiException dengan kode 0', () async {
      final client = _clientWith(
        (_) async => throw http.ClientException('Connection refused'),
      );

      final error = await _failureOf(client.getProjects);

      expect(error.statusCode, ApiException.networkErrorCode);
      expect(error.message, contains('terhubung'));
    });

    test('kehabisan waktu juga menjadi galat jaringan', () async {
      final client = _clientWith(
        (_) async => throw TimeoutException('too slow'),
      );

      final error = await _failureOf(client.getProjects);

      expect(error.statusCode, ApiException.networkErrorCode);
    });
  });

  group('createProject', () {
    const draft = Project(
      title: 'Baru',
      description: 'Deskripsi',
      category: 'Other',
      link: 'https://example.com/',
    );

    test('POST membawa token, JSON snake_case, dan tanpa id', () async {
      late http.Request seen;
      final client = _clientWith((request) async {
        seen = request;
        return _ok({
          ..._projectJson,
          'id': 'server-id',
          'title': 'Baru',
        }, status: 201);
      });

      final created = await client.createProject(draft, token: 'abc123');

      expect(seen.method, 'POST');
      expect(seen.url.toString(), '$_base/api/v1/projects/');
      expect(seen.headers['Authorization'], 'Token abc123');
      expect(seen.headers['Content-Type'], contains('application/json'));
      final sent = jsonDecode(seen.body) as Map<String, dynamic>;
      expect(sent['title'], 'Baru');
      expect(sent['project_image_url'], '');
      expect(sent.containsKey('id'), isFalse);
      expect(created.id, 'server-id');
    });

    test(
      '403 dari server menjadi ApiException dengan pesan dari DRF',
      () async {
        final client = _clientWith(
          (_) async => _ok({
            'detail': 'Hanya pemilik portofolio yang dapat menambah data.',
          }, status: 403),
        );

        final error = await _failureOf(
          () => client.createProject(draft, token: 't'),
        );

        expect(error.statusCode, 403);
        expect(error.isUnauthorized, isFalse);
        expect(error.message, contains('pemilik portofolio'));
      },
    );

    test(
      'token yang dicabut menghasilkan 401 yang dikenali isUnauthorized',
      () async {
        final client = _clientWith(
          (_) async => _ok({'detail': 'Invalid token.'}, status: 401),
        );

        final error = await _failureOf(
          () => client.createProject(draft, token: 'revoked'),
        );

        expect(error.isUnauthorized, isTrue);
      },
    );

    test('galat validasi per field digabung menjadi pesan terbaca', () async {
      final client = _clientWith(
        (_) async => _ok({
          'title': ['This field may not be blank.'],
          'link': ['Enter a valid URL.'],
        }, status: 400),
      );

      final error = await _failureOf(
        () => client.createProject(draft, token: 't'),
      );

      expect(error.statusCode, 400);
      expect(error.message, contains('title: This field may not be blank.'));
      expect(error.message, contains('link: Enter a valid URL.'));
    });
  });

  group('obtainToken', () {
    test('mengirim kredensial dan mengembalikan token', () async {
      late http.Request seen;
      final client = _clientWith((request) async {
        seen = request;
        return _ok({'token': 'key-42'});
      });

      final token = await client.obtainToken('owner', 'rahasia');

      expect(seen.method, 'POST');
      expect(seen.url.toString(), '$_base/api/v1/auth/token/');
      expect(seen.headers.containsKey('Authorization'), isFalse);
      expect(jsonDecode(seen.body), {
        'username': 'owner',
        'password': 'rahasia',
      });
      expect(token, 'key-42');
    });

    test('kredensial salah (400) menjadi pesan Indonesia yang ramah', () async {
      final client = _clientWith(
        (_) async => _ok({
          'non_field_errors': ['Unable to log in with provided credentials.'],
        }, status: 400),
      );

      final error = await _failureOf(() => client.obtainToken('x', 'y'));

      expect(error.statusCode, 400);
      expect(error.message, 'Username atau password salah.');
    });

    test(
      'terlalu banyak percobaan (429) tidak disamarkan sebagai password salah',
      () async {
        final client = _clientWith(
          (_) async => _ok({
            'detail': 'Terlalu banyak permintaan. Coba lagi dalam 30 detik.',
          }, status: 429),
        );

        final error = await _failureOf(() => client.obtainToken('x', 'y'));

        expect(error.statusCode, 429);
        expect(error.message, contains('30 detik'));
      },
    );

    test('respons 200 tanpa token dianggap tidak terbaca', () async {
      final client = _clientWith((_) async => _ok({'bukan': 'token'}));

      final error = await _failureOf(() => client.obtainToken('x', 'y'));

      expect(error.message, 'Respons server tidak dapat dibaca.');
    });
  });

  group('logout', () {
    test(
      'POST ke /api/v1/auth/logout/ membawa token dan menerima 204',
      () async {
        late http.Request seen;
        final client = _clientWith((request) async {
          seen = request;
          return http.Response('', 204);
        });

        await client.logout(token: 'key-42');

        expect(seen.method, 'POST');
        expect(seen.url.toString(), '$_base/api/v1/auth/logout/');
        expect(seen.headers['Authorization'], 'Token key-42');
      },
    );

    test('token yang sudah tidak berlaku melempar ApiException 401', () async {
      final client = _clientWith(
        (_) async => _ok({'detail': 'Invalid token.'}, status: 401),
      );

      final error = await _failureOf(() => client.logout(token: 'old'));

      expect(error.isUnauthorized, isTrue);
    });
  });

  test('ApiException.toString memuat kode dan pesan', () {
    expect(
      const ApiException(404, 'Hilang').toString(),
      'ApiException(404): Hilang',
    );
  });
}
