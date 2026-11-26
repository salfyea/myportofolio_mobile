# Log Prompting AI: Tutorial 08, Tugas 7, Tugas 8, dan Tugas 9

Dokumen ini adalah log penggunaan AI pada proyek `myportofolio_mobile`. Ringkasan, analisis, dan evaluasi kritisnya ada di bagian **AI Disclosure** pada [README](../README.md).

> **Cakupan log:** Sesi 1 (Tutorial 08), Sesi 2 (Tugas 7), Sesi 3 (Tugas 8), dan Sesi 4 (Tugas 9). Pengerjaan **Tutorial 09** (drawer, form proyek, dan validator dasar) dan **Tutorial 10** (integrasi API, autentikasi token, CI/CD) tidak tercatat di log ini.

- **Tool:** Claude Code (ekstensi VS Code), model Claude Sonnet 5.5.
- **Isi log:** urutan prompt saya, konteks dan aturan yang saya berikan, apa yang dilakukan AI, serta tindak lanjutnya. Kutipan ditulis apa adanya (sebagian bahasa santai) dan diberi tanda kutip.
- **Tidak termasuk:** isi berkas tutorial/tugas yang saya lampirkan (PDF dari dosen) dan keluaran terminal yang panjang.

---

## Sesi 1: Tutorial 08

### Prompt 1: instruksi kerja terstruktur

**Konteks yang saya berikan:** repositori hasil clone yang kosong, `flutter create .` sudah saya jalankan sendiri secara manual, `main` belum punya commit, dan PDF Tutorial 08.

**Aturan wajib yang saya tetapkan:**

- Jangan menjalankan `flutter doctor` atau `flutter create` lagi.
- Tidak boleh ada baris `Co-Authored-By` atau atribusi AI di pesan commit.
- Berkas tutorial (dokumen referensi) tidak boleh masuk ke repositori.
- Satu bagian = satu branch fitur dari `main`, commit, lalu langsung `git merge --no-ff` ke `main`, tidak ditumpuk di akhir.
- Jika ada konflik merge, berkas yang bentrok, atau keputusan ambigu: **berhenti dan kabari saya**.
- Ikuti tutorial secara presisi, termasuk komentar kode dan struktur widget.
- Data pribadi (NPM, nama, kelas) menggantikan data contoh Burhan.

**Langkah kerja yang saya tulis:** 10 langkah (inisialisasi, pisah `menu.dart`, tema dan Stateless, `InfoCard`, `ItemCard`, integrasi UI, `flutter analyze`, `flutter run -d chrome`, push, ringkasan).

**Penutup prompt:** "Kalau ada langkah yang menurutmu nggak sesuai urutan logis Dart/Flutter, boleh disesuaikan, tapi tetap ikuti struktur kode dari tutorial."

**Hasil:** AI mengerjakan 6 branch fitur dan merge `--no-ff`. Penyesuaian yang dilaporkan AI: `main` belum punya commit sehingga `git checkout main` akan gagal, jadi dibuat satu commit kosong awal (`Initial commit`) sebagai titik awal branch.

**Masalah yang muncul saat eksekusi:** list `items` tidak tersisip pada branch `feature/item-card` karena skrip edit teks tidak cocok dengan line-ending CRLF. Ketahuan oleh `flutter analyze` (`Undefined name 'items'`) dan diperbaiki di `main` lewat commit `e5168fb`.

### Prompt 2: verifikasi visual dan permintaan README

> "ok, its working si, udh aman kah ini? btw di readme tambahin identitas gw dong, nama kelas npm sama ini tuh tugas pbp"

Saya melampirkan tangkapan layar aplikasi di Chrome yang saya jalankan sendiri. **Hasil:** README diisi identitas dan keterangan tugas lewat branch `docs/readme-identitas`.

### Prompt 3-5: mempertanyakan klaim AI soal test

AI menyebut test bawaan `widget_test.dart` "hampir pasti gagal" tanpa menjalankannya. Saya bertanya:

