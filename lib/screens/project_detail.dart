import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/models/project.dart';

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
                    _CoverImage(url: project.projectImageUrl),

                  Text(project.title, style: textTheme.headlineSmall),

                  Align(
                    alignment: Alignment.centerLeft,
                    child: Chip(label: Text(project.category)),
                  ),

                  _Section(
                    label: 'Deskripsi',
                    child: SelectableText(project.description),
                  ),

                  if (project.link.isNotEmpty)
                    _Section(
                      label: 'Tautan',
                      child: SelectableText(project.link),
                    ),

                  _Section(
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

/// Judul kecil di atas satu blok isi detail.
class _Section extends StatelessWidget {
  const _Section({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 4,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelLarge
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        child,
      ],
    );
  }
}

/// Gambar sampul dari URL, dengan penanda saat memuat dan saat gagal.
class _CoverImage extends StatelessWidget {
  const _CoverImage({required this.url});

  final String url;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.network(
        url,
        height: 200,
        fit: BoxFit.cover,
        semanticLabel: 'Gambar sampul proyek',
        loadingBuilder: (context, child, progress) {
          if (progress == null) {
            return child;
          }
          return const SizedBox(
            height: 200,
            child: Center(child: CircularProgressIndicator()),
          );
        },
        // URL yang salah atau tidak terjangkau tidak boleh merusak halaman.
        errorBuilder: (context, error, stackTrace) => const SizedBox(
          height: 200,
          child: Center(child: Icon(Icons.broken_image_outlined, size: 48)),
        ),
      ),
    );
  }
}
