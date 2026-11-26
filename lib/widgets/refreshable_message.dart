import 'package:material_ui/material_ui.dart';

/// Pesan di tengah layar yang tetap bisa ditarik untuk memuat ulang.
///
/// Dipakai untuk keadaan daftar kosong. `RefreshIndicator` hanya bereaksi pada
/// isi yang bisa digulir, jadi pesannya dibungkus penggulir setinggi layar;
/// tanpa itu, pengguna tidak punya cara memuat ulang daftar yang kosong.
class RefreshableMessage extends StatelessWidget {
  const RefreshableMessage({
    super.key,
    required this.message,
    required this.onRefresh,
  });

  final String message;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: LayoutBuilder(
        builder: (context, constraints) => SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: SizedBox(
            height: constraints.maxHeight,
            child: Center(child: Text(message)),
          ),
        ),
      ),
    );
  }
}
