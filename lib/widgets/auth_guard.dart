import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/screens/login_screen.dart';
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
