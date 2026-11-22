// Widget test untuk AppTextFormField dan DateFormField (lib/widgets/).

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/utils/validators.dart';
import 'package:myportofolio_mobile/widgets/app_text_form_field.dart';
import 'package:myportofolio_mobile/widgets/date_form_field.dart';

/// Membungkus [child] dengan MaterialApp + Form agar widget bisa diuji sendiri.
Widget host(GlobalKey<FormState> key, Widget child) => MaterialApp(
      home: Scaffold(body: Form(key: key, child: child)),
    );

void main() {
  group('AppTextFormField', () {
    testWidgets('menjalankan validator saat Form divalidasi', (tester) async {
      final key = GlobalKey<FormState>();
      final controller = TextEditingController();
      addTearDown(controller.dispose);

      await tester.pumpWidget(host(
        key,
        AppTextFormField(
          controller: controller,
          label: 'Posisi',
          validator: (v) => validateRequired(v, 'Posisi'),
        ),
      ));

      controller.text = '   ';
      expect(key.currentState!.validate(), isFalse);
      await tester.pump();
      expect(find.text('Posisi tidak boleh kosong!'), findsOneWidget);

      controller.text = 'Intern';
      expect(key.currentState!.validate(), isTrue);
    });

    testWidgets('maxLength hanya menghitung: ketikan tidak diblokir',
        (tester) async {
      final key = GlobalKey<FormState>();
      final controller = TextEditingController();
      addTearDown(controller.dispose);

      await tester.pumpWidget(host(
        key,
        AppTextFormField(
          controller: controller,
          label: 'Deskripsi',
          maxLength: 10,
          validator: (v) => validateRequired(v, 'Deskripsi', maxLength: 10),
        ),
      ));

      await tester.enterText(find.byType(TextFormField), 'x' * 15);
      await tester.pump();

      // Teks tetap utuh (tidak terpotong), penghitung menampilkan 15/10,
      // dan validator-lah yang menolaknya.
      expect(controller.text.length, 15);
      expect(find.text('15/10'), findsOneWidget);
      expect(key.currentState!.validate(), isFalse);
      await tester.pump();
      expect(find.text('Deskripsi terlalu panjang (maksimal 10 karakter).'),
          findsOneWidget);
    });

    testWidgets('kolom multibaris memakai papan ketik multiline',
        (tester) async {
      final controller = TextEditingController();
      addTearDown(controller.dispose);

      await tester.pumpWidget(host(
        GlobalKey<FormState>(),
        AppTextFormField(controller: controller, label: 'Uraian', maxLines: 4),
      ));

      final field = tester.widget<TextField>(find.byType(TextField));
      expect(field.keyboardType, TextInputType.multiline);
      expect(field.textInputAction, TextInputAction.newline);
    });
  });

  group('DateFormField', () {
    final first = DateTime(2000);
    final last = DateTime(2100);

    DateFormField buildField({
      ValueChanged<DateTime?>? onChanged,
      FormFieldValidator<DateTime>? validator,
      bool enabled = true,
    }) =>
        DateFormField(
          label: 'Tanggal Mulai',
          firstDate: first,
          lastDate: last,
          pickerStartDate: DateTime(2026, 5, 10),
          onChanged: onChanged,
          validator: validator,
          enabled: enabled,
        );

    testWidgets('memilih tanggal menampilkannya dan memanggil onChanged',
        (tester) async {
      DateTime? changed;
      await tester.pumpWidget(host(
        GlobalKey<FormState>(),
        buildField(onChanged: (d) => changed = d),
      ));

      await tester.tap(find.text('Tanggal Mulai'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('15'));
      await tester.tap(find.text('Pilih'));
      await tester.pumpAndSettle();

      expect(changed, DateTime(2026, 5, 15));
      expect(find.text('15 Mei 2026'), findsOneWidget);
    });

    testWidgets('menekan Batal mempertahankan nilai lama', (tester) async {
      var calls = 0;
      await tester.pumpWidget(host(
        GlobalKey<FormState>(),
        buildField(onChanged: (_) => calls++),
      ));

      await tester.tap(find.text('Tanggal Mulai'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Batal'));
      await tester.pumpAndSettle();

      expect(calls, 0);
      expect(find.textContaining('Mei 2026'), findsNothing);
    });

    testWidgets('validator tampil sebagai pesan di bawah kolom',
        (tester) async {
      final key = GlobalKey<FormState>();
      await tester.pumpWidget(host(
        key,
        buildField(validator: (d) => validateRequiredDate(d, 'Tanggal mulai')),
      ));

      expect(key.currentState!.validate(), isFalse);
      await tester.pump();
      expect(find.text('Tanggal mulai wajib dipilih!'), findsOneWidget);
    });

    testWidgets('reset() mengosongkan tanggal yang sudah dipilih',
        (tester) async {
      final key = GlobalKey<FormState>();
      await tester.pumpWidget(host(key, buildField()));

      await tester.tap(find.text('Tanggal Mulai'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Pilih'));
      await tester.pumpAndSettle();
      expect(find.text('10 Mei 2026'), findsOneWidget);

      key.currentState!.reset();
      await tester.pump();
      expect(find.text('10 Mei 2026'), findsNothing);
    });

    testWidgets('kolom nonaktif tidak membuka date picker', (tester) async {
      await tester.pumpWidget(host(
        GlobalKey<FormState>(),
        buildField(enabled: false),
      ));

      await tester.tap(find.text('Tanggal Mulai'));
      await tester.pumpAndSettle();

      expect(find.byType(DatePickerDialog), findsNothing);
    });
  });
}