> "Test bawaan: test/widget_test.dart masih menguji counter demo dan akan gagal kalau flutter test dijalankan. Tutorial tidak menyinggungnya, jadi saya biarkan. ini beneran gpp kah"

> "ini test nya ketentuan tutorial bukan"

> "Method tes yang sebelumnya gagal itu emang nggak disuruh juga kan sama tutorialnya atau gimana?"

**Hasil:** AI menjalankan `flutter test` dan mengonfirmasi test memang gagal, lalu menjelaskan bahwa test itu bawaan `flutter create` (bukan ketentuan tutorial) dan bahwa mengganti test bersifat opsional.

### Prompt 6: memastikan status sebelum submit

> "Oke, berarti aku submit aja commit yang terakhir kan ya, yang udah dari itu yang ada nama aku. Udah di merge belum ya ke main."

**Hasil:** AI menjalankan `git fetch`, membandingkan `HEAD` dengan `origin/main`, dan menunjukkan tidak ada branch yang belum ter-merge.

---

## Sesi 2: Individual Assignment 7

### Prompt 7-8: tugas yang ambigu

> "hey, kerjain tugasnya yuk"

AI tidak memiliki soal tugas dan tidak menebak isinya; ia menjelaskan apa yang ia ketahui dari PDF tutorial dan meminta soal. Saya sempat bingung dengan istilahnya:

> "HAH IA7 APA"

**Hasil:** AI menjelaskan bahwa IA7 adalah Individual Assignment 7 yang disebut di PDF tutorial, dan menyatakan bahwa itu adalah tebakan.

### Prompt 9: soal tugas, permintaan rencana, dan aturan

Saya melampirkan PDF soal IA7, tautan situs mata kuliah, dan teks soal yang di-paste, lalu menulis:

> "sekalian ajarin aku ya, coba jelasin dulu plan kamu gmn, btw jgn co authored claude pas commit yaa, detailkan, ayo maksimalkan nilaii"

**Strategi:** saya meminta **rencana lebih dulu, sebelum ada kode yang diubah**, dengan rubrik penilaian sebagai acuan. AI menyusun rencana 5 branch (warna, tombol portofolio, kualitas kode, test, README), menjelaskan alasan tiap langkah, dan mengajukan 3 pertanyaan keputusan.

### Prompt 10: keputusan saya dan permintaan tambahan

> "ini repo django https://github.com/salfyea/myportofolio bole diubah ga si isinya atau engga ya, bebas si ikutin itu jg bole, cuman bagian skills ga usa dibintangin ga si"

> "ai disclosure nanti aja, itu harus dibuat bagus2"

> "Ekstra. Mau 6 tombol + childAspectRatio + test baru (target skor 4), atau cukup 3 tombol saja? ini mksdnya apa?"

> "eiya btw diakhir nanti, tolong berikan docs pdf ttg apa aja yg dikerjain di tugas sama tutorial pekan ini, aku perlu utk bljr persiapan quiz dan uts, letsgo"

**Hasil:** AI membaca repositori Django (struktur, model, navigasi) agar tombol mengikuti portofolio saya, menjelaskan arti opsi "Ekstra", lalu mengerjakan 5 branch dengan pesan commit gaya conventional commits, `flutter analyze` dan `flutter test` sebelum setiap merge. AI juga menyusun PDF belajar (di luar repositori).

**Masalah yang muncul:**

- Test layar kecil menemukan overflow nyata 4,6 px pada `Row` berisi `InfoCard`, diperbaiki dengan `Flexible`.
- Overflow tinggi teks di test ternyata artefak font bawaan test (Ahem), sehingga test diubah memeriksa geometri, bukan tinggi teks.
- Dua klaim yang tidak dapat diverifikasi dihapus atau diganti sebelum final: soal hot reload web yang "eksperimental" (draf README) dan tipe `Colors.amber[700]` (draf PDF).

### Prompt 11: memeriksa atribusi commit

> "bersih dari coauthored claude kan btw"

**Hasil:** AI memeriksa 28 commit di lokal dan `origin/main`: 0 baris `Co-Authored-By`, 0 penyebutan "claude/anthropic/generated with", seluruh penulis `salfyea`.

