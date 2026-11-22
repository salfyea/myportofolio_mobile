# Log Prompting AI: Tutorial 08, Tugas 7, dan Tugas 8

Dokumen ini adalah log penggunaan AI pada proyek `myportofolio_mobile`. Ringkasan, analisis, dan evaluasi kritisnya ada di bagian **AI Disclosure** pada [README](../README.md).

> **Cakupan log:** Sesi 1 (Tutorial 08), Sesi 2 (Tugas 7), dan Sesi 3 (Tugas 8). Pengerjaan **Tutorial 09** (drawer, form proyek, dan validator dasar) tidak tercatat di log ini.

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

**Verifikasi visual di Chrome: tidak tuntas.** AI membangun versi web (`flutter build web --release`) dan membukanya di Chrome lewat ekstensi. Pemuatan pertama menampilkan halaman utama dengan tujuh kartu, termasuk kartu teal **Tambah Experience**, tetapi semua ikon tampil sebagai kotak karena folder `assets/` pada hasil build web di mesin ini kosong (build melaporkan sukses; penyebabnya tidak diselidiki lebih jauh). Setelah AI menyalin aset dari `build/flutter_assets` sebagai jalan pintas, tangkapan layar gagal tiga kali berturut-turut (*timeout*, dua tab berbeda), sehingga AI berhenti dan tidak melanjutkan. **Alur formulir, dialog, dan drawer belum pernah AI lihat di browser sungguhan**; keyakinan atas perilakunya bersumber dari test otomatis, dan pemeriksaan di Chrome (`flutter run -d chrome`) perlu saya lakukan sendiri.

**Kelemahan alur yang ditemukan AI pada dirinya sendiri:** saat memecah satu branch menjadi dua commit, `flutter analyze | tail` memakai pipa sehingga kode keluar `analyze` tertutup oleh `tail`; satu temuan analyzer (dari berkas test yang belum di-commit) tidak menghentikan rangkaian perintah. Kode yang di-commit tidak terdampak, tetapi pola itu rapuh dan seharusnya diperiksa dengan kode keluar, bukan dengan `tail`.

### Prompt 15: dokumentasi

README dan log ini disusun AI dari hasil kerja di atas. Jawaban reflektif Tugas 8 ditulis dengan merujuk kode yang benar-benar ada (nama berkas, fungsi, dan test), dan klaim perilaku `pushReplacement` vs `pushAndRemoveUntil` dibuktikan lewat test di atas, bukan hanya teori.

---

## Pola yang saya pakai

1. **Aturan di depan:** larangan dan batasan (tanpa atribusi AI di commit, branch per fitur, berhenti jika ambigu) saya tulis sebelum pekerjaan dimulai.
2. **Rencana sebelum eksekusi** untuk tugas yang rubriknya jelas.
3. **Mempertanyakan klaim**, bukan menerima begitu saja ("ini beneran gpp kah", "udah di merge belum ya").
4. **Meminta penjelasan arti** istilah yang tidak saya pahami sebelum menyetujui pilihan.
5. **Verifikasi di luar AI:** menjalankan aplikasi sendiri di Chrome dan membandingkannya dengan tutorial.
