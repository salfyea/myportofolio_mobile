# MyPortfolio Mobile

[![CI](https://github.com/salfyea/myportofolio_mobile/actions/workflows/main.yaml/badge.svg)](https://github.com/salfyea/myportofolio_mobile/actions/workflows/main.yaml)

Aplikasi mobile portofolio pribadi yang dibangun dengan **Flutter**. Aplikasi ini adalah klien mobile dari website portofolio Django saya ([myportofolio](https://github.com/salfyea/myportofolio)) dan dikembangkan bertahap mengikuti tutorial serta tugas mata kuliah **Pemrograman Berbasis Platform (CSGE602022)**, Semester Gasal 2026/2027.

[Identitas](#identitas-diri) · [Tentang Proyek](#tentang-proyek) · [Perkembangan](#perkembangan-proyek) · [Menjalankan Proyek](#menjalankan-proyek) · [Refleksi Mingguan](#refleksi-mingguan) · [Penggunaan AI](#ai-disclosure)

---

## Identitas Diri

| Keterangan | Identitas |
| --- | --- |
| Nama | Salwa Alifia Putri |
| NPM | 2506620280 |
| Kelas | PBP A |
| Program Studi | S1 Sistem Informasi |

---

## Tentang Proyek

Halaman utama aplikasi menampilkan identitas pemilik portofolio pada tiga kartu informasi (NPM, Nama, Kelas) dan tujuh tombol menu yang mengikuti bagian-bagian website Django: **Experience**, **Projects**, dan **Skills**, ditambah aksi tambah dan logout. Setiap tombol memiliki ikon dan warna sendiri. Saat ditekan, tombol memunculkan SnackBar `Kamu telah menekan tombol [Nama Tombol]!`.

Aplikasi punya tiga halaman formulir yang bisa dibuka dari kartu aksi di halaman utama maupun dari drawer:

| Formulir | Isian | Aturan validasi |
| --- | --- | --- |
| **Add Project** (Tutorial 9, terhubung ke API sejak Tutorial 10) | Nama, deskripsi, kategori, tautan, URL gambar | Nama dan deskripsi wajib (spasi saja ditolak), nama maks. 200 karakter, tautan dan URL gambar opsional berformat `http(s)://`. **Wajib login**; tersimpan ke Django lewat `POST /api/v1/projects/` |
| **Add Skill** (Tugas 9) | Nama skill, URL ikon, kategori | Nama dan URL ikon wajib (spasi saja ditolak), nama maks. 100 karakter, URL ikon berformat `http(s)://` maks. 200 karakter, kategori opsional maks. 50 karakter. **Wajib login**; tersimpan ke Django lewat `POST /api/v1/skills/`. Form yang sama dipakai untuk **mengubah** skill (`PATCH`, lihat di bawah) |
| **Add Experience** (Tugas 8) | Posisi, perusahaan, jenis pekerjaan, tanggal mulai, tanggal selesai atau "Masih berlangsung", deskripsi, tautan | Posisi, perusahaan, tanggal mulai, dan deskripsi wajib; tanggal mulai tidak boleh di masa depan; tanggal selesai tidak boleh sebelum tanggal mulai; batas panjang 100/100/1000/200 karakter; tautan opsional berformat `http(s)://` |

Pada form **Experience**, setelah semua isian lolos validasi, tombol **Simpan** menampilkan ringkasan dalam `AlertDialog`; **data Experience belum dikirim ke backend** (lihat catatan di bagian [Assignment 9](#assignment-9)). Pada form **Project** dan **Skill**, tombol **Save** mengirim data ke Django dengan token milik pengguna yang login (lihat [Backend dan Autentikasi](#backend-dan-autentikasi)).

Sejak Tutorial 10, daftar proyek dibaca dari API (publik, tanpa login) pada layar **Projects**: indikator memuat, pesan galat dengan tombol **Retry**, pesan daftar kosong, tarik-untuk-muat-ulang, dan layar detail untuk satu proyek.

Sejak Tugas 9, bagian **Skills** terhubung ke API dengan pola yang sama:

| Fitur | Perilaku |
| --- | --- |
| Daftar skill (publik) | `GET /api/v1/skills/` tanpa login; ikon, nama, kategori, jumlah bintang; indikator memuat, galat + **Retry**, daftar kosong, tarik-untuk-muat-ulang. Ikon **SVG** ikut tampil (lihat [temuan QA](#hasil-uji-manual-skills-di-chrome-24-november-2026)) |
| Detail skill (publik) | Ikon besar, nama, kategori, URL ikon, dan ringkasan bintang |
| Tambah skill | Wajib login; setelah login ulang karena 401, pengguna kembali ke form |
| Ubah skill (`PATCH`) | Tombol pensil di layar detail, hanya tampil saat login; membuka form yang sama dalam mode ubah |
| Hapus skill (`DELETE`) | Tombol tempat sampah di layar detail, hanya tampil saat login; ada dialog konfirmasi |

Tombol ubah dan hapus tampil untuk **semua pengguna yang login** karena aplikasi tidak mengetahui peran akun; yang menentukan adalah backend (superuser boleh mengubah dan menghapus, anggota grup *Editor* hanya boleh mengubah, akun lain mendapat 403). Penolakan itu ditampilkan sebagai SnackBar berisi pesan dari server.

**Fitur tambahan pada form Experience** (di luar yang diminta soal): date picker dengan validasi silang tanggal, sakelar *Masih berlangsung*, penghitung karakter deskripsi, gulir otomatis ke kolom pertama yang salah, tombol Reset, durasi pengalaman pada ringkasan, penanda halaman aktif pada drawer, dan Home di drawer yang tidak menumpuk halaman.

### Teknologi

| Teknologi | Penggunaan |
| --- | --- |
| **Flutter** (Material 3) | Kerangka kerja UI lintas platform |
| **Dart** | Bahasa pemrograman aplikasi |
| **Git & GitHub** | Riwayat versi, branch per fitur, dan penyimpanan repositori |
| **http** | Pemanggilan REST API ke backend Django (`ApiClient`); `MockClient` dari paket yang sama dipakai di test agar tidak butuh jaringan |
| **provider** | `MultiProvider` menyediakan `ApiClient` dan `AuthState` ke seluruh widget tree |
| **json_serializable** + **build_runner** | Pembuatan kode serialisasi JSON untuk model `Project` dan `Skill` (`*.g.dart`, tidak di-commit) |
| **flutter_svg** | Menggambar ikon skill yang berformat SVG (`Image.network` tidak bisa) |
| **GitHub Actions** + **very_good_workflows** | CI (format, analyze, test) dan build APK release |

### Struktur Kode

```text
lib/
├── main.dart                        # Titik masuk: MyApp (MaterialApp + tema + MultiProvider)
├── config.dart                      # apiBaseUrl (dapat ditimpa lewat --dart-define=API_BASE_URL)
├── models/
│   ├── experience.dart              # Experience, EmploymentType (data murni, tanpa UI)
│   ├── project.dart                 # Project (@JsonSerializable; project.g.dart dibuat build_runner)
│   └── skill.dart                   # Skill (@JsonSerializable snake_case; skill.g.dart dibuat build_runner)
├── services/                        # Logika jaringan dan sesi, tanpa UI
│   ├── api_client.dart              # ApiClient + ApiException (GET/POST proyek dan skill, PATCH/DELETE skill, token, logout)
│   └── auth_state.dart              # AuthState (ChangeNotifier): token di memori, login, logout
├── screens/                         # Satu berkas = satu halaman penuh
│   ├── menu.dart                    # MyHomePage, InfoCard, ItemHomepage
│   ├── login_screen.dart            # LoginScreen (username + password -> token)
│   ├── project_list.dart            # ProjectListPage (FutureBuilder + RefreshIndicator)
│   ├── project_detail.dart          # ProjectDetailPage (seluruh field satu proyek)
│   ├── project_form.dart            # ProjectFormPage (form tambah proyek, POST terautentikasi)
│   ├── skill_list.dart              # SkillListPage (FutureBuilder + RefreshIndicator)
│   ├── skill_detail.dart            # SkillDetailPage (+ tombol ubah dan hapus saat login)
│   ├── skill_form.dart              # SkillFormPage (mode tambah = POST, mode ubah = PATCH)
│   └── experience_form.dart         # ExperienceFormPage (form tambah experience, lokal)
├── utils/                           # Logika murni, tanpa widget (mudah diuji)
│   ├── validators.dart              # validateRequired, validateRequiredUrl, validateOptionalUrl, validateEndDate, ...
│   └── formatters.dart              # formatDate, formatDuration, formatStarSummary
└── widgets/                         # Komponen yang dipakai ulang antarhalaman
    ├── auth_guard.dart              # ensureLoggedIn(context) dan handleApiFailure (SnackBar + penanganan 401)
    ├── left_drawer.dart             # LeftDrawer + DrawerDestination (navigasi, penanda aktif, Login/Logout)
    ├── project_card.dart            # ItemCard (kartu aksi di halaman utama)
    ├── app_text_form_field.dart     # AppTextFormField (kolom teks seragam)
    ├── date_form_field.dart         # DateFormField (FormField<DateTime> + showDatePicker)
    ├── experience_summary_dialog.dart  # ExperienceSummaryDialog (ringkasan setelah Simpan)
    ├── load_error_view.dart         # LoadErrorView: pesan galat + tombol Retry (dipakai semua daftar)
    ├── refreshable_message.dart     # RefreshableMessage: keadaan kosong yang tetap bisa ditarik-muat-ulang
    ├── detail_section.dart          # DetailSection: label + isi pada layar detail
    └── remote_image.dart            # RemoteImage: gambar dari URL (raster dan SVG) dengan penanda memuat/gagal
.github/workflows/
└── main.yaml                        # CI (very_good_workflows) + build APK release sebagai artefak
test/
├── support/test_app.dart            # Alat bantu: aplikasi dengan backend palsu (MockClient), tanpa jaringan
├── widget_test.dart                 # Halaman menu: kartu, warna, SnackBar, Login/Logout
├── api_client_test.dart             # ApiClient: header, body, pemetaan galat (MockClient)
├── project_model_test.dart          # Pemetaan JSON snake_case, nilai bawaan, field baca-saja
├── auth_test.dart                   # AuthState, LoginScreen, ensureLoggedIn
├── auth_navigation_test.dart        # Kartu dan drawer yang dijaga login
├── project_list_test.dart           # Memuat, galat + Retry, kosong, tarik-muat-ulang, buka detail
├── project_detail_test.dart         # Detail: field, gambar, bagian kosong
├── project_form_test.dart           # Form proyek: validasi, POST bertoken, 403/400/401/jaringan
├── skill_model_test.dart            # Skill: pemetaan snake_case, nilai bawaan, field baca-saja
├── skill_list_test.dart             # Daftar skill: memuat, galat + Retry, kosong, tarik-muat-ulang, buka detail
├── skill_detail_test.dart           # Detail skill: field, tombol ubah/hapus hanya saat login, hapus + 401
├── skill_form_test.dart             # Form skill: validasi, POST bertoken, mode ubah (PATCH), 403/400/401/jaringan
├── remote_image_test.dart           # RemoteImage: jalur raster, SVG, dan URL tanpa ekstensi
├── experience_form_test.dart        # Form Experience: validasi, dialog, reset, layar ponsel + keyboard
├── navigation_test.dart             # Kartu, drawer, Back sistem, tumpukan halaman
├── form_widgets_test.dart           # AppTextFormField dan DateFormField
├── validators_test.dart             # Unit test validator
├── formatters_test.dart             # Unit test formatter dan model
└── theme_test.dart                  # Warna AppBar konsisten antarhalaman
docs/
└── ai-log.md                        # Log prompting AI (Tutorial 08, Tugas 7, Tugas 8, Tugas 9)
```

| Komponen | Peran |
| --- | --- |
| `MyApp` | Widget akar; menyediakan `MaterialApp`, tema warna, dan `AppBarTheme` yang dipakai semua halaman |
| `MyHomePage` | Halaman menu utama (`StatelessWidget`) |
| `InfoCard` | Kartu informasi yang dapat dipakai ulang (judul + isi) |
| `ItemHomepage` | Model data satu tombol: nama, ikon, warna, dan halaman tujuan (opsional) |
| `ItemCard` | Kartu tombol berwarna dengan efek sentuh, SnackBar, dan `Navigator.push()` ke tujuannya |
| `LeftDrawer` | Drawer yang sama di semua halaman; daftar pilihannya berbasis data dan halaman aktif ditandai |
| `ExperienceFormPage` | Form `StatefulWidget` dengan `GlobalKey<FormState>`, validasi, dan dialog ringkasan |
| `AppTextFormField` / `DateFormField` | Kolom input reusable; `DateFormField` ikut `validate()` dan `reset()` karena berupa `FormField` |
| `validators.dart` / `formatters.dart` | Aturan validasi dan format tampilan dalam fungsi murni, terpisah dari widget |
| `Skill` / `Project` | Model `@JsonSerializable`: pemetaan JSON dibuat generator, bukan ditulis tangan |
| `ApiClient` / `ApiException` | Satu-satunya tempat yang bicara HTTP; semua kegagalan (status, jaringan, JSON rusak) menjadi `ApiException` |
| `SkillListPage` / `SkillDetailPage` / `SkillFormPage` | Tiga layar Skills: `Future` dibuat di `initState`, daftar dimuat ulang setelah tambah/ubah/hapus |
| `LoadErrorView` / `RefreshableMessage` / `DetailSection` / `RemoteImage` | Potongan UI yang dipakai bersama layar Projects dan Skills, diekstrak agar Skills tidak menyalin kode |
| `handleApiFailure` | Satu penanganan kegagalan API untuk semua aksi tulis: SnackBar, dan pada 401 hapus sesi lalu minta login ulang |

---

## Perkembangan Proyek

| Tahap | Lingkup Pengembangan |
| --- | --- |
| **Tutorial 8** | Setup Flutter dan Dart, inisialisasi proyek `myportofolio_mobile`, pemisahan `menu.dart` dari `main.dart`, perubahan tema warna, perubahan `MyHomePage` menjadi `StatelessWidget`, pembuatan `InfoCard` dan `ItemCard`, serta SnackBar. |
| **Tugas 7** | Atribut `color` pada `ItemHomepage` agar tiap tombol berwarna unik tanpa percabangan if-else, enam tombol yang mengikuti bagian portofolio Django, halaman yang dapat di-scroll dengan `childAspectRatio` kartu, perbaikan overflow `InfoCard` di layar sempit, docstring, dan widget test baru. |
| **Tutorial 9** | Drawer menu (`LeftDrawer`), navigasi `push`/`pushReplacement`/`pop`, form tambah proyek (`Form`, `TextFormField`, `DropdownButtonFormField`, validasi), pop-up `AlertDialog` berisi data isian, migrasi impor ke `material_ui`, dan refactoring ke direktori `screens/` dan `widgets/`. |
| **Tugas 8** | Form **Add Experience** (`Form`, `GlobalKey<FormState>`, `DropdownButtonFormField`, `showDatePicker`, `SwitchListTile`) dengan validator murni di `utils/`, dialog ringkasan, kartu aksi dan opsi drawer baru, pemusatan warna AppBar di `AppBarTheme`, penanda halaman aktif di drawer, perbaikan tumpukan halaman Home, serta 65 test otomatis. |
| **Tutorial 10** | Integrasi backend Django REST Framework: autentikasi token (`/api/v1/auth/token/`, `/api/v1/auth/logout/`) dan CORS di Django, model `@JsonSerializable`, `ApiClient` + `ApiException`, daftar dan detail proyek dengan `FutureBuilder` + `RefreshIndicator`, `AuthState` + `MultiProvider`, `LoginScreen` + `ensureLoggedIn`, form proyek terautentikasi dengan penanganan 401, serta CI/CD GitHub Actions (`very_good_workflows` + artefak APK). |
| **Tugas 9** | Bagian **Skills** terhubung ke API: model `Skill` (`@JsonSerializable(fieldRename: FieldRename.snake)`), `ApiClient` untuk `GET`/`POST` publik-terautentikasi plus `PATCH`/`DELETE` bertoken, layar daftar, detail, dan form (tambah + ubah), kartu dan drawer yang sudah terhubung, `handleApiFailure` bersama untuk 401, ekstraksi widget bersama (`LoadErrorView`, `RemoteImage`, dll.) dari layar Projects, dukungan ikon SVG (`flutter_svg`) hasil temuan QA browser, serta 242 test otomatis. |
| **Tugas berikutnya** | Akan ditambahkan pada bagian ini. |

---

## Menjalankan Proyek

**Prasyarat:** Flutter SDK (dikembangkan dengan Flutter 3.47 / Dart 3.13), serta Google Chrome atau emulator Android.

```bash
# 1. Clone repositori
git clone https://github.com/salfyea/myportofolio_mobile.git
cd myportofolio_mobile

# 2. Unduh dependensi
flutter pub get

# 3. Buat berkas hasil generasi (project.g.dart dan skill.g.dart). Berkas *.g.dart
#    sengaja tidak di-commit, jadi langkah ini wajib setelah clone dan setiap
#    model berubah. Tanpa langkah ini aplikasi tidak bisa dikompilasi.
dart run build_runner build --delete-conflicting-outputs

# 4. Jalankan (lihat "Backend dan Autentikasi" untuk memilih API_BASE_URL)
flutter run -d chrome --dart-define=API_BASE_URL=http://localhost:8000
# Emulator Android (bawaan: http://10.0.2.2:8000 = PC host)
# flutter run

# 5. Pemeriksaan yang sama dengan CI
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test
```

Saat aplikasi berjalan, tekan `r` di terminal untuk hot reload dan `R` untuk hot restart.

### Backend dan Autentikasi

Aplikasi ini adalah klien dari backend Django REST Framework di repositori [salfyea/myportofolio](https://github.com/salfyea/myportofolio) (di-deploy di `https://salwa-alifia-myportofolio.pws.cs.ui.ac.id`). Alamat backend ditentukan saat build lewat `--dart-define=API_BASE_URL=...` (lihat `lib/config.dart`):

| Target | Perintah |
| --- | --- |
| Emulator Android + Django lokal | `flutter run` (bawaan `http://10.0.2.2:8000`) |
| Chrome + Django lokal | `flutter run -d chrome --dart-define=API_BASE_URL=http://localhost:8000` |
| Backend yang sudah di-deploy | `flutter run -d chrome --dart-define=API_BASE_URL=https://salwa-alifia-myportofolio.pws.cs.ui.ac.id` |

Menjalankan Django lokal (di repositori backend, branch dengan token auth): `pip install -r requirements.txt`, `python manage.py migrate`, `python manage.py createsuperuser`, lalu `python manage.py runserver`.

Hak akses sengaja dipisah: **membaca** (`GET /api/v1/projects/` dan `GET /api/v1/skills/`) publik, sedangkan **menulis** memerlukan `Authorization: Token <key>`. Token didapat dari `POST /api/v1/auth/token/` (username + password akun Django) dan dicabut oleh `POST /api/v1/auth/logout/`. Token hanya disimpan di memori, jadi menutup aplikasi sama dengan logout. Jika token dicabut di server (mis. lewat Django Admin), aksi tulis berikutnya menerima 401: sesi lokal dihapus dan aplikasi meminta login ulang.

| Endpoint | Metode | Siapa yang boleh |
| --- | --- | --- |
| `/api/v1/projects/`, `/api/v1/skills/` | `GET` | Siapa saja (publik) |
| `/api/v1/projects/`, `/api/v1/skills/` | `POST` | Superuser (pemilik portofolio) |
| `/api/v1/skills/<id>/` | `PATCH` | Superuser atau anggota grup *Editor* |
| `/api/v1/skills/<id>/` | `DELETE` | Superuser |

Akun lain yang sudah login mendapat 403; token yang tidak valid mendapat 401.

**Status deployment (26 November 2026).** Backend sudah di-deploy ulang ke `pws.cs.ui.ac.id` (commit Django `76552ea`), sehingga APK dari CI mengarah ke API yang aktif. Yang sudah diperiksa terhadap deployment tercantum di [Hasil Uji terhadap Deployment](#hasil-uji-terhadap-deployment-26-november-2026). Sebelumnya (24 November) deployment masih menjawab 404 untuk `/api/v1/*`, sehingga uji tulis (`POST`, `PATCH`, `DELETE`) di bawah dilakukan terhadap **salinan lokal** backend.

APK release dibuat oleh GitHub Actions dengan `API_BASE_URL` mengarah ke backend yang di-deploy, dan dapat diunduh dari artefak `app-release-apk` pada tab **Actions**.

### Menguji Form Experience Secara Manual

1. Dari halaman utama, buka formulir lewat kartu **Tambah Experience**, lalu ulangi lewat drawer (**Add Experience**). Kedua jalur harus membuka halaman yang sama.
2. Tekan **Simpan** dengan semua kolom kosong. Pesan kesalahan harus muncul di tiap kolom wajib dan dialog tidak boleh muncul.
3. Isi **Posisi** hanya dengan spasi, atau isi **Tautan** dengan `linkedin.com/in/saya` (tanpa `https://`). Keduanya harus ditolak.
4. Pilih tanggal selesai lebih dulu, lalu pilih tanggal mulai yang lebih akhir. Pesan "Tanggal selesai tidak boleh sebelum tanggal mulai" harus muncul pada kolom tanggal selesai.
5. Aktifkan **Masih berlangsung**. Kolom tanggal selesai harus nonaktif dan tidak lagi wajib.
6. Lengkapi isian lalu tekan **Simpan**. Dialog harus menampilkan data yang baru dimasukkan. Tekan **Tutup**; formulir kembali kosong.
7. Buka drawer lalu tekan **Home**. Halaman utama tampil, dan tombol Back sistem tidak lagi menampilkan halaman utama kedua.
8. Ulangi langkah 2 dan 6 pada lebar jendela ponsel (sekitar 360 px) untuk memastikan tombol **Simpan** tetap terjangkau.

Pemeriksaan yang sama berjalan otomatis lewat `flutter test` (242 test sejak Tugas 9).

### Hasil Uji Manual di Chrome (23 November 2026)

Dijalankan oleh AI lewat ekstensi Chrome terhadap `flutter run -d web-server` (mode debug) pada lebar jendela desktop, lalu lebar ponsel 360 × 640 px (aplikasi disematkan dalam iframe karena jendela browser tidak dapat dikecilkan).

| Pemeriksaan | Hasil |
| --- | --- |
| Kartu **Tambah Experience** membuka form | Lolos |
| Drawer: opsi, penanda halaman aktif (di form Experience dan di Home), Home dari form, Add Project dari Home | Lolos |
| Simpan dengan semua kolom kosong | Lolos: pesan muncul di setiap kolom wajib; halaman menggulir ke kolom pertama |
| Posisi hanya berisi spasi | Lolos: ditolak |
| Tautan `linkedin.com/in/saya` | Lolos: ditolak dengan pesan format |
| Date picker: tanggal setelah hari ini nonaktif (mulai), tanggal sebelum tanggal mulai nonaktif (selesai) | Lolos |
| Tanggal mulai diubah menjadi setelah tanggal selesai | Lolos: pesan urutan muncul seketika di kolom tanggal selesai |
| Sakelar **Masih berlangsung** | Lolos: kolom selesai dikosongkan, nonaktif, error hilang |
| Data valid → dialog → **Tutup** | Lolos: dialog memuat semua isian (periode "23 November 2026 - Sekarang"), formulir kembali kosong |
| Lebar 360 px: tata letak, tombol Simpan terjangkau, kartu menu 3 kolom | Lolos |
| Lebar 360 px: pesan error tanggal selesai | **Cacat ditemukan:** pesan dipotong "…". Diperbaiki dengan `errorMaxLines: 3` (`ce30c75`) dan diverifikasi ulang: pesan turun ke baris kedua dan terbaca utuh |

**Belum diuji di browser:** papan ketik layar sungguhan (browser desktop tidak dapat mensimulasikannya; dicakup test `experience_form_test.dart` dengan papan ketik 300 px), deskripsi lebih dari 1000 karakter, tombol Reset, pilihan dropdown yang tercermin di dialog, drawer **Add Experience** dari halaman utama, kedalaman tumpukan halaman setelah Home (dicakup `navigation_test.dart`), dan perangkat Android/iOS nyata. SnackBar "Kamu telah menekan tombol…" dari Tugas 7 tetap muncul di atas formulir selama sekitar empat detik setelah kartu ditekan; perilaku itu disengaja dipertahankan karena Tugas 7 mensyaratkannya.

### Menguji Skills Secara Manual

Prasyarat: Django lokal berjalan dengan basis data yang memuat skill dan sebuah akun superuser (lihat [Backend dan Autentikasi](#backend-dan-autentikasi)), dan Flutter dijalankan dengan `--dart-define=API_BASE_URL` yang mengarah ke sana.

1. Tanpa login, buka **Lihat Skills**. Daftar harus tampil dengan ikon, nama, kategori, dan jumlah bintang. Tarik ke bawah untuk memuat ulang.
2. Buka salah satu skill. Layar detail harus tampil **tanpa** tombol pensil dan tempat sampah.
3. Tekan kartu **Tambah Skill**. Layar Login harus muncul; setelah login berhasil, form tambah skill terbuka.
4. Tekan **Save** dengan kolom kosong: pesan wajib harus muncul pada **Nama Skill** dan **URL Ikon**.
5. Isi data valid lalu **Save**. Dialog sukses harus muncul; **Lihat Daftar** harus menampilkan skill baru.
6. Buka skill itu. Tombol pensil dan tempat sampah harus tampil. Ubah nama lewat pensil, simpan; daftar harus menampilkan nama baru.
7. Cabut token di server (mis. `Token.objects.filter(user__username=...).delete()` di `manage.py shell`), lalu tekan tempat sampah dan **Hapus**. Aplikasi harus menampilkan SnackBar, menghapus sesi, dan membuka layar Login; setelah login ulang, pengguna kembali ke detail dengan petunjuk untuk menekan Hapus sekali lagi.
8. Tekan **Hapus** lagi. Skill harus hilang dari daftar.

### Hasil Uji Manual Skills di Chrome (24 November 2026)

Dijalankan oleh AI lewat ekstensi Chrome terhadap `flutter run -d web-server` (mode debug) dengan `API_BASE_URL` ke **salinan lokal** Django (basis data SQLite sementara berisi 12 skill bawaan). Seluruh uji memakai satu akun superuser uji; peran *Editor* dan akun biasa **tidak** diuji lewat UI, hanya lewat skrip dan test (lihat di bawah).

| Pemeriksaan | Hasil |
| --- | --- |
| Daftar skill publik dimuat dari Django nyata tanpa login | Lolos |
| Detail skill tanpa login: tanpa tombol ubah/hapus | Lolos |
| Drawer menandai **Skills** sebagai halaman aktif | Lolos |
| **Tambah Skill** tanpa login → Login → kembali ke form | Lolos |
| Save dengan kolom kosong | Lolos: dua pesan wajib muncul |
| Save data valid (`POST` 201) → dialog → **Lihat Daftar** | Lolos: skill baru muncul pada daftar yang dimuat ulang dari server |
| Ubah nama lewat form mode ubah (`PATCH` 200) | Lolos: SnackBar "Skill diperbarui." dan daftar menampilkan nama baru |
| Hapus dengan token yang sudah dicabut (`DELETE` 401) | Lolos: SnackBar "Anda perlu login untuk melakukan tindakan ini.", sesi dihapus, layar Login terbuka |
| Login ulang setelah 401 | Lolos: kembali ke detail dengan petunjuk "Tekan Hapus sekali lagi." |
| Hapus ulang (`DELETE` 204) | Lolos: SnackBar konfirmasi dan skill hilang dari daftar |
| Ikon skill pada daftar dan detail | **Cacat ditemukan:** semua ikon tampil sebagai ikon gambar rusak. Penyebab: URL ikon bawaan (`https://cdn.simpleicons.org/<nama>`) menyajikan `image/svg+xml`, yang tidak bisa digambar `Image.network`. Diperbaiki dengan `flutter_svg` dan pemilihan format dari URL di `RemoteImage` (`862f0b2`), lalu diverifikasi ulang: ikon Docker, Figma, Git, JavaScript, Jira, Next.js, Notion, Python, React, dan lainnya tampil |

**Catatan tentang cacat ikon:** 229 test otomatis saat itu hijau dan **tidak menangkapnya**, karena test memakai URL `.png` dan lingkungan test menolak semua permintaan gambar. Hanya melihat layar dengan data nyata yang menemukannya. Test regresi ditambahkan di `remote_image_test.dart` (11 test). Tiga di antaranya, yang menguji jalur SVG, terbukti merah sebelum perbaikan; delapan lainnya mengunci perilaku raster yang memang sudah benar agar tidak rusak oleh perbaikan itu.

**Belum diuji di browser pada sesi ini:** lebar ponsel 360 px untuk layar Skills (daftar dan detail kemudian diuji pada 26 November, lihat di bawah), papan ketik layar sungguhan, akun *Editor* dan akun biasa lewat UI, serta perangkat Android/iOS nyata. Tombol hapus pada mode debug berada tepat di bawah pita "DEBUG" di pojok kanan atas; tetap bisa diketuk dan pita itu tidak ada pada build release.

**Pengujian lapisan API (skrip, bukan UI).** Di luar browser, `ApiClient` yang sama dijalankan melawan salinan lokal Django yang sama lewat skrip sekali pakai (tidak masuk repositori), 24 pemeriksaan lolos: GET publik, login untuk tiga peran (superuser, *Editor*, akun biasa), `POST` (201; 403 untuk *Editor* dan akun biasa; 401 untuk token palsu; 400 untuk URL ikon tidak valid), penyaringan tag HTML oleh server, `PATCH` (superuser dan *Editor* boleh; akun biasa 403; id tidak ada 404), `DELETE` (superuser 204; *Editor* 403; ulang 404), serta token yang dicabut setelah logout menjadi 401.

### Hasil Uji terhadap Deployment (26 November 2026)

Dijalankan oleh AI setelah backend di-deploy ulang: pemeriksaan HTTP dengan `curl`, lalu `flutter run -d web-server` dengan `API_BASE_URL` ke `https://salwa-alifia-myportofolio.pws.cs.ui.ac.id` di Chrome. Lebar 360 × 640 px memakai iframe karena jendela browser tidak dapat dikecilkan.

| Pemeriksaan | Hasil |
| --- | --- |
| `GET /api/v1/skills/` dan `/api/v1/projects/` | Lolos: 200 |
| Login dengan kredensial salah | Lolos: 400 dengan pesan galat |
| `POST /api/v1/skills/` tanpa token / dengan token palsu | Lolos: 403 / 401 |
| Preflight CORS (`Authorization`, `PATCH`, `DELETE`) | Lolos |
| Daftar dan detail skill beserta ikon SVG, lebar desktop dan 360 px | Lolos |
| **Add Skill** tanpa login membuka layar Login | Lolos |

**Belum diuji terhadap deployment:** login dengan akun yang valid serta `POST`, `PATCH`, dan `DELETE` yang berhasil (AI tidak memegang kredensial), form Add Skill 360 px di browser (dicakup `skill_form_test.dart`), dan APK pada perangkat Android nyata.

---

## Refleksi Mingguan

### Tugas 7

1. **Widget tree dan hubungan induk-anak.**
   Di Flutter hampir semuanya adalah widget, dan tampilan dibangun dengan **menyusun widget di dalam widget lain** sehingga membentuk pohon (*widget tree*). Widget yang membungkus widget lain disebut induk (*parent*), dan widget yang dibungkus disebut anak (*child*). Pada proyek ini, pohon halaman menu kira-kira seperti ini:

   ```text
   MyApp
   └── MaterialApp
       └── MyHomePage
           └── Scaffold
               ├── AppBar
               │   └── Text("MyPortfolio")
               └── SingleChildScrollView
                   └── Padding
                       └── Column
                           ├── Row
                           │   └── Flexible × 3
                           │       └── InfoCard
                           │           └── Card → Container → Column → Text, SizedBox, Text
                           ├── SizedBox
                           └── Center
                               └── Column
                                   ├── Padding → Text("Selamat datang ...")
                                   └── GridView.count
                                       └── ItemCard × 6
                                           └── Material → InkWell → Container → Center
                                               └── Column → Icon, Padding, Text
   ```

   Hubungan induk-anak bekerja dengan tiga aturan: (a) induk **menurunkan batasan ukuran** (*constraints*) ke anak, (b) anak **menentukan ukurannya sendiri** dalam batasan itu lalu melaporkannya ke induk, dan (c) induk **menentukan posisi** anak. Misalnya `Row` memberi batas lebar ke tiap `Flexible`, `InfoCard` menyesuaikan diri, lalu `Row` meletakkannya berjajar. Data juga mengalir dari induk ke anak lewat konstruktor, contohnya `ItemCard(item)`. Karena itu, kalau sebuah widget berubah, hanya cabang pohon di bawahnya yang perlu dibangun ulang.

2. **Widget yang digunakan dalam proyek dan fungsinya.**

   | Widget | Fungsi dalam proyek |
   | --- | --- |
   | `MyApp` (kustom) | Widget akar aplikasi (`StatelessWidget`) |
   | `MaterialApp` | Membungkus aplikasi dengan tema, judul, dan halaman awal Material Design |
   | `MyHomePage` (kustom) | Halaman menu utama |
   | `Scaffold` | Kerangka halaman: menyediakan `appBar`, `body`, dan tempat SnackBar |
   | `AppBar` | Bar judul di bagian atas halaman |
   | `Text` | Menampilkan teks (judul, isi kartu, sambutan, nama tombol) |
   | `SingleChildScrollView` | Membuat isi halaman bisa di-scroll agar tidak overflow |
   | `Padding` | Memberi jarak di sekeliling anaknya |
   | `Column` | Menyusun anak secara vertikal |
   | `Row` | Menyusun tiga `InfoCard` secara horizontal |
   | `Flexible` | Membuat anak di `Row` bisa mengecil saat layar sempit |
   | `InfoCard` (kustom) | Kartu informasi reusable (judul + isi) |
   | `Card` | Kartu Material dengan bayangan (elevasi) |
   | `Container` | Kotak pembungkus untuk mengatur lebar dan padding |
   | `SizedBox` | Memberi jarak kosong dengan ukuran tetap |
   | `Center` | Menempatkan anak di tengah |
   | `GridView.count` | Menyusun `ItemCard` dalam kisi 3 kolom |
   | `ItemCard` (kustom) | Kartu tombol menu berwarna |
   | `Material` | Permukaan Material berwarna dengan sudut membulat; wadah efek ripple |
   | `InkWell` | Mendeteksi sentuhan (`onTap`) dan menampilkan efek ripple |
   | `Icon` | Menampilkan ikon pada tombol |
   | `SnackBar` | Notifikasi singkat di bawah layar, ditampilkan lewat `ScaffoldMessenger` |

3. **Fungsi `MaterialApp` dan alasan dipakai sebagai root widget.**
   `MaterialApp` adalah widget pembungkus yang menyiapkan semua yang dibutuhkan aplikasi bergaya Material Design: **tema** (`theme`, termasuk `ColorScheme` dan `useMaterial3`), **judul** aplikasi, **halaman awal** (`home`), **sistem navigasi** (`Navigator` dan `routes`), **`MediaQuery`** dan arah teks, serta **`ScaffoldMessenger`** yang dipakai untuk menampilkan SnackBar. Widget seperti `Scaffold`, `AppBar`, dan `InkWell` memerlukan "leluhur" tersebut. Tanpa `MaterialApp` di akar, pemanggilan seperti `Theme.of(context)` atau `ScaffoldMessenger.of(context)` akan gagal karena tidak menemukan induk yang menyediakannya. Karena itu `MaterialApp` umumnya ditaruh di paling atas pohon, tepat di bawah `runApp`. (Alternatifnya `CupertinoApp` untuk gaya iOS, tetapi `MaterialApp` yang paling umum.)

4. **`StatelessWidget` vs `StatefulWidget`.**
   `StatelessWidget` **tidak menyimpan state yang berubah**: tampilannya hanya bergantung pada data yang diberikan lewat konstruktor (dan data warisan seperti tema), sehingga jika dibangun ulang dengan data yang sama hasilnya selalu sama. `StatefulWidget` memiliki objek `State` terpisah yang **bertahan di antara pembangunan ulang**. Ia menyimpan data yang berubah, dan setiap perubahan dibungkus `setState()` agar Flutter membangun ulang tampilannya. `State` juga punya siklus hidup (`initState`, `dispose`).
   **Pilih Stateless** untuk tampilan statis, seperti `MyHomePage`, `InfoCard`, dan `ItemCard` di proyek ini. **Pilih Stateful** jika tampilan berubah akibat interaksi atau waktu, misalnya penghitung (counter) bawaan Flutter, isi form, checkbox, animasi, atau data yang dimuat. Itu sebabnya di Tutorial 8 `MyHomePage` diubah dari Stateful ke Stateless setelah logika `_counter` dihapus.

5. **`BuildContext` dan penggunaannya di metode `build`.**
   `BuildContext` adalah **penunjuk posisi sebuah widget di dalam widget tree**. Lewat konteks inilah sebuah widget bisa "naik" ke leluhurnya untuk mengambil informasi. Setiap metode `build(BuildContext context)` menerima konteks widget itu sendiri. Contoh di proyek ini: `Theme.of(context).colorScheme.primary` mengambil warna dari tema milik `MaterialApp` di `MyHomePage`, `MediaQuery.of(context).size.width` mengambil lebar layar di `InfoCard`, dan `ScaffoldMessenger.of(context)` mencari `ScaffoldMessenger` terdekat di `ItemCard` untuk menampilkan SnackBar. Konteks penting karena menentukan **dari posisi mana pencarian dimulai**: pencarian hanya menemukan leluhur, bukan widget saudara atau anak.

6. **Hot reload vs hot restart, dan kapan harus restart.**
   **Hot reload** menyuntikkan kode Dart yang baru ke mesin virtual yang sedang berjalan lalu membangun ulang widget tree. **State aplikasi dipertahankan**, jadi perubahan tampilan terlihat dalam hitungan detik tanpa kembali ke awal. **Hot restart** menjalankan ulang aplikasi dari `main()`, sehingga **state direset** ke kondisi awal, tetapi tetap lebih cepat daripada membangun ulang seluruh aplikasi. **Full restart** (hentikan lalu `flutter run` lagi) mengompilasi ulang aplikasi native secara penuh.
   Hot reload **tidak cukup** jika: mengubah `main()` atau isi variabel global/`static` (inisialisasi awalnya tidak dijalankan ulang), mengubah logika `initState` (hanya berjalan sekali saat `State` dibuat), mengubah tipe seperti mengganti `StatelessWidget` menjadi `StatefulWidget` atau mengubah `enum`/generik, atau state yang tersimpan terlanjur salah dan perlu direset (butuh **hot restart**). Perlu **full restart** jika menambah atau mengubah dependensi di `pubspec.yaml` (dengan `flutter pub get`), aset, atau kode native seperti `AndroidManifest.xml` dan konfigurasi Gradle/Xcode, serta mengubah plugin native.

### Tugas 8

1. **`Navigator.push()`, `pushReplacement()`, dan `pop()`.**
   Navigator mengelola **tumpukan halaman (route)**; halaman paling atas yang terlihat.
   - `push()` menaruh halaman baru **di atas** tumpukan. Halaman lama tetap hidup di bawahnya, sehingga pengguna bisa kembali ke sana.
   - `pushReplacement()` **mengganti** halaman teratas dengan halaman baru. Halaman lama dibuang, jadi tidak ada yang bisa dikembalikan lewat tombol Back.
   - `pop()` **membuang** halaman teratas dan menampilkan halaman di bawahnya.

   **Untuk membuka formulir dari kartu aksi dipakai `Navigator.push()`** (di `ItemCard`, `lib/widgets/project_card.dart`). Tumpukannya menjadi `[Home, Form]`, sehingga tombol Back bawaan perangkat langsung kembali ke halaman utama.

   **Opsi Home di drawer** (`LeftDrawer._open`, `lib/widgets/left_drawer.dart`) memakai `Navigator.pushAndRemoveUntil(context, route, (route) => false)`. Fungsi itu mendorong `MyHomePage` baru lalu **membuang seluruh halaman di bawahnya** (predikat `false` berarti tidak ada yang dipertahankan), sehingga tumpukan menjadi `[Home]`. Awalnya (pola Tutorial 9) Home memakai `pushReplacement()`, tetapi cara itu hanya mengganti halaman teratas: jika form dibuka dari kartu, tumpukan `[Home, Form]` berubah menjadi `[Home, Home]` dan pengguna menemukan halaman utama kedua saat menekan Back. Test `navigation_test.dart` membuktikannya: dengan `pushReplacement`, `Navigator.canPop()` bernilai `true`; dengan `pushAndRemoveUntil`, `false`. Opsi **Add Project** dan **Add Experience** tetap memakai `pushReplacement()` karena berpindah antarformulir tidak perlu menumpuk halaman, dan memilih halaman yang sedang aktif hanya memanggil `pop()` untuk menutup drawer (supaya isian form tidak terhapus oleh pembangunan ulang halaman).

2. **Susunan `Scaffold`, `AppBar`, dan `Drawer`.**
   `Scaffold` adalah kerangka tetap setiap halaman: slot `appBar` untuk judul, `drawer` untuk navigasi, dan `body` untuk isi, serta tempat SnackBar ditampilkan. Karena setiap halaman (`MyHomePage`, `ProjectFormPage`, `ExperienceFormPage`) memakai susunan slot yang sama, pengguna selalu menemukan judul di tempat yang sama dan ikon hamburger yang sama. `LeftDrawer` ditulis **satu kali** dan dipakai ulang di ketiga halaman; yang berbeda hanya parameter `selected` untuk menandai halaman aktif. Menambah halaman baru cukup menambah satu entri di daftar `_entries`.

   **Contoh warna tema di lebih dari satu halaman:** warna utama portofolio berasal dari `ColorScheme.fromSeed(seedColor: Colors.indigo)` di `MyApp`, dan `colorScheme.primary` dipakai di **AppBar halaman utama, AppBar form Project, AppBar form Experience** (ditetapkan sekali di `AppBarTheme`), **header drawer**, tombol **Simpan**, penanda menu drawer yang aktif, dan ikon dialog ringkasan. Awalnya form dan drawer memakai `Colors.indigo` yang tertulis langsung, sehingga sedikit berbeda dengan warna halaman utama; sekarang `theme_test.dart` memeriksa bahwa warna AppBar yang dirender identik di ketiga halaman.

3. **Alasan tata letak formulir dan peran widget jarak serta penggulir.**
   Formulir disusun sebagai `Column` di dalam `SingleChildScrollView`, di dalam `SafeArea`, dengan lebar dibatasi `ConstrainedBox(maxWidth: 600)`. Satu kolom vertikal cocok untuk formulir: pengguna mengisi dari atas ke bawah, tiap kolom memakai lebar penuh sehingga mudah disentuh, dan urutan fokus papan ketik mengikuti urutan visual.
   - **Widget pengatur jarak** (`Padding` 16 px di sekeliling, `spacing: 16` pada `Column`, `spacing: 12` pada baris tombol) menjaga kolom tidak saling menempel, sehingga target sentuh tidak berhimpitan dan pesan kesalahan di bawah kolom punya ruang. `Expanded` membagi lebar baris tombol, dan `isExpanded: true` mencegah dropdown meluap pada layar sempit.
   - **Widget penggulir** (`SingleChildScrollView`) dipilih karena formulir ini lebih tinggi daripada layar ponsel, apalagi saat papan ketik menutupi sebagian layar. `Scaffold` mengecilkan area `body` sebesar tinggi papan ketik, dan `SingleChildScrollView` membuat sisanya bisa digulir, sehingga tidak ada overflow dan tombol **Simpan** tetap terjangkau. `keyboardDismissBehavior: onDrag` menutup papan ketik saat digulir. Pada layar lebar (Chrome), `maxWidth: 600` mencegah kolom melebar berlebihan.

   Hal ini diuji pada layar 360×640 dengan papan ketik 300 px tampil: Simpan dapat dijangkau, dan setelah ditekan halaman menggulir otomatis ke kolom pertama yang salah (`Scrollable.ensureVisible`) agar kesalahan di atas layar tidak terlewat.

4. **Peran `GlobalKey<FormState>`, `validator`, dan `validate()`.**
   - **`GlobalKey<FormState>`** adalah "pegangan" yang menghubungkan tombol Simpan (di luar kolom) dengan `FormState` milik widget `Form`. Tanpa kunci itu tombol tidak bisa memerintahkan seluruh kolom.
   - **`validator`** adalah fungsi pada tiap kolom yang menerima nilainya dan mengembalikan **pesan kesalahan** (`String`) bila ditolak atau `null` bila valid. Aturannya ada di `lib/utils/validators.dart`, bukan di dalam widget, sehingga bisa diuji tanpa UI.
   - **`validate()`** menjalankan semua `validator` sekaligus, menampilkan pesan di `errorText` kolom yang salah, dan mengembalikan `true` hanya jika semuanya `null`. Pada `_submit()`, dialog baru dibuka setelah `validate()` bernilai `true`. `DateFormField` dibuat sebagai `FormField<DateTime>` supaya ikut `validate()` dan `reset()`; jika hanya berupa tombol biasa, tanggal kosong tidak akan terdeteksi.

   **Contoh nilai yang ditolak:** Posisi berisi `"     "` (hanya spasi) ditolak dengan pesan *"Posisi tidak boleh kosong!"*, karena `validateRequired` memangkas spasi sebelum memeriksa. Contoh lain: tautan `linkedin.com/in/saya` (tanpa `https://`) dan deskripsi 1001 karakter.

   **Mengapa memilih jenis input atau papan ketik saja belum cukup:** `keyboardType: TextInputType.url` hanya mengubah **tampilan** papan ketik; pengguna tetap bisa mengetik `abc`, menempel teks apa pun, atau memakai papan ketik perangkat keras. Papan ketik juga tidak mengenal aturan model seperti batas 100 karakter atau "tanggal selesai tidak boleh sebelum tanggal mulai". Dropdown dan date picker memang mencegah nilai di luar pilihan, tetapi hubungan antarkolom (urutan tanggal) tetap perlu `validator`. Validasi adalah penjaga terakhir yang memastikan data yang lolos benar-benar sesuai aturan, apa pun cara masuknya.

### Assignment 9

1. **Mengapa `@JsonSerializable(fieldRename: FieldRename.snake)` dan `@JsonKey(includeToJson: false)`, bukan `Map<String, dynamic>` mentah; satu bug yang dicegah pada model Skill.**
   Dengan `Map` mentah, setiap kunci JSON diketik tangan sebagai string (`json['icon_url']`) dan nilainya bertipe `dynamic`. Salah ketik, misalnya `json['iconURL']`, lolos kompilasi dan baru terlihat saat aplikasi berjalan sebagai `null` atau galat tipe. Dengan `json_serializable`, kunci diturunkan dari **nama properti Dart** yang diperiksa kompilator (`iconUrl` menjadi `icon_url` karena `fieldRename: FieldRename.snake`), dan `fromJson`/`toJson` dihasilkan `build_runner` ke `skill.g.dart`, sehingga tidak ada parsing yang ditulis berulang di tiap layar. Nilai bawaan juga dinyatakan di satu tempat (`@JsonKey(defaultValue: '')` pada `category`).
   `@JsonKey(includeToJson: false)` dipasang pada field yang dimiliki server dan hanya dibaca klien: `id` (UUID dari server), `starCount`, `isStarred`, dan `starredByNames`. Field itu tetap dibaca saat `fromJson`, tetapi tidak ikut `toJson()`, jadi isi body `POST` dan `PATCH` hanya `name`, `icon_url`, dan `category`.
   **Bug yang dicegah:** tanpa `FieldRename.snake`, `iconUrl` akan terkirim sebagai `iconUrl`, sedangkan `SkillSerializer` mengharapkan `icon_url`: server menjawab 400 dengan galat pada field `icon_url` dan **setiap** penambahan skill gagal. Tanpa `defaultValue`, satu skill yang `category`-nya `null` atau hilang akan melempar `type 'Null' is not a subtype of 'String'` dan **seluruh daftar** gagal tampil. Tanpa `includeToJson: false`, objek `Skill` hasil `GET` yang dikirim kembali lewat `PATCH` akan membawa `star_count` lama; hari ini server mengabaikan field itu, tetapi bila kelak menerimanya, angka bintang bisa tertimpa nilai basi (ini risiko yang dicegah, bukan kejadian yang saya alami). Perilaku-perilaku itu dikunci `test/skill_model_test.dart` (pemetaan snake_case, kategori kosong/`null`/hilang, data bintang hilang, dan `id` serta data bintang tidak ikut terkirim).

2. **Mengapa `Future` dibuat di `initState()`, bukan di `build()`; dan mengapa `ApiClient` melempar `ApiException`, bukan mengembalikan `null`.**
   `build()` dipanggil ulang kapan saja framework perlu menggambar ulang: `setState`, papan ketik muncul, rotasi layar, tema berubah, atau induk dibangun ulang. Jika `Future` dibuat di dalamnya, **setiap pembangunan ulang mengirim permintaan HTTP baru** dan `FutureBuilder` kembali ke keadaan menunggu, sehingga layar berkedip dan jaringan terbebani; bila selesainya permintaan itu sendiri memicu pembangunan ulang, siklusnya tidak berhenti. `initState()` dijalankan **sekali** per objek `State`, jadi `SkillListPage` menyimpan `_skillsFuture` dan `FutureBuilder` hanya membaca hasilnya. Muat ulang tetap mungkin karena `_reload()` (dipanggil tombol **Retry**, tarik-untuk-muat-ulang, dan setelah tambah/ubah/hapus) sengaja menetapkan `Future` baru di dalam `setState`; permintaan baru terjadi karena keputusan pengguna, bukan karena penggambaran ulang.
   `ApiClient` melempar `ApiException(statusCode, message)` karena `null` menyatukan keadaan yang harus ditangani berbeda: daftar kosong, 401 (login ulang), 403 (tidak punya izin), 404, galat server, dan jaringan putus tampak sama sebagai "tidak ada data". Eksepsi membawa penyebabnya: `isUnauthorized` memicu login ulang pada `handleApiFailure`, kode `networkErrorCode` (0) menampilkan pesan koneksi, dan `message` sudah berupa kalimat aman untuk pengguna (halaman HTML galat atau *stack trace* Django tidak pernah diteruskan mentah). Eksepsi yang terlewat juga muncul ke permukaan sebagai galat, sedangkan `null` yang terlewat baru meledak jauh dari sumbernya sebagai error pada nilai `null`. Di layar, galat itu mengalir ke `snapshot.hasError` pada `FutureBuilder` lalu menjadi `LoadErrorView` dengan tombol **Retry**.

3. **`SessionAuthentication` vs `TokenAuthentication`, dan mengapa aplikasi mobile memakai token sementara session tetap aktif.**
   Pada **session**, server menyimpan sesi dan klien membawa *cookie* `sessionid` yang dilampirkan **otomatis** oleh browser pada setiap permintaan. Karena otomatis, penyerang bisa membuat browser pengguna mengirim permintaan dari situs lain (*CSRF*); itu sebabnya `SessionAuthentication` mewajibkan token CSRF pada permintaan yang mengubah data. Cara ini cocok untuk halaman web Django dan Django Admin. Pada **token**, klien mengirim `Authorization: Token <key>` **secara eksplisit** pada tiap permintaan; tidak ada cookie yang terlampir otomatis, sehingga tidak ada celah CSRF dan tidak perlu token CSRF. Token juga dapat dicabut di server (`POST /api/v1/auth/logout/` menghapusnya), dan klien non-browser seperti aplikasi Flutter tidak punya *cookie jar* bawaan pada paket `http`.
   Backend ini mendaftarkan **keduanya** di `REST_FRAMEWORK["DEFAULT_AUTHENTICATION_CLASSES"]`: `ApiTokenAuthentication` lebih dulu, lalu `SessionAuthentication`. Aplikasi mobile memakai token karena tidak punya cookie dan menyimpan token di memori (`AuthState`). Session tidak dihapus karena **website dan Django Admin yang sama masih memakainya**; menghapusnya akan merusak situs web. Detail yang saya temukan saat menyelaraskan keduanya: DRF memilih status 401 atau 403 dari kelas autentikasi pertama, sehingga `TokenAuthentication` biasa di urutan pertama membuat semua tamu mendapat 401 alih-alih 403 yang sudah ditangani halaman web. Karena itu `ApiTokenAuthentication` hanya menantang (401) bila permintaan membawa header `Authorization`: tamu tetap 403, sedangkan token yang salah atau sudah dicabut jelas 401 sehingga aplikasi tahu harus meminta login ulang. Ini terlihat langsung pada uji manual: setelah token dicabut lewat `manage.py shell`, `DELETE` menjawab 401 dan aplikasi membuka layar Login. **Kelemahan token:** token DRF bawaan tidak kedaluwarsa, jadi token yang bocor berlaku sampai dicabut; mitigasi yang ada hanya penyimpanan di memori (hilang saat aplikasi ditutup), pembatasan laju `api_token` 10 kali per menit untuk tebakan kata sandi, dan logout yang mencabut token di server.

4. **Peran job `build` (`very_good_workflows`) dan `build_apk`, serta mengapa `*.g.dart` di-ignore Git padahal CI membutuhkannya.**
   Berkas `.github/workflows/main.yaml` berjalan pada `push` ke `main` dan setiap `pull_request`.
   - **`build` (CI, memverifikasi)** memanggil `very_good_workflows/.../flutter_package.yml@v2` dengan Flutter 3.47.9. Urutannya: *checkout*, pasang Flutter, `very_good packages get` (unduh dependensi), jalankan `setup` kita (`dart run build_runner build --delete-conflicting-outputs`, membuat `*.g.dart`), **`dart format --set-exit-if-changed lib test`** (gagal bila ada berkas belum rapi), **`flutter analyze lib test`** (gagal bila ada temuan lint), lalu **`very_good test`** dengan coverage dan urutan test diacak (`--test-randomize-ordering-seed random`) untuk menyingkap test yang saling bergantung. Pada proyek ini `min_coverage` bernilai 0 dan `*.g.dart` dikecualikan dari laporan coverage, jadi **coverage tidak menjadi syarat lulus**; gerbangnya adalah format, analisis, dan test yang lolos.
   - **`build_apk` (CD, menghasilkan)** punya `needs: build`, sehingga **hanya berjalan bila `build` hijau**. Job ini memasang Flutter, `flutter pub get`, `build_runner` lagi, lalu `flutter build apk --release --dart-define=API_BASE_URL=<alamat backend yang di-deploy>` dan mengunggah `app-release.apk` sebagai artefak `app-release-apk`. Dipisah karena tujuannya berbeda: verifikasi harus cepat gagal dan menjadi gerbang, sedangkan kompilasi APK lebih lambat dan tidak berguna jika kodenya tidak lulus; artefak yang bisa diunduh hanya berasal dari kode yang sudah lolos verifikasi.
   - **Mengapa `*.g.dart` di-ignore** (`.gitignore` dan pengecualian `analyzer` di `analysis_options.yaml`): berkas itu **turunan** dari model dan bisa dibuat ulang kapan saja dari kode sumber. Jika di-commit, ia menambah *diff* besar yang berisik, rawan konflik merge, dan bisa **basi** (model diubah tetapi lupa membangkitkan ulang). CI tetap bekerja karena langkah `setup` pada `build` dan perintah `build_runner` pada `build_apk` membuatnya ulang di runner yang bersih sebelum analisis, test, atau kompilasi. Konsekuensinya, setelah `git clone` pengembang wajib menjalankan `dart run build_runner build --delete-conflicting-outputs`; tanpa itu proyek tidak terkompilasi (lihat [Menjalankan Proyek](#menjalankan-proyek)).

#### Catatan lingkup Tugas 9

- **Bagian yang dipilih: Skills, bukan Experience.** Endpoint Skills di Django (Assignment 6) sudah lengkap, sedangkan model Experience di Django tidak cocok dengan form Tugas 8 (tidak ada field `company`, dan `started_at` bersifat `auto_now_add`), sehingga memakainya berarti mengubah model dan memigrasikan basis data produksi di luar lingkup tugas ini.
- **Akibatnya, form Experience dari Tugas 8 tetap lokal dan belum terhubung ke API.** Butir "refactor form dari Assignment 8" dipenuhi dengan **form Skill baru** yang mengikuti pola yang sama (validasi, `GlobalKey<FormState>`, `ensureLoggedIn`, POST bertoken, penanganan `ApiException`), bukan dengan memodifikasi form Experience. Itu penafsiran saya atas soal; jika penilai mengharapkan form Experience yang berubah, butir itu belum terpenuhi persis seperti tertulis.
- **Fitur di luar minimum:** `PATCH` (ubah) dan `DELETE` (hapus) bertoken beserta dialog konfirmasi dan penanganan 401/403, dukungan ikon SVG, serta 242 test otomatis termasuk `MockClient` untuk tiap jalur API.

---

## AI Disclosure

Pada Tutorial 08, Tugas 7, Tugas 8, Tutorial 10, dan Tugas 9 saya menggunakan AI sebagai **asisten implementasi**. Perlu saya nyatakan terus terang: **sebagian besar penulisan kode, test, dokumentasi, dan draf jawaban reflektif dikerjakan oleh AI** berdasarkan instruksi, aturan, dan keputusan saya. Karena porsinya besar, bagian ini sengaja saya tulis rinci, termasuk kesalahan AI yang ditemukan selama prosesnya.

> **Batas catatan:** [log prompt](docs/ai-log.md) mencatat prompt per sesi untuk Tutorial 08, Tugas 7, Tugas 8, dan Tugas 9. Tutorial 9 dan **Tutorial 10** juga dikerjakan dengan Claude Code, tetapi tidak tercatat di log prompt; yang ada untuk keduanya hanya hasil di repositori dan README ini.

### Tools yang Digunakan

| Tools | Peran dalam proses |
| --- | --- |
| **Claude Code** (ekstensi VS Code, model Claude Sonnet 5.5) | Menulis dan mengubah kode Dart langsung pada repositori, menjalankan `flutter analyze` dan `flutter test`, mengelola branch, commit, merge, dan push, menyusun README dan draf jawaban reflektif, menyusun log ini, serta membuat PDF ringkasan belajar (di luar repositori) |
| **Ekstensi Chrome milik Claude Code** (Tugas 8 dan 9) | Menjalankan aplikasi web di Chrome untuk QA manual dan mengambil tangkapan layar; pada Tugas 9 dipakai terhadap salinan lokal Django dengan basis data sementara |

Tool yang tercatat pada pengerjaan proyek mobile ini hanya Claude Code beserta ekstensi Chrome-nya. Log lengkap prompt dan hasilnya ada di [docs/ai-log.md](docs/ai-log.md).

### Pembagian Peran

```text
Saya                                    Claude Code
 │                                          │
 ├─ menyiapkan lingkungan                   ├─ menulis dan mengubah kode Dart
 │  (Flutter SDK, flutter create)           ├─ menjalankan analyze dan test
 ├─ menetapkan aturan kerja                 ├─ branch, commit, merge, push
 ├─ memutuskan lingkup tugas                ├─ menyusun draf README dan jawaban
 ├─ menjalankan aplikasi di Chrome          └─ melaporkan hasil dan kendala
 └─ mempertanyakan klaim AI                          │
        └────────────── saling memverifikasi ────────┘
```

| Bagian pekerjaan | Dikerjakan AI | Peran saya |
| --- | --- | --- |
| Setup Flutter dan `flutter create` | Tidak | Mengerjakan sendiri |
| Kode Tutorial 08 (`menu.dart`, `InfoCard`, `ItemCard`, tema) | Menulis kode mengikuti PDF tutorial | Menetapkan aturan, menyediakan data pribadi, menjalankan aplikasi dan memeriksa tampilan di Chrome |
| Kode Tugas 7 (warna per tombol, 6 tombol, scroll, test) | Menulis kode dan test | Memutuskan lingkup: tombol mengikuti situs Django saya, tanpa fitur star, dan meminta rencana dijelaskan dulu |
| Kode Tugas 8 (form Experience, `AppTextFormField`, `DateFormField`, drawer, kartu aksi, tema, 42 test baru) | Merancang struktur, memilih field formulir Experience, menulis kode dan test, menjalankan `analyze` dan `test` per branch | Menyediakan soal dan rubrik, menetapkan target skor 4 di setiap kriteria, dan aturan tanpa atribusi AI di commit (dari sesi sebelumnya) |
| Kode Tutorial 10 (`ApiClient`, `AuthState`, layar Projects, login, CI/CD) | Menulis kode, test, dan alur kerja GitHub Actions | Tidak tercatat di log prompt (lihat batas catatan di atas) |
| Kode Tugas 9 (model `Skill`, `ApiClient` untuk Skills, layar daftar/detail/form, ubah dan hapus, widget bersama, ikon SVG; test bertambah dari 145 menjadi 240) | Merancang, menulis kode dan test dengan alur uji-dulu, mengekstrak widget bersama dari layar Projects, menjalankan QA browser dan skrip ujung ke ujung terhadap salinan lokal Django | Meminta AI melanjutkan setelah sesi sebelumnya terhenti; mengacu pada rubrik dengan target skor 4 yang saya tetapkan sejak Tugas 8; menanyakan mana yang sebaiknya dipilih antara Skills dan Experience (AI lalu mengerjakan rekomendasinya, Skills, tanpa konfirmasi eksplisit saya) |
| Git (branch, merge `--no-ff`, push) | Menjalankan perintah | Menetapkan alur kerja dan larangan trailer `Co-Authored-By`; pada Tugas 9 **tidak ada merge atau push** yang dilakukan AI tanpa izin baru dari saya |
| README dan jawaban reflektif | Menyusun draf | Meminta dijelaskan dan menjadikannya bahan belajar |
| PDF ringkasan belajar | Menyusun | Dipakai untuk persiapan quiz dan UTS (tidak termasuk repositori) |

---

## Strategi Prompting

Saya tidak memakai satu prompt besar untuk semuanya. Pola yang saya pakai (contoh kutipan ada di [docs/ai-log.md](docs/ai-log.md)):

```text
1. Tetapkan aturan dan batasan di depan
        ↓
2. Minta rencana dijelaskan sebelum ada kode yang berubah
        ↓
3. Kerjakan per branch kecil, verifikasi sebelum merge
        ↓
4. Pertanyakan klaim AI yang terdengar yakin
        ↓
5. Minta arti istilah atau pilihan yang belum saya pahami
        ↓
6. Verifikasi di luar AI (jalankan aplikasi, periksa git log)
```

- **Aturan di depan:** tanpa atribusi AI di commit, berkas tutorial tidak boleh masuk repositori, satu bagian satu branch, dan **berhenti dan kabari saya** jika ada konflik atau keputusan ambigu.
- **Rencana dulu:** pada Tugas 7 saya meminta rencana lebih dulu, dengan rubrik sebagai acuan. AI mengajukan pertanyaan keputusan sebelum mengerjakan.
- **Pertanyakan klaim:** misalnya "ini beneran gpp kah" untuk test yang gagal dan "udah di merge belum ya ke main" sebelum submit.
- **Minta rekomendasi beralasan, bukan pilihan buta (Tugas 9):** ketika AI menanyakan Skills atau Experience, saya menjawab "kalau dari tugas dan kriteria penilaian serta best practice kode etc sebaiknya yg mana ya". AI memberi rekomendasi beserta pertukarannya, lalu langsung mengerjakannya; saya seharusnya bisa menahan keputusan itu, sehingga risikonya tetap pada saya (lihat butir 16 pada Evaluasi Kritis).

---

## Belajar Menggunakan AI

Selain membantu implementasi, saya memakai AI sebagai **alat belajar**, bukan hanya untuk menyerahkan pekerjaan. Hal yang benar-benar saya lakukan:

- **Meminta rencana dijelaskan sebelum dikerjakan.** Pada Tugas 7 saya meminta penjelasan rencana lebih dulu dan menulis "sekalian ajarin aku", supaya saya paham alasan di balik tiap langkah, bukan hanya hasil akhirnya.
- **Menanyakan hal yang belum saya mengerti.** Contohnya menanyakan maksud istilah tugas ("IA7 apa") dan maksud pilihan yang diajukan AI (6 tombol, `childAspectRatio`, test baru) sebelum memutuskan.
- **Meminta bahan belajar dari hasil kerja.** Saya meminta PDF ringkasan Tutorial 08 dan Tugas 7 untuk persiapan quiz dan UTS: konsep widget tree, `StatelessWidget` vs `StatefulWidget`, `BuildContext`, hot reload vs hot restart, dan alasan tiap baris kode ditulis. PDF ini tidak termasuk repositori.
- **Meminta soal latihan coding** (membaca kode, mengisi bagian kosong, mencari bug) untuk menguji apakah saya paham kode, sintaks, dan alurnya sendiri.
- **Mempertanyakan klaim AI,** misalnya soal test bawaan yang gagal dan status merge ke `main`, lalu memeriksa hasilnya sendiri (menjalankan aplikasi di Chrome dan membaca `git log`).

Jawaban reflektif pada [Tugas 7](#tugas-7) saya jadikan bahan belajar: saya membacanya, membandingkannya dengan kode yang berjalan, dan memakainya untuk memahami konsepnya.

Pada Tugas 9 saya menanyakan pilihan lingkup ("sebaiknya yg mana ya") alih-alih memilih tanpa dasar, sehingga alasan tiap opsi (kecocokan model Django, beban migrasi, kesesuaian dengan rubrik) menjadi bahan yang bisa saya jelaskan ulang.

---

## Evaluasi Kritis terhadap AI

### 1. Edit teks massal oleh AI dapat gagal tanpa suara

Skrip penyisip kode pada langkah `ItemCard` tidak cocok dengan line-ending CRLF di Windows, sehingga list `items` tidak pernah tersisip dan commit tetap dibuat. Tidak ada pesan error dari skrip itu. Hanya `flutter analyze` yang menangkapnya (`Undefined name 'items'`).

### 2. AI dapat menyatakan sesuatu tanpa memverifikasinya

AI menyebut test bawaan "hampir pasti gagal" tanpa menjalankannya. Setelah saya mempertanyakannya, barulah `flutter test` dijalankan dan kegagalannya terkonfirmasi. Dua klaim teknis pada draf dokumentasi (hot reload web yang "eksperimental" dan tipe `Colors.amber[700]`) juga tidak bisa diverifikasi dan akhirnya dihapus atau diganti.

### 3. Test yang lolos tidak sama dengan tampilan yang benar

Font bawaan test (Ahem) jauh lebih lebar daripada font asli, sehingga overflow tinggi teks di test tidak mencerminkan perangkat nyata. Test akhirnya hanya memeriksa geometri (posisi kartu). Test juga tidak menggantikan melihat aplikasi langsung di browser atau perangkat.

### 4. AI dapat menebak maksud yang tidak jelas

Ketika saya hanya menulis "kerjain tugasnya", AI menebak tugas yang dimaksud adalah Individual Assignment 7. Tebakannya memang ditandai sebagai tebakan dan diminta dikonfirmasi, tetapi tanpa itu hasil kerjanya bisa salah arah.

### 5. AI cenderung mengusulkan lebih dari minimum

Untuk Tugas 7 AI mengusulkan 6 tombol, rasio kartu, dan test baru (target skor 4). Saya perlu menanyakan arti opsi tersebut sebelum menyetujuinya. Usulan yang tidak dipahami sebaiknya tidak langsung diterima.

### 6. Kegagalan alur kerja dapat menggeser branch diam-diam

Saat skrip edit gagal pada branch integrasi UI, perintah berikutnya tetap berjalan dan perubahan sempat berada di `main` yang belum di-commit. AI memindahkannya ke branch fitur sebelum commit, tetapi tanpa pemeriksaan `git branch --show-current` hal ini mudah terlewat.

### 7. Pengaturan bawaan alat dapat bertentangan dengan keinginan saya

Claude Code secara bawaan mengarahkan penambahan trailer `Co-Authored-By` pada commit. Saya melarangnya, dan pada Tugas 8 AI tetap mengikuti larangan itu walau konfigurasi alat menyuruh sebaliknya. Seluruh commit di repositori ini memuat 0 trailer tersebut (`git log --format=%B | grep -ci "co-authored-by"` bernilai 0). Karena riwayat commit sengaja dibiarkan bersih, **pengungkapan penggunaan AI saya letakkan di README ini**.

### 8. AI tidak menggantikan pemahaman saya

Yang akan diuji pada quiz dan UTS adalah pemahaman saya, bukan AI. Karena itu jawaban reflektif dan PDF belajar hanya berguna jika saya benar-benar memahami dan mampu menjelaskan ulang isinya sendiri.

### 9. Perintah yang terpotong ditafsirkan, bukan ditanyakan (Tugas 8)

Perintah saya berakhir di "coba cek dan" (terpotong). AI menafsirkannya sebagai "periksa repositori lalu kerjakan" dan langsung mengimplementasikan seluruh tugas. Tafsirannya kebetulan sesuai, tetapi AI seharusnya menanyakan kelanjutan kalimat itu sebelum menulis banyak kode. AI juga memilih sendiri formulir **Experience** tanpa bertanya.

### 10. Rancangan model dibuat tanpa melihat sumbernya (Tugas 8)

Field formulir Experience (posisi, perusahaan, jenis, tanggal mulai/selesai, deskripsi, tautan) adalah rancangan AI. AI **tidak membuka model Experience di proyek Django saya**, sehingga kesesuaian dengan model sebenarnya belum terjamin dan perlu saya cocokkan sendiri.

### 11. AI menulis test yang mustahil karena fiturnya sendiri (Tugas 8)

Test pertama untuk "tanggal selesai sebelum tanggal mulai" mengasumsikan pengguna bisa membuka bulan sebelumnya pada date picker tanggal selesai. Padahal AI sendiri membatasi `firstDate` picker itu dengan tanggal mulai. Test gagal dan menunjukkan bahwa UI memang mencegah urutan terbalik, sehingga skenarionya diganti (pilih tanggal selesai lebih dulu). Pelajarannya: test dari AI bisa salah memahami kodenya sendiri.

### 12. Test yang hijau belum tentu bermakna (Tugas 8)

Untuk dua fitur yang tidak terlihat dari luar (gulir otomatis ke kolom yang salah, dan Home yang tidak menumpuk halaman), AI mematikan fiturnya sementara untuk memastikan testnya **gagal**. Keduanya gagal sebagaimana mestinya (kolom berada di y = -424; `canPop()` bernilai `true`), baru kemudian kode dikembalikan. Langkah yang sama dipakai pada perbaikan pesan error multibaris: perbaikannya dikembalikan sementara dan dua test baru gagal. Tanpa langkah ini, test yang lolos tidak membuktikan apa-apa.

### 13. Alur perintah AI dapat menyembunyikan kegagalan (Tugas 8)

AI memeriksa hasil analisis dengan `flutter analyze | tail`, dan pipa itu menutupi kode keluar `analyze`. Satu temuan analyzer pada berkas test yang belum di-commit tidak menghentikan rangkaian perintah. Kode yang di-commit tidak terdampak, tetapi pola itu rapuh.

### 14. Verifikasi di browser: percobaan pertama gagal, tuntas dengan cara lain (Tugas 8)

Percobaan pertama AI memakai `flutter build web --release`, tetapi hasil build di mesin ini kehilangan folder `assets/` (ikon tampil sebagai kotak) dan tangkapan layar gagal tiga kali (*timeout*). AI berhenti dan tidak mengklaim tampilannya benar. Setelah saya meminta QA manual lewat browser, AI beralih ke `flutter run -d web-server` yang menyajikan aset dari memori, dan pengujian berjalan (hasil lengkap ada di [Hasil Uji Manual](#hasil-uji-manual-di-chrome-23-november-2026)). Uji ini menemukan cacat yang **tidak tertangkap 63 test otomatis**: pesan error terpotong pada lebar ponsel. Batasannya tetap ada: AI hanya menguji mode debug di Chrome desktop dan iframe 360 px, bukan perangkat nyata atau papan ketik layar sungguhan.

### 15. Skor rubrik tidak bisa dijamin AI

Kriteria skor 4 memuat penilaian subjektif ("optimasi kode tingkat lanjut", "dokumentasi berkualitas open-source"). AI hanya dapat memenuhi indikator yang terukur (struktur modular, docstring, branch per fitur, conventional commits, analisis kritis), dan tidak dapat menjanjikan skor akhir.

### 16. Pilihan lingkup datang dari rekomendasi AI, dan rekomendasi itu tidak netral (Tugas 9)

Soal meminta satu bagian portofolio selain Project. Ketika saya bertanya mana yang sebaiknya dipilih, AI merekomendasikan **Skills** dan **langsung mengerjakannya tanpa menunggu persetujuan eksplisit dari saya**: pertanyaan saya adalah permintaan pendapat, bukan perintah memilih. Alasannya sah dan sudah saya cocokkan dengan kode: endpoint Skills sudah lengkap, sedangkan model Experience di Django tidak cocok dengan form Tugas 8 (tidak ada `company`, `started_at` otomatis). Namun pilihan itu juga jalur yang lebih murah bagi AI, dan akibatnya **form Experience dari Tugas 8 tetap tidak terhubung ke API**; butir "refactor form dari Assignment 8" hanya terpenuhi lewat penafsiran (form Skill baru dengan pola yang sama). AI menyatakan pertukaran ini sebelum mengerjakan, tetapi keputusan akhir dan risikonya ada pada saya.

### 17. Bug yang ditemukan test sebelum kode jadi: galat yang dilempar terlalu cepat (Tugas 9)

`updateSkill` pertama kali ditulis sebagai fungsi biasa yang melempar `ArgumentError` bila skill belum punya `id`. Karena dilempar sebelum fungsi mengembalikan `Future`, metode ini melanggar kontrak semua metode lain `ApiClient` ("kegagalan adalah galat pada `Future`"): pemanggil yang memakai `.catchError` atau `Future.wait` tidak akan menangkapnya lewat jalur `Future`. Test yang ditulis lebih dulu (`skill tanpa id ditolak`) mengharapkan `Future` yang gagal dan menggagalkan versi itu; perbaikannya menjadikan metode tersebut `async`.

### 18. Test yang salah memahami widget-nya sendiri, lagi (Tugas 9)

Test tombol ubah dan hapus gagal dengan `type 'RawTooltip' is not a subtype of 'IconButton'`: `find.byTooltip` menemukan widget `Tooltip`, bukan `IconButton`. Kesalahannya ada pada test, bukan pada layar; diperbaiki dengan pembantu yang mencari `IconButton` lewat ikonnya. Sama seperti butir 11, test dari AI bisa keliru soal kodenya sendiri, dan baru ketahuan karena dijalankan.

### 19. 229 test hijau, tetapi semua ikon skill rusak (Tugas 9)

QA manual di Chrome dengan data nyata menunjukkan **setiap ikon skill tampil sebagai gambar rusak**: URL ikon bawaan menyajikan SVG, yang tidak bisa digambar `Image.network`. Test otomatis tidak menangkapnya karena memakai URL `.png` dan lingkungan test menolak semua permintaan gambar, jadi widget gambar tidak pernah diuji terhadap format yang dipakai data asli. Diperbaiki dengan `flutter_svg` (commit `862f0b2`) dan diverifikasi ulang di browser. Pelajarannya sama dengan butir 3 dan 14: data uji yang dibuat sendiri cenderung hanya membuktikan hal yang sudah diperkirakan.

### 20. Verifikasi ujung ke ujung tidak dilakukan terhadap deployment (Tugas 9)

AI memeriksa deployment `pws.cs.ui.ac.id` dan mendapati `/api/v1/skills/`, `/api/v1/projects/`, dan `/api/v1/auth/token/` menjawab **404**: backend yang berjalan di sana belum memuat API. Karena itu uji ujung ke ujung (browser dan skrip 24 pemeriksaan) dijalankan terhadap **salinan lokal** Django dengan basis data sementara, dan README menyatakannya. Konsekuensinya, **belum ada bukti bahwa APK dari CI bekerja terhadap backend yang di-deploy**; untuk itu backend harus di-deploy ulang (termasuk migrasi `authtoken`), dan tindakan itu sengaja tidak dilakukan AI tanpa izin saya. **Tindak lanjut 26 November:** setelah saya izinkan, backend di-deploy ulang dan jalur baca serta penolakan akses diperiksa terhadap deployment (lihat [hasilnya](#hasil-uji-terhadap-deployment-26-november-2026)).

### 21. Perintah git yang berisiko dipakai pada pohon kerja yang tidak bersih (Tugas 9)

Untuk membandingkan log overflow dengan kondisi awal, AI sekali memakai `git stash` lalu `git stash pop` pada pohon kerja yang berisi tujuh berkas plugin hasil generate (hanya berbeda *line ending*). Tidak ada yang hilang (stash kosong setelahnya, berkas utuh, test hijau), tetapi perintah itu bisa saja bertabrakan dengan berkas yang tidak boleh di-commit, dan seharusnya dihindari; perbandingannya bisa dilakukan lewat `git worktree`. Overflow yang dibandingkan ternyata sudah ada sejak sebelum Tugas 9 (berasal dari `widget_test.dart` dengan font Ahem).

---

## Perbaikan Manual dan Verifikasi

| Masalah | Bantuan AI | Perbaikan / Verifikasi |
| --- | --- | --- |
| Branch `main` belum punya commit sehingga `git checkout main` akan gagal | Mengusulkan dan membuat commit kosong awal | Terlihat di `git log` (`c129a1c`); branch fitur dan merge `--no-ff` setelahnya berjalan normal |
| List `items` tidak tersisip pada commit `ItemCard` | Menulis skrip edit tanpa memeriksa hasilnya | `flutter analyze` menangkap `Undefined name 'items'`, diperbaiki langsung di `main` (`e5168fb`) |
| Perubahan sempat berada di `main` saat skrip gagal | Alur branch bergeser setelah satu perintah gagal | Perubahan dipindahkan ke branch fitur sebelum commit; riwayat `git log` menunjukkan commit berada di branch fitur |
| Test bawaan `widget_test.dart` gagal | Menyebutnya "hampir pasti gagal" tanpa menjalankan | Saya bertanya "ini beneran gpp kah", `flutter test` dijalankan dan kegagalan terkonfirmasi, test diganti (`7df0f2e`) |
| `InfoCard` overflow 4,6 px di layar 360 px | Menulis layout sesuai tutorial apa adanya | Test layar kecil menemukannya; diperbaiki dengan `Flexible` dan padding yang lebih kecil (`33f2c0d`) |
| Test overflow tinggi teks gagal di layar kecil | Menulis test yang terlalu ketat karena font Ahem | Penyebabnya ditelusuri; test diganti memeriksa geometri dan rasio kartu diturunkan ke 0,9 sebagai ruang aman |
| Klaim yang tidak terverifikasi pada draf dokumentasi | Menulis klaim hot reload web dan tipe `Colors.amber[700]` | Dihapus atau diganti sebelum final; log run menampilkan `r Hot reload` |
| Opsi "Ekstra" belum saya pahami | Mengusulkan 6 tombol, rasio kartu, dan test baru | Saya menanyakan maksudnya; dijelaskan dulu, baru dikerjakan |
| Tugas yang dimaksud tidak jelas | Menebak bahwa itu Individual Assignment 7 | Saya mengirim soal resminya; AI menandai bahwa sebelumnya hanya menebak |
| Trailer `Co-Authored-By` pada commit | Bawaan Claude Code mengarahkan penambahannya | Saya melarangnya; pada Tugas 8 AI membaca larangan itu dari log, mengikutinya, dan memeriksa riwayat: 0 trailer, seluruh penulis `salfyea` |
| Tampilan aplikasi belum teruji di browser nyata | Hanya membangun versi web, belum melihatnya | Saya menjalankan aplikasi di Chrome sendiri dan memeriksa tampilannya lewat tangkapan layar |
| **Tugas 8:** Home di drawer menyisakan `[Home, Home]` (pola `pushReplacement` Tutorial 9) | Mengikuti pola tutorial apa adanya pada awalnya | Diganti `pushAndRemoveUntil`; test `navigation_test.dart` membuktikan `canPop()` berubah dari `true` ke `false` (`4c9b0a2`) |
| **Tugas 8:** warna AppBar dan drawer berbeda (`Colors.indigo` vs `colorScheme.primary`) | Warna ditulis langsung per halaman | Dipusatkan di `AppBarTheme`; `theme_test.dart` memeriksa warna yang dirender identik (`71a1b2c`) |
| **Tugas 8:** `ItemCard` memilih tujuan dengan `if (item.name == "Tambah Proyek")` | Menambah kartu baru akan menambah if-else lagi | Tujuan dipindah ke data (`ItemHomepage.destination`) (`30a56d5`) |
| **Tugas 8:** salah impor `MaxLengthEnforcement`, `FakeViewPadding`, `EmploymentType` | Menulis impor tanpa memeriksa paket `material_ui` | `flutter analyze` menangkap ketiganya sebelum commit |
| **Tugas 8:** test tanggal mustahil dan test teks ganda | Menulis skenario yang bertentangan dengan fiturnya sendiri | `flutter test` menggagalkannya; skenario diganti dan pencarian dibatasi ke dialog (lihat [log](docs/ai-log.md)) |
| **Tugas 8:** test lolos belum tentu bermakna | Menulis test untuk fitur tak kasatmata | Mutation check dua kali (gulir ke kolom salah, Home) |
| **Tugas 8:** `flutter build web` di mesin ini menghasilkan `assets/` kosong | Mencoba memverifikasi di Chrome | Percobaan pertama gagal; diganti `flutter run -d web-server` sehingga QA manual di Chrome berjalan |
| **Tugas 8:** pesan error tanggal selesai terpotong "…" di lebar 360 px | Menulis `InputDecoration` tanpa `errorMaxLines`; 63 test lolos tanpa menyadarinya | Ditemukan lewat QA manual di Chrome; diperbaiki dengan `errorMaxLines: 3`, ditambah 2 test regresi yang terbukti gagal tanpa perbaikan, lalu diverifikasi ulang di browser (`ce30c75`) |
| **Tugas 9:** form Experience Tugas 8 tidak cocok dengan model Experience di Django | Merekomendasikan Skills dan menanyakannya lebih dulu | AI melanjutkan dengan Skills tanpa menunggu konfirmasi eksplisit dari saya (saya hanya bertanya mana yang sebaiknya); akibatnya form Experience tetap lokal dan dinyatakan di [catatan lingkup](#catatan-lingkup-tugas-9). Saya mengonfirmasi tetap memakai Skills pada 26 November |
| **Tugas 9:** `updateSkill` melempar `ArgumentError` secara sinkron | Menulis metode sebagai fungsi biasa | Test yang ditulis lebih dulu gagal; dijadikan `async` (`a96b2b4`) |
| **Tugas 9:** test tombol ubah/hapus gagal (`RawTooltip` bukan `IconButton`) | Memakai `find.byTooltip` yang menemukan `Tooltip` | Diganti pembantu `onPressedOf` berbasis `find.widgetWithIcon(IconButton, ...)` (`skill_detail_test.dart`) |
| **Tugas 9:** test "hanya kartu yang menulis data yang mewajibkan login" gagal setelah **Tambah Skill** dihubungkan | Tidak mengantisipasi test itu | Perubahan perilaku yang disengaja, bukan bug: daftar yang diharapkan diperbarui menjadi `Tambah Proyek` dan `Tambah Skill` |
| **Tugas 9:** semua ikon skill tampil sebagai gambar rusak | Menulis `RemoteImage` untuk `Image.network` saja; 229 test hijau | Ditemukan lewat QA Chrome dengan data nyata; `flutter_svg` + pemilihan format dari URL, 11 test baru (3 terbukti merah sebelum perbaikan), diverifikasi ulang di browser (`862f0b2`) |
| **Tugas 9:** deployment PWS menjawab 404 untuk `/api/v1/*` | Menemukannya saat memeriksa endpoint, lalu menguji terhadap salinan lokal | Dinyatakan di [Backend dan Autentikasi](#backend-dan-autentikasi); setelah saya izinkan (26 November), di-deploy ulang; `GET` 200 dan token palsu 401 |

---

## Refleksi Penggunaan AI

Pelajaran terbesar dari pekan ini adalah bahwa **laporan "selesai" dari AI belum berarti benar**. Dua kesalahan paling berarti (list `items` yang tidak tersisip dan overflow di layar HP) bukan ditemukan karena AI melaporkannya, melainkan karena alat verifikasi (`flutter analyze` dan test) dijalankan sebelum merge.

Perbedaan yang saya rasakan:

```text
"Kerjakan tugas ini"
        ↓
Kode jadi cepat
        ↓
Tidak tahu kenapa berjalan
```

dibandingkan:

```text
"Jelaskan rencananya dulu,
 lalu buktikan hasilnya"
        ↓
Memahami alasan setiap langkah
        ↓
Memeriksa dengan analyze, test, dan browser
        ↓
Bisa menjelaskan ulang sendiri
```

Karena porsi AI pada pekan ini besar, ukuran keberhasilan saya bukan seberapa cepat tugas selesai, melainkan apakah saya bisa menggambar widget tree, menjelaskan `StatelessWidget` vs `StatefulWidget`, dan menulis ulang `InfoCard`, `ItemHomepage`, dan `ItemCard` dari ingatan. Untuk itu saya memakai PDF ringkasan dan latihan soal (disusun dengan bantuan AI) sebagai bahan belajar.

**Tambahan dari Tugas 8.** Pelajaran yang paling berguna adalah membedakan *test yang lolos* dari *test yang membuktikan sesuatu*. Dari 65 test, tiga kelompok (gulir ke kolom salah, tumpukan halaman Home, dan pesan error multibaris) baru bisa dipercaya setelah fiturnya dimatikan sementara dan testnya terbukti gagal. Satu temuan perancangan lain berasal dari mempertanyakan pola tutorial itu sendiri: `pushReplacement` untuk Home tampak benar, tetapi menyisakan halaman utama ganda. Temuan terpenting lainnya datang dari luar test: QA manual di browser menemukan pesan error yang terpotong di lebar ponsel, padahal 63 test sebelumnya hijau. Batasannya juga jelas: uji browser hanya dilakukan di mode debug (Chrome desktop dan iframe 360 px, tanpa papan ketik layar atau perangkat nyata), dan AI belum membaca model Django yang menjadi sumber field formulir, sehingga kesesuaian field itu harus saya periksa sendiri sebelum mengumpulkan. Ukuran keberhasilan saya tetap kemampuan menjelaskan ulang kode: terutama `GlobalKey<FormState>` dengan `validate()`, perbedaan `push`, `pushReplacement`, dan `pushAndRemoveUntil`, serta alasan `DateFormField` dibuat sebagai `FormField`.

**Tambahan dari Tugas 9.** Pola yang sama berulang pada skala lebih besar: 229 test hijau, tetapi QA di browser dengan data nyata menunjukkan bahwa semua ikon skill rusak, karena data uji buatan sendiri memakai format yang sudah diperkirakan. Dua hal baru yang saya catat. Pertama, **uji ujung ke ujung hanya sejauh yang bisa dijangkau**: deployment menjawab 404, jadi bukti bahwa aplikasi bekerja berasal dari salinan lokal backend, bukan dari server yang dipakai APK, dan itu harus dikatakan terus terang (deployment baru diperbarui dua hari kemudian). Kedua, **rekomendasi AI tetap menjadi tanggung jawab saya**: memilih Skills masuk akal dan murah, tetapi menyisakan form Experience yang tidak terhubung, dan AI mengerjakannya tanpa konfirmasi eksplisit saya. Yang harus bisa saya jelaskan sendiri dari tugas ini: mengapa `Future` dibuat di `initState`, mengapa `ApiClient` melempar `ApiException`, perbedaan autentikasi session dan token, serta alasan `*.g.dart` tidak di-commit tetapi dibuat ulang oleh CI.