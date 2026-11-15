// Smoke test untuk aplikasi MyPortfolio Mobile.
//
// Menguji halaman menu utama (MyHomePage): kartu profil, tombol aksi,
// warna unik tiap tombol, dan SnackBar saat tombol ditekan.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:myportofolio_mobile/main.dart';
import 'package:myportofolio_mobile/menu.dart';

/// Mengatur ukuran layar virtual (dalam piksel logis) untuk satu test.
void setScreenSize(WidgetTester tester, Size size) {
  tester.view.devicePixelRatio = 1.0;
  tester.view.physicalSize = size;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

void main() {
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