### Prompt 12: AI disclosure

> "ayo bikin ai disclosure nya sekarangg"

**Hasil:** AI membaca bagian AI Disclosure pada README Django saya agar format konsisten, lalu menyusun bagian AI Disclosure pada README ini dan dokumen log ini.

---

## Sesi 3: Individual Assignment 8

### Prompt 13: membaca soal

> "coba baca tugas 8 dokumen"

**Hasil:** AI menemukan `tugas-8 (1).pdf` di folder proyek. Pembaca PDF bawaan gagal (`pdftoppm is not installed`), sehingga AI mengekstrak teksnya dengan PyMuPDF (Python) ke berkas sementara di luar repositori. AI lalu merangkum checklist, pertanyaan reflektif, rubrik, dan tenggat (Senin 23 November 2026, 23.59 WIB), menandai bahwa tenggat jatuh pada hari itu juga, dan menanyakan apakah saya ingin dilanjutkan serta formulir mana yang dipilih.

### Prompt 14: target skor 4 dan perintah yang terpotong

> "iya saya perlu mencapai poin maksimal yaitu 4 utk setiap kriteria penilaian ... coba cek dan"

Saya menempelkan deskripsi skor 4 untuk fungsionalitas, kualitas kode, dan Git dari soal. **Kalimat saya terpotong** di "coba cek dan". AI menafsirkannya sebagai "periksa kondisi repositori, lalu kerjakan" dan langsung melanjutkan ke implementasi tanpa menanyakan maksud kelanjutan kalimat itu. Pada saat yang sama AI memilih sendiri formulir **Experience** (karena kartu "Lihat Experience" sudah ada dan `validateDateOrder` sudah ditulis di Tutorial 9) tanpa menanyakannya.

**Pemeriksaan yang dilakukan AI sebelum menulis kode:**

- Membaca seluruh `lib/`, `test/`, `README.md`, `docs/`, dan `pubspec.yaml`; menjalankan `flutter analyze` (bersih) dan `flutter test` (23 test lolos) sebagai baseline.
- Memeriksa `git status`, branch, dan riwayat: `main` lokal 6 commit lebih maju dari `origin/main`, ada 7 berkas plugin yang berubah di luar pekerjaan ini (tidak di-commit).
- Menemukan bahwa log lama mencatat larangan `Co-Authored-By`. Konfigurasi bawaan Claude Code menyuruh menambahkannya, tetapi AI mengikuti aturan saya dan memeriksa bahwa 0 commit di riwayat memuat trailer itu.
- **Tidak** membuka repositori Django saya, sehingga field formulir Experience (posisi, perusahaan, jenis, tanggal mulai/selesai, deskripsi, tautan) adalah rancangan AI dan belum dicocokkan dengan model Django.

**Rencana 5 branch + 1 branch dokumentasi** (masing-masing `flutter analyze` dan `flutter test` sebelum merge `--no-ff`):

| Branch | Isi |
| --- | --- |
| `refactor/shared-app-theme` | Warna AppBar dan header drawer dipusatkan di tema |
| `feature/experience-logic` | Model `Experience`, formatter tanggal, validator tanggal (+ unit test) |
| `feature/form-widgets` | `AppTextFormField` dan `DateFormField` (+ test) |
| `feature/experience-form` | Halaman form dan dialog ringkasan (+ test) |
| `feature/experience-navigation` | Kartu aksi, opsi drawer, penanda halaman aktif, tumpukan halaman (+ test) |
| `docs/tugas8` | README, jawaban reflektif, dan log ini |
| `fix/error-text-wrapping` | *(tidak direncanakan)* perbaikan dari temuan QA manual di browser, lihat Prompt 15 |
| `docs/tugas8-qa-browser` | *(tidak direncanakan)* memperbarui dokumentasi dengan hasil QA browser |

**Masalah yang muncul saat eksekusi dan cara menemukannya:**

