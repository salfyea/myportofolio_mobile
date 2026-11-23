// Widget test untuk halaman formulir Experience (lib/screens/experience_form.dart).

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/models/experience.dart';
import 'package:myportofolio_mobile/screens/experience_form.dart';
import 'package:myportofolio_mobile/utils/formatters.dart';

import 'support/test_app.dart';

/// Mengatur ukuran layar virtual (piksel logis) untuk satu test.
void setScreenSize(WidgetTester tester, Size size) {
  tester.view.devicePixelRatio = 1.0;
  tester.view.physicalSize = size;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(tester.view.resetViewInsets);
}

/// Layar tinggi agar seluruh formulir terlihat tanpa menggulir.
Future<void> openForm(WidgetTester tester) async {
  setScreenSize(tester, const Size(800, 1800));
  await tester.pumpWidget(
    testApp(
      client: fakeApiClient(emptyBackend),
      home: const ExperienceFormPage(),
    ),
  );
}

Finder textField(String label) => find.widgetWithText(TextFormField, label);

/// Memilih tanggal pada kolom [label]; tanpa mengetuk hari, yang terpilih
/// adalah tanggal awal date picker (hari ini untuk tanggal mulai).
Future<void> pickDate(WidgetTester tester, String label) async {
  await tester.tap(find.text(label));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Pilih'));
  await tester.pumpAndSettle();
}

/// Mencari [text] hanya di dalam AlertDialog; teks yang sama juga ada pada
/// kolom formulir di balik dialog sehingga `find.text` biasa menemukan dua.
Finder inDialog(String text) =>
    find.descendant(of: find.byType(AlertDialog), matching: find.text(text));

Future<void> tapSave(WidgetTester tester) async {
  await tester.tap(find.text('Simpan'));
  await tester.pumpAndSettle();
}

/// Mengisi seluruh kolom wajib dengan data valid (kegiatan sudah selesai).
Future<void> fillValidForm(WidgetTester tester) async {
  await tester.enterText(textField('Posisi / Jabatan'), 'Frontend Intern');
  await tester.enterText(textField('Perusahaan / Organisasi'), 'Acme Corp');
  await tester.enterText(textField('Deskripsi'), 'Membangun halaman web.');
  await pickDate(tester, 'Tanggal Mulai');
  await pickDate(tester, 'Tanggal Selesai');
}

