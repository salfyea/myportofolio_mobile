// Test alur navigasi: kartu aksi, drawer, dan tombol kembali.

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'support/test_app.dart';

const homeText = 'Selamat datang di MyPortfolio Mobile!';

/// Layar cukup besar agar seluruh kartu menu terlihat tanpa menggulir.
Future<void> openApp(WidgetTester tester, {String? loggedInToken}) async {
  tester.view.devicePixelRatio = 1.0;
  tester.view.physicalSize = const Size(800, 1200);
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(fakeApp(loggedInToken: loggedInToken));
}

Future<void> openDrawer(WidgetTester tester) async {
  await tester.tap(find.byTooltip('Open navigation menu'));
  await tester.pumpAndSettle();
  // Font tes (Ahem) lebih lebar dari font asli sehingga header drawer overflow.
  while (tester.takeException() != null) {}
}

Future<void> tapDrawerItem(WidgetTester tester, String label) async {
  await openDrawer(tester);
  await tester.tap(find.widgetWithText(ListTile, label));
  await tester.pumpAndSettle();
}

NavigatorState navigator(WidgetTester tester) =>
    tester.state<NavigatorState>(find.byType(Navigator));

bool isSelected(WidgetTester tester, String label) =>
    tester.widget<ListTile>(find.widgetWithText(ListTile, label)).selected;

void main() {
  testWidgets('kartu Tambah Experience membuka form; Back sistem ke menu', (
    tester,
  ) async {
    await openApp(tester);

    await tester.tap(find.text('Tambah Experience'));
    await tester.pumpAndSettle();
    expect(find.text('Add Experience Form'), findsOneWidget);
    expect(navigator(tester).canPop(), isTrue);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text(homeText), findsOneWidget);
  });

  testWidgets('drawer Add Experience membuka form dengan pushReplacement', (
    tester,
  ) async {
    await openApp(tester);

    await tapDrawerItem(tester, 'Add Experience');
    expect(find.text('Add Experience Form'), findsOneWidget);
    // Halaman utama digantikan, bukan ditumpuk.
    expect(navigator(tester).canPop(), isFalse);
  });

  testWidgets('Home di drawer menyisakan tepat satu halaman utama', (
    tester,
  ) async {
    await openApp(tester);

    // Menu -> form (push dari kartu) -> Home (drawer).
    await tester.tap(find.text('Tambah Experience'));
    await tester.pumpAndSettle();
    await tapDrawerItem(tester, 'Home');

    expect(find.text(homeText), findsOneWidget);
    // Tanpa pushAndRemoveUntil, tumpukannya akan [Home, Home] dan canPop true.
    expect(navigator(tester).canPop(), isFalse);
  });

  testWidgets('drawer menandai halaman yang sedang aktif', (tester) async {
    await openApp(tester);

    await openDrawer(tester);
    expect(isSelected(tester, 'Home'), isTrue);
    expect(isSelected(tester, 'Add Project'), isFalse);
    expect(isSelected(tester, 'Add Experience'), isFalse);

    await tester.tap(find.widgetWithText(ListTile, 'Add Experience'));
    await tester.pumpAndSettle();

    await openDrawer(tester);
    expect(isSelected(tester, 'Home'), isFalse);
    expect(isSelected(tester, 'Add Experience'), isTrue);
  });

  testWidgets('memilih halaman aktif hanya menutup drawer, isian tetap ada', (
    tester,
  ) async {
    await openApp(tester);
    await tester.tap(find.text('Tambah Experience'));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Posisi / Jabatan'),
      'Intern',
    );
    await tapDrawerItem(tester, 'Add Experience');

    expect(find.byType(Drawer), findsNothing);
    expect(find.text('Intern'), findsOneWidget);
    expect(find.text('Add Experience Form'), findsOneWidget);
  });

  testWidgets(
    'berpindah antara form Experience dan form Project lewat drawer',
    (tester) async {
      // Add Project dijaga login, jadi mulai dalam keadaan sudah login.
      await openApp(tester, loggedInToken: 'tok');

      await tapDrawerItem(tester, 'Add Experience');
      expect(find.text('Add Experience Form'), findsOneWidget);

      await tapDrawerItem(tester, 'Add Project');
      expect(find.text('Add Project Form'), findsOneWidget);

      await tapDrawerItem(tester, 'Add Experience');
      expect(find.text('Add Experience Form'), findsOneWidget);
      expect(navigator(tester).canPop(), isFalse);
    },
  );
}