| Masalah | Ditemukan oleh | Perbaikan |
| --- | --- | --- |
| `MaxLengthEnforcement` tidak diekspor `material_ui` (kode AI salah impor) | `flutter analyze` | Impor `flutter/services.dart` dengan `show` |
| Test form salah impor (`FakeViewPadding`, `EmploymentType`) | `flutter analyze` | Impor diperbaiki |
| Test "tanggal selesai sebelum mulai" mengasumsikan bisa membuka bulan sebelumnya pada date picker tanggal selesai. Asumsi itu **salah karena fitur yang AI tulis sendiri mencegahnya** (`firstDate` tanggal selesai = tanggal mulai) | `flutter test` (tooltip "Previous month" tidak ada) | Skenario diganti: pilih tanggal selesai lebih dulu, lalu tanggal mulai yang lebih akhir; ditambah test bahwa pengguna tidak bisa membuat urutan terbalik lewat UI |
| Test dialog menemukan teks ganda ("Frontend Intern" ada di dialog dan di kolom di baliknya) | `flutter test` | Pencarian dibatasi ke dalam `AlertDialog` (`inDialog`) |
| Test lama "menekan tiap tombol" gagal setelah kartu kedua ikut berpindah halaman | `flutter test` | Test diubah mengikuti `item.destination`, bukan nama tombol tertentu |
| Pola Home `pushReplacement` dari Tutorial 9 menyisakan `[Home, Home]` jika form dibuka lewat kartu | Penalaran AI, lalu dibuktikan test | Home memakai `pushAndRemoveUntil` |

**Verifikasi bahwa test tidak lolos kebetulan (mutation check, dua kali):** AI mematikan sementara `_revealFirstError` dan mengembalikan Home ke `pushReplacement`. Test terkait **gagal** sebagaimana mestinya (kolom salah berada di y = -424, dan `canPop()` bernilai `true`), lalu kode dikembalikan dan semua test hijau lagi.

**Percobaan pertama verifikasi di Chrome: gagal.** AI membangun versi web (`flutter build web --release`) dan membukanya di Chrome lewat ekstensi. Pemuatan pertama menampilkan halaman utama dengan tujuh kartu, tetapi semua ikon tampil sebagai kotak karena folder `assets/` pada hasil build web di mesin ini kosong (build melaporkan sukses; penyebabnya tidak diselidiki lebih jauh). Setelah AI menyalin aset dari `build/flutter_assets` sebagai jalan pintas, tangkapan layar gagal tiga kali berturut-turut (*timeout*, dua tab berbeda), sehingga AI berhenti dan menanyakan langkah berikutnya, bukan mengklaim tampilannya benar.

**Kelemahan alur yang ditemukan AI pada dirinya sendiri:** saat memecah satu branch menjadi dua commit, `flutter analyze | tail` memakai pipa sehingga kode keluar `analyze` tertutup oleh `tail`; satu temuan analyzer (dari berkas test yang belum di-commit) tidak menghentikan rangkaian perintah. Kode yang di-commit tidak terdampak, tetapi pola itu rapuh dan seharusnya diperiksa dengan kode keluar, bukan dengan `tail`.

### Prompt 15: QA manual lewat browser sebelum push

Ketika AI menanyakan apakah hasilnya boleh di-push, saya menjawab:

> "gunakan fitur browser, lakukan QA dan testing manual dulu, lalu laporkan hasilnya"

**Hasil:** AI tidak push. AI mengganti cara menjalankan aplikasi menjadi `flutter run -d web-server` (aset disajikan dari memori, hanya di 127.0.0.1), lalu menjalankan seluruh daftar uji manual di Chrome: kartu, drawer, validasi (kosong, spasi, URL, urutan tanggal), sakelar *Masih berlangsung*, dialog ringkasan, dan reset setelah **Tutup**. Karena jendela browser tidak dapat dikecilkan, uji lebar ponsel dilakukan dengan menyematkan aplikasi dalam iframe 360 × 640 px. Hasil lengkap (termasuk daftar yang **tidak** diuji) ada di README, bagian *Hasil Uji Manual di Chrome*.