void main() {
  testWidgets('input kosong ditolak dan dialog tidak muncul', (tester) async {
    await openForm(tester);
    await tapSave(tester);

    expect(find.text('Posisi tidak boleh kosong!'), findsOneWidget);
    expect(find.text('Perusahaan tidak boleh kosong!'), findsOneWidget);
    expect(find.text('Tanggal mulai wajib dipilih!'), findsOneWidget);
    expect(
      find.textContaining('Tanggal selesai wajib dipilih'),
      findsOneWidget,
    );
    expect(find.text('Deskripsi tidak boleh kosong!'), findsOneWidget);
    expect(find.byType(AlertDialog), findsNothing);
  });

  testWidgets('isian yang hanya berisi spasi dianggap kosong', (tester) async {
    await openForm(tester);
    await tester.enterText(textField('Posisi / Jabatan'), '     ');
    await tester.enterText(textField('Perusahaan / Organisasi'), '\t ');
    await tester.enterText(textField('Deskripsi'), '   ');
    await tapSave(tester);

    expect(find.text('Posisi tidak boleh kosong!'), findsOneWidget);
    expect(find.text('Perusahaan tidak boleh kosong!'), findsOneWidget);
    expect(find.text('Deskripsi tidak boleh kosong!'), findsOneWidget);
    expect(find.byType(AlertDialog), findsNothing);
  });

  testWidgets('batas panjang dan format URL ditolak walau kolom terisi', (
    tester,
  ) async {
    await openForm(tester);
    await fillValidForm(tester);
    await tester.enterText(textField('Posisi / Jabatan'), 'a' * 101);
    await tester.enterText(textField('Deskripsi'), 'b' * 1001);
    await tester.enterText(
      textField('Tautan Pendukung (opsional)'),
      'linkedin.com/in/saya',
    );
    await tapSave(tester);

    expect(
      find.text('Posisi terlalu panjang (maksimal 100 karakter).'),
      findsOneWidget,
    );
    expect(
      find.text('Deskripsi terlalu panjang (maksimal 1000 karakter).'),
      findsOneWidget,
    );
    expect(find.textContaining('Tautan tidak valid'), findsOneWidget);
    expect(find.byType(AlertDialog), findsNothing);
  });

  testWidgets('pesan kesalahan hilang setelah isian diperbaiki', (
    tester,
  ) async {
    await openForm(tester);
    await tapSave(tester);
    expect(find.text('Posisi tidak boleh kosong!'), findsOneWidget);

    await tester.enterText(textField('Posisi / Jabatan'), 'Intern');
    await tester.pump();
    expect(find.text('Posisi tidak boleh kosong!'), findsNothing);
  });

  testWidgets('data valid menampilkan ringkasan; Tutup mengosongkan formulir', (
    tester,
  ) async {
    await openForm(tester);
    await fillValidForm(tester);

    await tester.tap(find.byType(DropdownButtonFormField<EmploymentType>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Magang').last);
    await tester.pumpAndSettle();
    await tester.enterText(
      textField('Tautan Pendukung (opsional)'),
      'https://acme.example/intern',
    );
    await tapSave(tester);

    final today = formatDate(DateTime.now());
    expect(find.text('Ringkasan Pengalaman'), findsOneWidget);
    expect(inDialog('Frontend Intern'), findsOneWidget);
    expect(inDialog('Acme Corp'), findsOneWidget);
    expect(inDialog('Magang'), findsOneWidget);
    expect(inDialog('$today - $today'), findsOneWidget);
    expect(inDialog('Kurang dari 1 bulan'), findsOneWidget);
    expect(inDialog('Membangun halaman web.'), findsOneWidget);
    expect(inDialog('https://acme.example/intern'), findsOneWidget);

    await tester.tap(find.text('Tutup'));
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsNothing);

    // Formulir kembali kosong dan pilihan dropdown kembali ke bawaan.
    expect(find.text('Frontend Intern'), findsNothing);
    expect(find.text('Acme Corp'), findsNothing);
    expect(find.text(today), findsNothing);
    expect(find.text('Penuh Waktu'), findsOneWidget);
  });

  testWidgets('tautan opsional kosong tidak ditampilkan pada ringkasan', (
    tester,
  ) async {
    await openForm(tester);
    await fillValidForm(tester);
    await tapSave(tester);

    expect(find.text('Ringkasan Pengalaman'), findsOneWidget);
    expect(find.text('Tautan'), findsNothing);
  });

  testWidgets('"Masih berlangsung" menonaktifkan tanggal selesai', (
    tester,
  ) async {
    await openForm(tester);
    await tester.enterText(textField('Posisi / Jabatan'), 'Intern');
    await tester.enterText(textField('Perusahaan / Organisasi'), 'Acme');
    await tester.enterText(textField('Deskripsi'), 'Magang.');
    await pickDate(tester, 'Tanggal Mulai');
    await pickDate(tester, 'Tanggal Selesai'); // terisi, lalu akan dikosongkan

    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();

    // Kolom tanggal selesai dikosongkan dan tidak bisa dibuka lagi.
    await tester.tap(find.text('Tanggal Selesai'));
    await tester.pumpAndSettle();
    expect(find.byType(DatePickerDialog), findsNothing);

    await tapSave(tester);
    expect(
      find.text('${formatDate(DateTime.now())} - Sekarang'),
      findsOneWidget,
    );
  });

  testWidgets('tanggal selesai sebelum tanggal mulai ditolak', (tester) async {
    await openForm(tester);
    await tester.enterText(textField('Posisi / Jabatan'), 'Intern');
    await tester.enterText(textField('Perusahaan / Organisasi'), 'Acme');
    await tester.enterText(textField('Deskripsi'), 'Magang.');

    // Tanggal selesai dipilih lebih dulu: tanggal 10 bulan lalu. Date picker
    // selesai baru dibatasi tanggal mulai setelah tanggal mulai terisi.
    await tester.tap(find.text('Tanggal Selesai'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Previous month'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('10'));
    await tester.tap(find.text('Pilih'));
    await tester.pumpAndSettle();

    // Tanggal mulai = hari ini, yang jatuh setelah tanggal selesai tadi.
    // Kolom tanggal selesai langsung divalidasi ulang tanpa menekan Simpan.
    await pickDate(tester, 'Tanggal Mulai');
    expect(
      find.text('Tanggal selesai tidak boleh sebelum tanggal mulai.'),
      findsOneWidget,
    );

    await tapSave(tester);
    expect(find.byType(AlertDialog), findsNothing);
  });

  testWidgets('tanggal selesai tidak bisa dipilih sebelum tanggal mulai', (
    tester,
  ) async {
    await openForm(tester);
    await pickDate(tester, 'Tanggal Mulai'); // hari ini

    await tester.tap(find.text('Tanggal Selesai'));
    await tester.pumpAndSettle();

    // Bulan sebelum tanggal mulai tidak tersedia: tombolnya nonaktif tanpa
    // tooltip, sehingga pengguna tidak bisa membuat urutan tanggal terbalik.
    expect(find.byTooltip('Previous month'), findsNothing);
  });

  testWidgets('Reset mengosongkan semua isian tanpa dialog', (tester) async {
    await openForm(tester);
    await fillValidForm(tester);
    expect(find.text('Frontend Intern'), findsOneWidget);

    await tester.tap(find.text('Reset'));
    await tester.pumpAndSettle();

    expect(find.text('Frontend Intern'), findsNothing);
    expect(find.text(formatDate(DateTime.now())), findsNothing);
    expect(find.byType(AlertDialog), findsNothing);
  });

  testWidgets(
    'layar ponsel dengan papan ketik: Simpan terjangkau dan kolom salah terlihat',
    (tester) async {
      const phone = Size(360, 640);
      setScreenSize(tester, phone);
      // Papan ketik setinggi 300 px menutupi bagian bawah layar.
      tester.view.viewInsets = const FakeViewPadding(bottom: 300);
      await tester.pumpWidget(
        testApp(
          client: fakeApiClient(emptyBackend),
          home: const ExperienceFormPage(),
        ),
      );

      final scrollable = find.byType(Scrollable).first;
      await tester.scrollUntilVisible(
        find.text('Simpan'),
        150,
        scrollable: scrollable,
      );
      await tester.tap(find.text('Simpan'));
      await tester.pumpAndSettle();

      // Halaman menggulir kembali ke kolom pertama yang salah.
      final error = tester.getRect(find.text('Posisi tidak boleh kosong!'));
      expect(error.top, greaterThanOrEqualTo(0));
      expect(error.bottom, lessThanOrEqualTo(phone.height - 300));
    },
  );
}
