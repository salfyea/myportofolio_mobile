/// Model data untuk bagian **Project** yang disinkronkan dengan backend Django.
///
/// Bentuknya mengikuti `ProjectSerializer` di Django (bukan sebaliknya), jadi
/// nama field di sini harus sama dengan kunci JSON API setelah diubah dari
/// snake_case ke camelCase. Berkas `project.g.dart` dihasilkan oleh
/// `dart run build_runner build --delete-conflicting-outputs`.
library;

import 'package:json_annotation/json_annotation.dart';

part 'project.g.dart';

/// Satu proyek portofolio yang dibaca dari dan dikirim ke API DRF.
///
/// `fieldRename: FieldRename.snake` memetakan `projectImageUrl` ke kunci JSON
/// `project_image_url` secara otomatis, sehingga tidak ada nama kunci yang
/// diketik manual (sumber salah ketik yang baru ketahuan saat runtime).
@JsonSerializable(fieldRename: FieldRename.snake)
class Project {
  const Project({
    required this.title,
    required this.description,
    required this.category,
    this.link = '',
    this.projectImageUrl = '',
    this.id,
    this.starCount = 0,
    this.isStarred = false,
    this.starredByNames = '',
  });

  /// Membuat [Project] dari objek JSON milik DRF.
  factory Project.fromJson(Map<String, dynamic> json) =>
      _$ProjectFromJson(json);

  /// UUID yang ditetapkan server. Tidak ikut dikirim saat membuat proyek baru.
  @JsonKey(includeToJson: false)
  final String? id;

  final String title;
  final String description;

  /// Kategori bebas (maksimal 100 karakter di Django).
  final String category;

  /// Tautan proyek; kosong bila tidak ada.
  @JsonKey(defaultValue: '')
  final String link;

  /// Alamat gambar sampul; kosong bila tidak ada, dan saat itu gambar tidak
  /// ditampilkan.
  @JsonKey(defaultValue: '')
  final String projectImageUrl;

  /// Jumlah bintang. Dihitung server, hanya dibaca klien.
  @JsonKey(includeToJson: false, defaultValue: 0)
  final int starCount;

  /// Apakah pengguna yang sedang login memberi bintang. Hanya dibaca klien.
  @JsonKey(includeToJson: false, defaultValue: false)
  final bool isStarred;

  /// Nama pengguna pemberi bintang, dipisah koma. Hanya dibaca klien.
  @JsonKey(includeToJson: false, defaultValue: '')
  final String starredByNames;

  /// Mengubah proyek menjadi body permintaan POST, hanya berisi field yang
  /// boleh ditulis klien.
  Map<String, dynamic> toJson() => _$ProjectToJson(this);
}