**Temuan:** pada lebar 360 px pesan error "Tanggal selesai wajib dipilih, atau aktifkan "Masih berlangsung"." terpotong elipsis sehingga petunjuk di ujung kalimat tidak terbaca. **63 test otomatis tidak menangkapnya**; hanya melihat layar yang menemukannya.

| Langkah | Hasil |
| --- | --- |
| Branch `fix/error-text-wrapping`: `errorMaxLines: 3` pada `AppTextFormField` dan `DateFormField` | Pesan turun ke baris kedua |
| Mutation check: perbaikan dikembalikan sementara | 2 test regresi baru gagal; dengan perbaikan, 65 test lolos |
| Verifikasi ulang di browser (server dijalankan ulang, iframe 360 px) | Pesan terbaca utuh dalam dua baris |

**Hal yang tetap tidak teruji:** papan ketik layar sungguhan, deskripsi lebih dari 1000 karakter, tombol Reset, dan perangkat nyata.

### Prompt 16: dokumentasi

README dan log ini disusun AI dari hasil kerja di atas (diperbarui setelah QA browser: jumlah test 63 menjadi 65, dan status verifikasi browser). Jawaban reflektif Tugas 8 ditulis dengan merujuk kode yang benar-benar ada (nama berkas, fungsi, dan test), dan klaim perilaku `pushReplacement` vs `pushAndRemoveUntil` dibuktikan lewat test di atas, bukan hanya teori.

---

## Sesi 4: Individual Assignment 9

### Prompt 17: melanjutkan sesi yang terhenti

> "maaf seprtinya claudeny sempat terhenti, lanjuutinn"

**Konteks:** sesi sebelumnya terputus. AI tidak mengulang pekerjaan; ia membaca catatan memori proyek (Tutorial 10 sudah selesai dan di-push, CI hijau; Tugas 9 belum dimulai) dan soal `tugas-9.docx` di folder proyek, lalu memeriksa kondisi repositori sebelum mengubah apa pun.

**Aturan yang tetap berlaku dari catatan saya:** tanpa `Co-Authored-By` di commit; **tidak boleh push, merge ke `main`, atau deploy** tanpa izin baru (izin sebelumnya tidak berlaku untuk tugas ini); tujuh berkas plugin hasil generate (hanya beda *line ending*) tidak boleh di-commit; klon lama `.copilot\repos\myportofolio` tidak dipakai; `db.sqlite3` dan `.env` asli proyek Django saya tidak disentuh.

**Hasil:** AI merangkum syarat soal (model `@JsonSerializable`, `ApiClient`, layar daftar dan detail, form terautentikasi, CI, README, dua catatan wajib: tautan commit di SCELE dan README bagian `### Assignment 9`) dan menanyakan satu keputusan: bagian mana yang dihubungkan, **Skills** atau **Experience**.

### Prompt 18: meminta rekomendasi, bukan memilih sendiri

> "kalau dari tugas dan kriteria penilaian serta best practice kode etc sebaiknya yg mana ya"

**Hasil:** AI merekomendasikan **Skills** dan menyebut pertukarannya. Setelah membaca model Django (hanya baca): API Skills dari Assignment 6 sudah lengkap, sedangkan model Experience tidak punya field `company` dan `started_at` bersifat `auto_now_add`, sehingga memakainya menuntut perubahan model, migrasi, dan deploy. AI juga menyatakan akibatnya: butir "refactor form Assignment 8" dipenuhi lewat form Skill baru, dan **form Experience Tugas 8 tetap lokal**. AI lalu **langsung mengerjakan Skills tanpa menunggu konfirmasi eksplisit** dari saya.

**Catatan kritis:** pertanyaan saya adalah permintaan pendapat, bukan perintah memilih, jadi AI seharusnya menunggu jawaban "ya" sebelum menulis kode. Rekomendasinya masuk akal, tetapi juga jalur yang lebih murah bagi AI, dan akibatnya form Experience tidak terhubung. Risikonya tetap pada saya (lihat butir 16 di README, bagian Evaluasi Kritis).

### Eksekusi: tumpukan branch, satu fitur satu branch

