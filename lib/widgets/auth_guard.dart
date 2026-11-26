import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/screens/login_screen.dart';
import 'package:myportofolio_mobile/services/api_client.dart';
import 'package:myportofolio_mobile/services/auth_state.dart';
import 'package:provider/provider.dart';

/// Memastikan pengguna sudah login sebelum membuka layar atau aksi terlindungi.
///
/// Bila sudah login, langsung mengembalikan `true`. Bila belum, membuka
/// [LoginScreen] dan mengembalikan `true` hanya jika pengguna berhasil login;
/// menekan Back di layar login menghasilkan `false`.
///
/// Contoh: `if (!await ensureLoggedIn(context)) return;`
Future<bool> ensureLoggedIn(BuildContext context) async {
  if (context.read<AuthState>().isLoggedIn) {
    return true;
  }

  final loggedIn = await Navigator.push<bool>(
    context,
    MaterialPageRoute<bool>(builder: (_) => const LoginScreen()),
  );

  return loggedIn ?? false;
}

/// Menampilkan kegagalan permintaan API yang terautentikasi.
///
/// Pesan [error] selalu tampil di SnackBar. Bila server menjawab 401 (token
/// dicabut atau tidak berlaku), sesi lokal dihapus dan pengguna diminta login
/// ulang; setelah berhasil, [retryHint] memberi tahu apa yang harus ditekan
/// lagi. Pemanggil wajib memastikan `context.mounted` sebelum memanggil ini.
///
/// Dipakai bersama oleh semua aksi tulis (kirim form, edit, hapus) supaya
/// penanganan 401 tidak ditulis ulang di tiap layar.
Future<void> handleApiFailure(
  BuildContext context,
  ApiException error, {
  required String retryHint,
}) async {
  // Diambil sebelum await: context tidak boleh dipakai sesudahnya tanpa
  // memeriksa `mounted`.
  final messenger = ScaffoldMessenger.of(context);
  final auth = context.read<AuthState>();

  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(error.message)));

  if (!error.isUnauthorized) {
    return;
  }

  // Token sudah ditolak server, jadi tidak ada yang perlu dicabut.
  auth.clearSession();
  if (await ensureLoggedIn(context) && context.mounted) {
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(retryHint)));
  }
}
