# MyPortfolio Mobile

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

Halaman utama aplikasi menampilkan identitas pemilik portofolio pada tiga kartu informasi (NPM, Nama, Kelas) dan enam tombol menu yang mengikuti bagian-bagian website Django: **Experience**, **Projects**, dan **Skills**, ditambah aksi tambah dan logout. Setiap tombol memiliki ikon dan warna sendiri. Saat ditekan, tombol memunculkan SnackBar `Kamu telah menekan tombol [Nama Tombol]!`.

### Teknologi

| Teknologi | Penggunaan |
| --- | --- |
| **Flutter** (Material 3) | Kerangka kerja UI lintas platform |
| **Dart** | Bahasa pemrograman aplikasi |
| **Git & GitHub** | Riwayat versi, branch per fitur, dan penyimpanan repositori |

### Struktur Kode

```text
lib/
├── main.dart          # Titik masuk: main(), MyApp (MaterialApp + tema)
└── menu.dart          # MyHomePage, InfoCard, ItemHomepage, ItemCard
test/
└── widget_test.dart   # Smoke test halaman menu
docs/
└── ai-log.md          # Log prompting AI (Tutorial 08 dan Tugas 7)
```

| Komponen | Peran |
| --- | --- |
| `MyApp` | Widget akar; menyediakan `MaterialApp` dan tema warna |
| `MyHomePage` | Halaman menu utama (`StatelessWidget`) |
| `InfoCard` | Kartu informasi yang dapat dipakai ulang (judul + isi) |
| `ItemHomepage` | Model data satu tombol: nama, ikon, warna |
| `ItemCard` | Kartu tombol berwarna dengan efek sentuh dan SnackBar |

---

## Perkembangan Proyek

| Tahap | Lingkup Pengembangan |
| --- | --- |
| **Tutorial 8** | Setup Flutter dan Dart, inisialisasi proyek `myportofolio_mobile`, pemisahan `menu.dart` dari `main.dart`, perubahan tema warna, perubahan `MyHomePage` menjadi `StatelessWidget`, pembuatan `InfoCard` dan `ItemCard`, serta SnackBar. |
| **Tugas 7** | Atribut `color` pada `ItemHomepage` agar tiap tombol berwarna unik tanpa percabangan if-else, enam tombol yang mengikuti bagian portofolio Django, halaman yang dapat di-scroll dengan `childAspectRatio` kartu, perbaikan overflow `InfoCard` di layar sempit, docstring, dan widget test baru. |
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

# 3. Jalankan di Chrome (paling ringan) atau di emulator/perangkat
flutter run -d chrome
# flutter run

# 4. Analisis statis dan test
flutter analyze
flutter test
```

Saat aplikasi berjalan, tekan `r` di terminal untuk hot reload dan `R` untuk hot restart.

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

---

## AI Disclosure

Pada Tutorial 08 dan Tugas 7 saya menggunakan AI sebagai **asisten implementasi**. Perlu saya nyatakan terus terang: **sebagian besar penulisan kode, dokumentasi, dan draf jawaban reflektif dikerjakan oleh AI** berdasarkan instruksi, aturan, dan keputusan saya. Karena porsinya besar, bagian ini sengaja saya tulis rinci, termasuk kesalahan AI yang saya temukan selama prosesnya.

### Tools yang Digunakan

| Tools | Peran dalam proses |
| --- | --- |
| **Claude Code** (ekstensi VS Code, model Claude Sonnet 5.5) | Menulis dan mengubah kode Dart langsung pada repositori, menjalankan `flutter analyze` dan `flutter test`, mengelola branch, commit, merge, dan push, menyusun README dan draf jawaban reflektif, menyusun log ini, serta membuat PDF ringkasan belajar (di luar repositori) |

Tool yang tercatat pada pengerjaan proyek mobile ini hanya Claude Code. Log lengkap prompt dan hasilnya ada di [docs/ai-log.md](docs/ai-log.md).

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
| Git (branch, merge `--no-ff`, push) | Menjalankan perintah | Menetapkan alur kerja dan larangan trailer `Co-Authored-By` |
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

---

## Belajar Menggunakan AI

Selain membantu implementasi, saya memakai AI sebagai **alat belajar**, bukan hanya untuk menyerahkan pekerjaan. Hal yang benar-benar saya lakukan:

- **Meminta rencana dijelaskan sebelum dikerjakan.** Pada Tugas 7 saya meminta penjelasan rencana lebih dulu dan menulis "sekalian ajarin aku", supaya saya paham alasan di balik tiap langkah, bukan hanya hasil akhirnya.
- **Menanyakan hal yang belum saya mengerti.** Contohnya menanyakan maksud istilah tugas ("IA7 apa") dan maksud pilihan yang diajukan AI (6 tombol, `childAspectRatio`, test baru) sebelum memutuskan.
- **Meminta bahan belajar dari hasil kerja.** Saya meminta PDF ringkasan Tutorial 08 dan Tugas 7 untuk persiapan quiz dan UTS: konsep widget tree, `StatelessWidget` vs `StatefulWidget`, `BuildContext`, hot reload vs hot restart, dan alasan tiap baris kode ditulis. PDF ini tidak termasuk repositori.
- **Meminta soal latihan coding** (membaca kode, mengisi bagian kosong, mencari bug) untuk menguji apakah saya paham kode, sintaks, dan alurnya sendiri.
- **Mempertanyakan klaim AI,** misalnya soal test bawaan yang gagal dan status merge ke `main`, lalu memeriksa hasilnya sendiri (menjalankan aplikasi di Chrome dan membaca `git log`).

Jawaban reflektif pada [Tugas 7](#tugas-7) saya jadikan bahan belajar: saya membacanya, membandingkannya dengan kode yang berjalan, dan memakainya untuk memahami konsepnya.

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

Claude Code secara bawaan mengarahkan penambahan trailer `Co-Authored-By` pada commit. Saya melarangnya dan memeriksa bahwa 28 commit di repositori ini memuat 0 trailer tersebut. Karena riwayat commit sengaja dibiarkan bersih, **pengungkapan penggunaan AI saya letakkan di README ini**.

### 8. AI tidak menggantikan pemahaman saya

Yang akan diuji pada quiz dan UTS adalah pemahaman saya, bukan AI. Karena itu jawaban reflektif dan PDF belajar hanya berguna jika saya benar-benar memahami dan mampu menjelaskan ulang isinya sendiri.

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
| Trailer `Co-Authored-By` pada commit | Bawaan Claude Code mengarahkan penambahannya | Saya melarangnya, lalu memeriksa 28 commit di lokal dan `origin/main`: 0 trailer, seluruh penulis `salfyea` |
| Tampilan aplikasi belum teruji di browser nyata | Hanya membangun versi web, belum melihatnya | Saya menjalankan aplikasi di Chrome sendiri dan memeriksa tampilannya lewat tangkapan layar |

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