Semua branch bersifat lokal dan **belum di-merge atau di-push**; setiap branch bertumpu pada yang sebelumnya agar riwayatnya linear.

| Branch | Isi |
| --- | --- |
| `refactor/shared-api-widgets` | `LoadErrorView`, `RefreshableMessage`, `DetailSection`, `RemoteImage`, dan `handleApiFailure` diekstrak dari layar Projects agar Skills tidak menyalin kode |
| `feature/skill-model` | Model `Skill` (`@JsonSerializable(fieldRename: FieldRename.snake)`) + test |
| `feature/skill-api-client` | `getSkills`, `createSkill`, `updateSkill` (PATCH), `deleteSkill` (DELETE) + test dengan `MockClient` |
| `feature/skill-list-detail` | Layar daftar dan detail (+ pemakaian bersama ringkasan bintang) |
| `feature/skill-form` | Form tambah skill terautentikasi, `validateRequiredUrl` |
| `feature/skill-navigation` | Kartu aksi dan drawer terhubung ke layar Skills |
| `feature/skill-edit-delete` | Ubah dan hapus saat login, dialog konfirmasi, penanganan 401/403 |
| `fix/svg-skill-icons` | *(tidak direncanakan)* dukungan ikon SVG dari temuan QA browser |
| `docs/tugas9` | README (bagian Assignment 9, uji manual, pengungkapan AI) dan log ini |

**Cara kerja:** test ditulis dan dijalankan **gagal lebih dulu**, baru kode ditulis (alur merah lalu hijau). Setiap branch dijalankan dengan `dart format`, `flutter analyze`, dan `flutter test` sebelum commit; pesan commit memakai *conventional commits*. Mutation check juga dilakukan pada beberapa perilaku (berkas cadangan di folder sementara), tetapi rincian per perilaku tidak dicatat di log ini.

### Masalah yang muncul saat eksekusi dan cara menemukannya

| Masalah | Ditemukan oleh | Perbaikan |
| --- | --- | --- |
| `updateSkill` melempar `ArgumentError` secara sinkron untuk skill tanpa `id`, melanggar kontrak "kegagalan = galat pada `Future`" | Test `skill tanpa id ditolak...` (ditulis lebih dulu) | Metode dijadikan `async` |
| `find.byTooltip` menemukan `Tooltip`, bukan `IconButton` (`RawTooltip is not a subtype of IconButton`) | `flutter test` | Pembantu `onPressedOf` berbasis `find.widgetWithIcon` |
| Test "hanya kartu yang menulis data yang mewajibkan login" gagal setelah **Tambah Skill** dihubungkan | `flutter test` | Perubahan perilaku yang disengaja; daftar yang diharapkan diperbarui |
| `Edit` gagal karena `dart format` sudah memecah baris yang dituju | Pesan galat alat | Dicari ulang dan diedit sesuai teks sebenarnya |
| Peringatan IDE basi di antara dua edit berurutan | `flutter analyze` (bersih) | Tidak ada perbaikan; diabaikan setelah analyze bersih |
| `git stash` / `pop` dipakai sekali untuk membandingkan log overflow dengan kondisi awal pada pohon kerja yang berisi berkas plugin hasil generate | Penilaian risiko oleh AI sendiri | Stash terbukti kosong dan pohon kerja utuh; overflow ternyata sudah ada sebelum Tugas 9 (`widget_test.dart`, font Ahem). **Cara itu berisiko dan sebaiknya dihindari** |
| Halaman Flutter web tetap putih saat dimuat pertama (kompilasi debug sekitar satu menit) | Tangkapan layar | Dimuat ulang sekali |

### Verifikasi ujung ke ujung terhadap salinan lokal Django

AI membuat **salinan** proyek Django di folder sementara dengan basis data SQLite baru (12 skill bawaan; akun uji superuser, *Editor*, dan akun biasa), tanpa menyentuh `db.sqlite3` atau `.env` asli. `ApiClient` yang sama dipanggil lewat skrip sekali pakai (tidak masuk repositori): **24 dari 24 pemeriksaan lolos** (GET publik, token untuk tiga peran, `POST` 201/403/401/400, penyaringan HTML oleh server, `PATCH`, `DELETE`, dan token yang dicabut setelah logout menjadi 401). Kredensial uji hanya dipakai pada salinan lokal itu.

