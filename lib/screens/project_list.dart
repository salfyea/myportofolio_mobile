import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/models/project.dart';
import 'package:myportofolio_mobile/screens/project_detail.dart';
import 'package:myportofolio_mobile/services/api_client.dart';
import 'package:myportofolio_mobile/widgets/left_drawer.dart';
import 'package:myportofolio_mobile/widgets/load_error_view.dart';
import 'package:myportofolio_mobile/widgets/refreshable_message.dart';
import 'package:provider/provider.dart';

/// Daftar proyek yang dibaca dari API Django (publik, tanpa login).
///
/// Future pengambilan data dibuat di [State.initState], **bukan** di `build()`.
/// `build()` bisa dipanggil berkali-kali (rotasi layar, papan ketik, tema), dan
/// membuat Future di sana akan mengirim ulang permintaan HTTP tiap kali.
///
/// Empat keadaan ditangani: memuat, galat (dengan tombol Retry), kosong, dan
/// berisi. Tarik ke bawah (RefreshIndicator) memuat ulang di semua keadaan
/// yang bisa digulir.
class ProjectListPage extends StatefulWidget {
  const ProjectListPage({super.key});

  @override
  State<ProjectListPage> createState() => _ProjectListPageState();
}

class _ProjectListPageState extends State<ProjectListPage> {
  late Future<List<Project>> _projectsFuture;

  @override
  void initState() {
    super.initState();
    _projectsFuture = context.read<ApiClient>().getProjects();
  }

  /// Memuat ulang daftar. Dipakai tombol Retry dan tarik-untuk-muat-ulang.
  Future<void> _reload() async {
    final future = context.read<ApiClient>().getProjects();
    // Body berblok, bukan `=>`: setState melarang callback yang mengembalikan
    // Future, dan `=> _projectsFuture = future` justru mengembalikannya.
    setState(() {
      _projectsFuture = future;
    });

    try {
      await future;
    } on ApiException {
      // Galatnya sudah ditampilkan oleh FutureBuilder; jangan dilempar lagi ke
      // RefreshIndicator.
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Projects')),
      drawer: const LeftDrawer(selected: DrawerDestination.projects),
      body: FutureBuilder<List<Project>>(
        future: _projectsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return LoadErrorView(
              subject: 'proyek',
              error: snapshot.error!,
              onRetry: _reload,
            );
          }

          final projects = snapshot.data ?? const <Project>[];

          if (projects.isEmpty) {
            // Tetap bisa digulir agar tarik-untuk-muat-ulang berfungsi.
            return RefreshableMessage(
              message: 'Belum ada proyek.',
              onRefresh: _reload,
            );
          }

          return RefreshIndicator(
            onRefresh: _reload,
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(12),
              itemCount: projects.length,
              itemBuilder: (context, index) =>
                  _ProjectTile(project: projects[index]),
            ),
          );
        },
      ),
    );
  }
}

/// Satu baris proyek; mengetuknya membuka [ProjectDetailPage].
class _ProjectTile extends StatelessWidget {
  const _ProjectTile({required this.project});

  final Project project;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: Card(
          child: ListTile(
            title: Text(project.title),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  project.category,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  project.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
            isThreeLine: true,
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.star, size: 16),
                const SizedBox(width: 2),
                Text('${project.starCount}'),
              ],
            ),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute<void>(
                builder: (_) => ProjectDetailPage(project: project),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
