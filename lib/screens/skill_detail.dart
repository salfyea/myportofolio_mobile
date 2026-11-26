import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/models/skill.dart';
import 'package:myportofolio_mobile/utils/formatters.dart';
import 'package:myportofolio_mobile/widgets/detail_section.dart';
import 'package:myportofolio_mobile/widgets/remote_image.dart';

/// Halaman detail satu [Skill]: menampilkan seluruh field yang dikirim API.
///
/// Dibuka saat sebuah item pada `SkillListPage` diketuk. Data diteruskan lewat
/// konstruktor, jadi halaman ini tidak perlu memanggil API lagi.
///
/// Kategori yang kosong tidak digambar sebagai chip kosong.
class SkillDetailPage extends StatelessWidget {
  const SkillDetailPage({super.key, required this.skill});

  final Skill skill;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Detail Skill')),
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
                  Center(
                    child: RemoteImage(
                      url: skill.iconUrl,
                      semanticLabel: 'Ikon ${skill.name}',
                      height: 120,
                      width: 120,
                      fit: BoxFit.contain,
                    ),
                  ),

                  Text(skill.name, style: textTheme.headlineSmall),

                  if (skill.category.isNotEmpty)
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Chip(label: Text(skill.category)),
                    ),

                  DetailSection(
                    label: 'URL Ikon',
                    child: SelectableText(skill.iconUrl),
                  ),

                  DetailSection(
                    label: 'Bintang',
                    child: Text(
                      formatStarSummary(skill.starCount, skill.starredByNames),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
