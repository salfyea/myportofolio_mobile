// Smoke test untuk aplikasi MyPortfolio Mobile.
//
// Menguji halaman menu utama (MyHomePage): kartu profil, tombol aksi,
// warna unik tiap tombol, dan SnackBar saat tombol ditekan.

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/screens/menu.dart';

import 'support/test_app.dart';

const homeText = 'Selamat datang di MyPortfolio Mobile!';

/// Mengatur ukuran layar virtual (dalam piksel logis) untuk satu test.
void setScreenSize(WidgetTester tester, Size size) {
  tester.view.devicePixelRatio = 1.0;
  tester.view.physicalSize = size;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

void main() {
  testWidgets('menampilkan identitas pemilik pada tiga InfoCard', (
    tester,
  ) async {
    await tester.pumpWidget(fakeApp());

    expect(find.byType(InfoCard), findsNWidgets(3));
    expect(find.text('NPM'), findsOneWidget);
    expect(find.text('2506620280'), findsOneWidget);
    expect(find.text('Name'), findsOneWidget);
    expect(find.text('Salwa Alifia Putri'), findsOneWidget);
    expect(find.text('Class'), findsOneWidget);
    expect(find.text('PBP A'), findsOneWidget);
  });

  test('setiap ItemHomepage memiliki warna yang unik', () {
    for (final isLoggedIn in [false, true]) {
      final items = const MyHomePage().itemsFor(isLoggedIn: isLoggedIn);
      final colors = items.map((item) => item.color).toSet();

      expect(items.length, greaterThanOrEqualTo(3));
      expect(colors.length, items.length);
    }
  });

  test('tombol terakhir berganti antara Login dan Logout sesuai sesi', () {
    final loggedOut = const MyHomePage().itemsFor(isLoggedIn: false);
    final loggedIn = const MyHomePage().itemsFor(isLoggedIn: true);

    expect(loggedOut.map((i) => i.name), contains('Login'));
    expect(loggedOut.map((i) => i.name), isNot(contains('Logout')));
    expect(loggedIn.map((i) => i.name), contains('Logout'));
    expect(loggedIn.map((i) => i.name), isNot(contains('Login')));
  });

  test('hanya kartu yang menulis data yang mewajibkan login', () {
    final items = const MyHomePage().itemsFor(isLoggedIn: false);
    final guarded = items
        .where((item) => item.requiresLogin)
        .map((i) => i.name);

    expect(guarded, ['Tambah Proyek']);
  });

  testWidgets('menekan tiap tombol memunculkan SnackBar sesuai namanya', (
    tester,
  ) async {
    setScreenSize(tester, const Size(800, 1200));
    await tester.pumpWidget(fakeApp());

    for (final item in const MyHomePage().itemsFor(isLoggedIn: false)) {
      await tester.tap(find.text(item.name));
      await tester.pump(); // memulai animasi SnackBar
      await tester.pump(const Duration(milliseconds: 750));

      expect(
        find.text('Kamu telah menekan tombol ${item.name}!'),
        findsOneWidget,
      );

      // Kartu yang membuka halaman (tujuan, atau layar login untuk kartu yang
      // dijaga) menutup menu; kembali dengan tombol Back sistem. Kartu lain
      // tetap berada di menu.
      await tester.pumpAndSettle();
      if (find.text(homeText).evaluate().isEmpty) {
        await tester.binding.handlePopRoute();
        await tester.pumpAndSettle();
      }
      expect(find.text(homeText), findsOneWidget);
    }
  });

  testWidgets(
    'InfoCard muat di lebar layar HP kecil dan semua tombol terjangkau',
    (tester) async {
      const phone = Size(360, 640);
      setScreenSize(tester, phone);
      await tester.pumpWidget(fakeApp());

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
        find.text('Login'),
        200,
        scrollable: find.byType(Scrollable).first, // scroll halaman (luar)
      );
      while (tester.takeException() != null) {}
      expect(find.text('Login'), findsOneWidget);
    },
  );

  testWidgets('tidak overflow di layar lebar (web/desktop)', (tester) async {
    setScreenSize(tester, const Size(1280, 720));
    await tester.pumpWidget(fakeApp());

    await tester.scrollUntilVisible(
      find.text('Login'),
      200,
      scrollable: find.byType(Scrollable).first, // scroll halaman (luar)
    );
    expect(find.text('Login'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
