// Test RemoteImage: raster, SVG, dan URL tanpa ekstensi (mis. cdn.simpleicons.org).
//
// Lingkungan tes menjawab semua permintaan jaringan dengan galat, sehingga yang
// diperiksa di sini adalah JALUR yang dipilih widget, bukan piksel gambar.

import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/widgets/remote_image.dart';

Future<void> show(WidgetTester tester, String url) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: RemoteImage(
          url: url,
          semanticLabel: 'Ikon uji',
          height: 40,
          width: 40,
          fit: BoxFit.contain,
        ),
      ),
    ),
  );
}

Finder get brokenIcon => find.byIcon(Icons.broken_image_outlined);

void main() {
  group('ekstensi .svg', () {
    testWidgets('langsung memakai SvgPicture, bukan Image', (tester) async {
      await show(tester, 'https://example.com/logo.svg');

      expect(find.byType(SvgPicture), findsOneWidget);
      expect(find.byType(Image), findsNothing);
    });

    testWidgets('ekstensi huruf besar dan query string tetap dikenali', (
      tester,
    ) async {
      await show(tester, 'https://example.com/Logo.SVG?v=2');

      expect(find.byType(SvgPicture), findsOneWidget);
    });

    testWidgets('SVG yang gagal dimuat menampilkan ikon rusak, tanpa galat', (
      tester,
    ) async {
      await show(tester, 'https://example.com/logo.svg');
      await tester.pumpAndSettle();

      expect(brokenIcon, findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('ekstensi raster', () {
    for (final extension in ['png', 'jpg', 'jpeg', 'gif', 'webp']) {
      testWidgets('.$extension memakai Image dan tidak mencoba SVG', (
        tester,
      ) async {
        await show(tester, 'https://example.com/foto.$extension');
        await tester.pumpAndSettle();

        // Gagal dimuat: ikon rusak, dan tidak ada percobaan kedua sebagai SVG.
        expect(find.byType(SvgPicture), findsNothing);
        expect(brokenIcon, findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    }
  });

  group('tanpa ekstensi', () {
    testWidgets('mencoba Image dahulu', (tester) async {
      await show(tester, 'https://cdn.simpleicons.org/django');

      expect(find.byType(Image), findsOneWidget);
      expect(find.byType(SvgPicture), findsNothing);
    });

    testWidgets('bila Image gagal, mencoba lagi sebagai SVG', (tester) async {
      await show(tester, 'https://cdn.simpleicons.org/django');
      await tester.pumpAndSettle();

      // Image tidak bisa memecahkan SVG; widget beralih ke SvgPicture. Di
      // lingkungan tes SVG-nya pun gagal diunduh, jadi akhirnya ikon rusak.
      expect(find.byType(SvgPicture), findsOneWidget);
      expect(brokenIcon, findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  testWidgets('ukuran ikon rusak mengikuti ukuran gambar', (tester) async {
    await show(tester, 'https://example.com/foto.png');
    await tester.pumpAndSettle();

    final icon = tester.widget<Icon>(brokenIcon);
    // 40 px * 0,24 dibatasi minimal 24.
    expect(icon.size, 24);
  });
}
