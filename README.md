# MyPortfolio Mobile

Aplikasi mobile portofolio pribadi yang dibangun dengan **Flutter**. Aplikasi ini adalah klien mobile dari website portofolio Django saya ([myportofolio](https://github.com/salfyea/myportofolio)) dan dikembangkan bertahap mengikuti tutorial serta tugas mata kuliah **Pemrograman Berbasis Platform (CSGE602022)**, Fakultas Ilmu Komputer, Universitas Indonesia, Semester Gasal 2026/2027.

[Identitas](#identitas-diri) · [Tentang Proyek](#tentang-proyek) · [Perkembangan](#perkembangan-proyek) · [Menjalankan Proyek](#menjalankan-proyek) · [Refleksi Mingguan](#refleksi-mingguan)

---

## Identitas Diri

| Keterangan | Identitas |
| --- | --- |
| Nama | Salwa Alifia Putri |
| NPM | 2506620280 |
| Kelas | PBP A |
| Program Studi | S1 Sistem Informasi |
| Institusi | Universitas Indonesia |

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