import 'package:material_ui/material_ui.dart';

/// Judul kecil di atas satu blok isi pada layar detail.
class DetailSection extends StatelessWidget {
  const DetailSection({super.key, required this.label, required this.child});

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
