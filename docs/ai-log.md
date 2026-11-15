# Log Prompting AI: Tutorial 08 dan Tugas 7

Dokumen ini adalah log penggunaan AI pada proyek `myportofolio_mobile`. Ringkasan, analisis, dan evaluasi kritisnya ada di bagian **AI Disclosure** pada [README](../README.md).

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

## Pola yang saya pakai

1. **Aturan di depan:** larangan dan batasan (tanpa atribusi AI di commit, branch per fitur, berhenti jika ambigu) saya tulis sebelum pekerjaan dimulai.
2. **Rencana sebelum eksekusi** untuk tugas yang rubriknya jelas.
3. **Mempertanyakan klaim**, bukan menerima begitu saja ("ini beneran gpp kah", "udah di merge belum ya").
4. **Meminta penjelasan arti** istilah yang tidak saya pahami sebelum menyetujui pilihan.
5. **Verifikasi di luar AI:** menjalankan aplikasi sendiri di Chrome dan membandingkannya dengan tutorial.
