/// Model data untuk bagian **Skills** yang disinkronkan dengan backend Django.
///
/// Bentuknya mengikuti `SkillSerializer` di Django (bukan sebaliknya), jadi
/// nama field di sini harus sama dengan kunci JSON API setelah diubah dari
/// snake_case ke camelCase. Berkas `skill.g.dart` dihasilkan oleh
/// `dart run build_runner build --delete-conflicting-outputs`.
library;

import 'package:json_annotation/json_annotation.dart';

part 'skill.g.dart';

/// Satu skill atau alat pada portofolio, dibaca dari dan dikirim ke API DRF.
///
/// `fieldRename: FieldRename.snake` memetakan `iconUrl` ke kunci JSON
/// `icon_url` secara otomatis, sehingga tidak ada nama kunci yang diketik
/// manual. Salah ketik seperti `'iconURL'` baru ketahuan saat runtime bila
/// memakai `Map<String, dynamic>` mentah, sedangkan di sini kuncinya selalu
/// diturunkan dari nama properti yang diperiksa kompilator.
@JsonSerializable(fieldRename: FieldRename.snake)
class Skill {
  const Skill({
    required this.name,
    required this.iconUrl,
    this.category = '',
    this.id,
    this.starCount = 0,
    this.isStarred = false,
    this.starredByNames = '',
  });

  /// Membuat [Skill] dari objek JSON milik DRF.
  factory Skill.fromJson(Map<String, dynamic> json) => _$SkillFromJson(json);

  /// UUID yang ditetapkan server. Tidak ikut dikirim saat membuat atau
  /// mengubah skill, karena server tidak menerimanya dari klien.
  @JsonKey(includeToJson: false)
  final String? id;

  /// Nama skill (maksimal 100 karakter di Django).
  final String name;

  /// Alamat gambar ikon. Wajib dan harus berupa URL yang valid.
  final String iconUrl;

  /// Kelompok skill, misalnya `"Framework"`. Opsional (maksimal 50 karakter
  /// di Django); kosong berarti tidak dikelompokkan.
  @JsonKey(defaultValue: '')
  final String category;

  /// Jumlah bintang. Dihitung server, hanya dibaca klien.
  @JsonKey(includeToJson: false, defaultValue: 0)
  final int starCount;

  /// Apakah pengguna yang sedang login memberi bintang. Hanya dibaca klien.
  @JsonKey(includeToJson: false, defaultValue: false)
  final bool isStarred;

  /// Nama pengguna pemberi bintang, dipisah koma. Hanya dibaca klien.
  @JsonKey(includeToJson: false, defaultValue: '')
  final String starredByNames;

  /// Mengubah skill menjadi body permintaan POST atau PATCH, hanya berisi
  /// field yang boleh ditulis klien.
  Map<String, dynamic> toJson() => _$SkillToJson(this);
}
