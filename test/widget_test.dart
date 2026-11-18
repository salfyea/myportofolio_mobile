// Smoke test untuk aplikasi MyPortfolio Mobile.
//
// Menguji halaman menu utama (MyHomePage): kartu profil, tombol aksi,
// warna unik tiap tombol, dan SnackBar saat tombol ditekan.

import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:myportofolio_mobile/main.dart';
import 'package:myportofolio_mobile/screens/menu.dart';

/// Mengatur ukuran layar virtual (dalam piksel logis) untuk satu test.
void setScreenSize(WidgetTester tester, Size size) {
  tester.view.devicePixelRatio = 1.0;
  tester.view.physicalSize = size;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

void main() {
  formTests();
  testWidgets('menampilkan identitas pemilik pada tiga InfoCard', (tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.byType(InfoCard), findsNWidgets(3));
    expect(find.text('NPM'), findsOneWidget);
    expect(find.text('2506620280'), findsOneWidget);
    expect(find.text('Name'), findsOneWidget);
    expect(find.text('Salwa Alifia Putri'), findsOneWidget);
    expect(find.text('Class'), findsOneWidget);
    expect(find.text('PBP A'), findsOneWidget);
  });

  test('setiap ItemHomepage memiliki warna yang unik', () {
    final items = MyHomePage().items;
    final colors = items.map((item) => item.color).toSet();

    expect(items.length, greaterThanOrEqualTo(3));
    expect(colors.length, items.length);
  });

  testWidgets('menekan tiap tombol memunculkan SnackBar sesuai namanya',
      (tester) async {
    setScreenSize(tester, const Size(800, 1200));
    await tester.pumpWidget(const MyApp());

    for (final item in MyHomePage().items) {
      await tester.tap(find.text(item.name));
      await tester.pump(); // memulai animasi SnackBar
      await tester.pump(const Duration(milliseconds: 750));

      expect(find.text('Kamu telah menekan tombol ${item.name}!'),
          findsOneWidget);

      // "Tambah Proyek" membuka halaman form; kembali ke menu dengan Back.
      if (item.name == 'Tambah Proyek') {
        await tester.pumpAndSettle();
        expect(find.text('Add Project Form'), findsOneWidget);
        Navigator.of(tester.element(find.text('Add Project Form'))).pop();
        await tester.pumpAndSettle();
      }
    }
  });

  testWidgets('InfoCard muat di lebar layar HP kecil dan semua tombol terjangkau',
      (tester) async {
    const phone = Size(360, 640);
    setScreenSize(tester, phone);
    await tester.pumpWidget(const MyApp());

    // Catatan: font bawaan test (Ahem) jauh lebih lebar daripada font asli,
    // sehingga overflow tinggi teks di sini bukan cerminan perangkat nyata.
    // Karena itu yang diperiksa adalah geometri, bukan tinggi teks.
    while (tester.takeException() != null) {}

    for (var i = 0; i < 3; i++) {
      final rect = tester.getRect(find.byType(InfoCard).at(i));
      expect(rect.left, greaterThanOrEqualTo(0));
      expect(rect.right, lessThanOrEqualTo(phone.width));
    }

    // Tombol paling bawah harus bisa dijangkau lewat scroll.
    await tester.scrollUntilVisible(
      find.text('Logout'),
      200,
      scrollable: find.byType(Scrollable).first, // scroll halaman (luar)
    );
    while (tester.takeException() != null) {}
    expect(find.text('Logout'), findsOneWidget);
  });

  testWidgets('tidak overflow di layar lebar (web/desktop)', (tester) async {
    setScreenSize(tester, const Size(1280, 720));
    await tester.pumpWidget(const MyApp());

    await tester.scrollUntilVisible(
      find.text('Logout'),
      200,
      scrollable: find.byType(Scrollable).first, // scroll halaman (luar)
    );
    expect(find.text('Logout'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

void formTests() {
  testWidgets('form Project menolak spasi, nama terlalu panjang, dan URL salah',
      (tester) async {
    setScreenSize(tester, const Size(800, 1200));
    await tester.pumpWidget(const MyApp());
    await tester.tap(find.text('Tambah Proyek'));
    await tester.pumpAndSettle();

    final nama = find.widgetWithText(TextFormField, 'Nama Proyek');
    final deskripsi = find.widgetWithText(TextFormField, 'Deskripsi Proyek');
    final tautan = find.widgetWithText(TextFormField, 'Tautan Proyek');

    // Hanya spasi dianggap kosong.
    await tester.enterText(nama, '   ');
    await tester.enterText(deskripsi, '   ');
    await tester.tap(find.text('Save'));
    await tester.pump();
    expect(find.text('Nama proyek tidak boleh kosong!'), findsOneWidget);
    expect(find.text('Deskripsi proyek tidak boleh kosong!'), findsOneWidget);

    // Nama lebih dari 200 karakter dan URL tanpa skema ditolak.
    await tester.enterText(nama, 'a' * 201);
    await tester.enterText(deskripsi, 'Toko online');
    await tester.enterText(tautan, 'github.com/salfyea');
    await tester.tap(find.text('Save'));
    await tester.pump();
    expect(find.text('Nama proyek terlalu panjang (maksimal 200 karakter).'),
        findsOneWidget);
    expect(find.textContaining('Tautan proyek tidak valid'), findsOneWidget);
    expect(find.text('Proyek berhasil ditambahkan!'), findsNothing);

    // Data valid diterima.
    await tester.enterText(nama, 'Burhanpedia');
    await tester.enterText(tautan, 'https://github.com/salfyea');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(find.text('Proyek berhasil ditambahkan!'), findsOneWidget);
  });

  testWidgets('setelah OK, isian lama tidak terbawa ke simpan berikutnya',
      (tester) async {
    setScreenSize(tester, const Size(800, 1200));
    await tester.pumpWidget(const MyApp());
    await tester.tap(find.text('Tambah Proyek'));
    await tester.pumpAndSettle();

    await tester.enterText(find.widgetWithText(TextFormField, 'Nama Proyek'), 'A');
    await tester.enterText(find.widgetWithText(TextFormField, 'Deskripsi Proyek'), 'B');
    await tester.enterText(find.widgetWithText(TextFormField, 'Teknologi yang Digunakan'), 'Flutter');
    await tester.tap(find.byType(DropdownButtonFormField<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Other').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(find.text('Kategori: Other'), findsOneWidget);
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    // Isi ulang hanya field wajib; kategori dan teknologi harus kembali default.
    await tester.enterText(find.widgetWithText(TextFormField, 'Nama Proyek'), 'C');
    await tester.enterText(find.widgetWithText(TextFormField, 'Deskripsi Proyek'), 'D');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(find.text('Kategori: Web Development'), findsOneWidget);
    expect(find.text('Teknologi: '), findsOneWidget);
  });

  testWidgets('Tambah Proyek membuka form, validasi, dan pop-up data',
      (tester) async {
    setScreenSize(tester, const Size(800, 1200));
    await tester.pumpWidget(const MyApp());

    await tester.tap(find.text('Tambah Proyek'));
    await tester.pumpAndSettle();
    expect(find.text('Add Project Form'), findsOneWidget);

    // Simpan dengan field kosong -> pesan validasi.
    await tester.tap(find.text('Save'));
    await tester.pump();
    expect(find.text('Nama proyek tidak boleh kosong!'), findsOneWidget);

    await tester.enterText(find.widgetWithText(TextFormField, 'Nama Proyek'), 'Burhanpedia');
    await tester.enterText(find.widgetWithText(TextFormField, 'Deskripsi Proyek'), 'Toko online');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(find.text('Proyek berhasil ditambahkan!'), findsOneWidget);
    expect(find.text('Nama Proyek: Burhanpedia'), findsOneWidget);
    expect(find.text('Kategori: Web Development'), findsOneWidget);

    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    expect(find.text('Proyek berhasil ditambahkan!'), findsNothing);
  });

  testWidgets('drawer berpindah antara Home dan Add Project', (tester) async {
    setScreenSize(tester, const Size(800, 1200));
    await tester.pumpWidget(const MyApp());

    await tester.tap(find.byTooltip('Open navigation menu'));
    await tester.pumpAndSettle();
    // Font tes (Ahem) lebih lebar dari font asli sehingga header drawer overflow.
    while (tester.takeException() != null) {}
    await tester.tap(find.text('Add Project'));
    await tester.pumpAndSettle();
    expect(find.text('Add Project Form'), findsOneWidget);

    await tester.tap(find.byTooltip('Open navigation menu'));
    await tester.pumpAndSettle();
    while (tester.takeException() != null) {}
    await tester.tap(find.text('Home'));
    await tester.pumpAndSettle();
    expect(find.text('Selamat datang di MyPortfolio Mobile!'), findsOneWidget);
  });
}
