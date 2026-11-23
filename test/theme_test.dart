// Test konsistensi tema: semua halaman harus memakai warna portofolio yang sama.

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/main.dart';

/// Mengambil warna latar AppBar yang benar-benar dirender pada halaman aktif.
Color renderedAppBarColor(WidgetTester tester) {
  final material = tester.widget<Material>(
    find
        .descendant(of: find.byType(AppBar), matching: find.byType(Material))
        .first,
  );
  return material.color!;
}

void main() {
  testWidgets(
    'AppBar halaman utama dan semua form memakai warna tema yang sama',
    (tester) async {
      tester.view.devicePixelRatio = 1.0;
      tester.view.physicalSize = const Size(800, 1200);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(const MyApp());
      final primary = Theme.of(tester.element(find.byType(AppBar)))
          .colorScheme
          .primary;
      final homeColor = renderedAppBarColor(tester);
      expect(homeColor, primary);

      await tester.tap(find.text('Tambah Proyek'));
      await tester.pumpAndSettle();
      expect(find.text('Add Project Form'), findsOneWidget);
      expect(renderedAppBarColor(tester), homeColor);

      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      await tester.tap(find.text('Tambah Experience'));
      await tester.pumpAndSettle();
      expect(find.text('Add Experience Form'), findsOneWidget);
      expect(renderedAppBarColor(tester), homeColor);
    },
  );
}