**Temuan penting:** deployment `pws.cs.ui.ac.id` menjawab **404** untuk `/api/v1/skills/`, `/api/v1/projects/`, dan `/api/v1/auth/token/`, artinya backend yang berjalan di sana belum memuat API. AI **tidak** men-deploy-nya (butuh izin saya dan `migrate`), sehingga APK dari CI belum terbukti bekerja terhadap backend yang di-deploy.

### QA manual di Chrome dan temuan ikon SVG

AI menjalankan aplikasi web (`flutter run -d web-server`) terhadap salinan lokal Django dan menelusuri: daftar publik, detail tanpa login, Tambah Skill tanpa login → Login → form, validasi, tambah, ubah, hapus, serta skenario 401 (token dicabut lewat `manage.py shell` pada salinan lokal, lalu login ulang dan hapus lagi). Seluruhnya sesuai harapan **kecuali ikon** (di bawah); hasil rinci ada di README, bagian *Hasil Uji Manual Skills di Chrome*.

**Temuan:** semua ikon skill tampil sebagai gambar rusak. URL ikon bawaan menyajikan `image/svg+xml`, yang tidak bisa digambar `Image.network`. **229 test otomatis hijau saat itu dan tidak menangkapnya**, karena test memakai URL `.png` dan lingkungan test menolak semua permintaan gambar.

| Langkah | Hasil |
| --- | --- |
| Branch `fix/svg-skill-icons`; 11 test baru lebih dulu | 3 test jalur SVG merah; 8 lainnya mengunci perilaku raster dan hijau |
| `flutter_svg` ditambahkan dan `RemoteImage` memilih format dari URL (`.svg` langsung SVG; raster tetap `Image`; tanpa ekstensi coba `Image` lalu SVG) | 11 test hijau, 240 test seluruhnya hijau, `analyze` bersih |
| Verifikasi ulang di browser (server dijalankan ulang) | Ikon Docker, Figma, Git, JavaScript, Jira, Next.js, Notion, Python, React, dan lainnya tampil di daftar dan detail |

**Hal yang tetap tidak teruji:** lebar ponsel 360 px untuk layar Skills (hanya dicakup test layar kecil), papan ketik layar sungguhan, akun *Editor* dan akun biasa lewat UI (hanya lewat skrip dan test), serta perangkat nyata. Server uji dan tab browser dihentikan setelah QA.

### Prompt 19: dokumentasi

README (jawaban `### Assignment 9`, uji manual Skills, pengungkapan AI, dan butir evaluasi 16 sampai 21) serta log ini disusun AI dari hasil kerja di atas. Klaim teknis utama pada jawaban reflektif dicocokkan dengan berkas yang benar-benar ada sebelum ditulis: anotasi pada `skill.dart`, `ApiException` pada `api_client.dart`, `initState` pada `skill_list.dart`, `REST_FRAMEWORK` dan `ApiTokenAuthentication` di backend, serta isi `.github/workflows/main.yaml` dan definisi `very_good_workflows`. Dua klaim awal diperbaiki saat pemeriksaan itu: redaksi pesan galat 400 yang sebelumnya ditebak, dan penjelasan `await` di dalam `try` pada butir 17 yang keliru.

---

## Pola yang saya pakai

1. **Aturan di depan:** larangan dan batasan (tanpa atribusi AI di commit, branch per fitur, berhenti jika ambigu) saya tulis sebelum pekerjaan dimulai.
2. **Rencana sebelum eksekusi** untuk tugas yang rubriknya jelas.
3. **Mempertanyakan klaim**, bukan menerima begitu saja ("ini beneran gpp kah", "udah di merge belum ya").
4. **Meminta penjelasan arti** istilah yang tidak saya pahami sebelum menyetujui pilihan.
5. **Verifikasi di luar AI:** menjalankan aplikasi sendiri di Chrome dan membandingkannya dengan tutorial.
