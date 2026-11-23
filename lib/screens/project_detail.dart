import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/models/project.dart';
import 'package:myportofolio_mobile/widgets/detail_section.dart';
import 'package:myportofolio_mobile/widgets/remote_image.dart';

/// Halaman detail satu [Project]: menampilkan seluruh field yang dikirim API.
///
/// Dibuka saat sebuah item pada `ProjectListPage` diketuk. Data diteruskan
/// lewat konstruktor, jadi halaman ini tidak perlu memanggil API lagi.
///
/// Gambar sampul hanya ditampilkan bila `projectImageUrl` tidak kosong; bagian
/// tautan dan bintang yang kosong juga tidak digambar.
class ProjectDetailPage extends StatelessWidget {
  const ProjectDetailPage({super.key, required this.project});

  final Project project;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Detail Proyek')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: 16,
                children: [
                  if (project.projectImageUrl.isNotEmpty)
                    RemoteImage(
                      url: project.projectImageUrl,
                      semanticLabel: 'Gambar sampul proyek',
                    ),

                  Text(project.title, style: textTheme.headlineSmall),

                  Align(
                    alignment: Alignment.centerLeft,
                    child: Chip(label: Text(project.category)),
                  ),

                  DetailSection(
                    label: 'Deskripsi',
                    child: SelectableText(project.description),
                  ),

                  if (project.link.isNotEmpty)
                    DetailSection(
                      label: 'Tautan',
                      child: SelectableText(project.link),
                    ),

                  DetailSection(
                    label: 'Bintang',
                    child: Text(_starSummary(project)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  static String _starSummary(Project project) {
    final count = '${project.starCount} bintang';
    if (project.starredByNames.isEmpty) {
      return count;
    }
    return '$count, diberikan oleh ${project.starredByNames}';
  }
}
