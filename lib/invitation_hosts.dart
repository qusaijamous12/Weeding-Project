import 'package:material_ui/material_ui.dart';

import 'invitation.dart';
import 'studio_theme.dart';

class InvitationHosts extends StatelessWidget {
  const InvitationHosts({
    super.key,
    required this.invitation,
    required this.ink,
    required this.accent,
    this.compact = false,
  });

  final Invitation invitation;
  final Color ink;
  final Color accent;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final families = [
      invitation.groomFamily,
      invitation.brideFamily,
    ].where((name) => name.isNotEmpty).toList();
    if (families.isEmpty) return const SizedBox.shrink();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          families.length == 2 ? 'تتشرف العائلتان' : 'تتشرف العائلة',
          textAlign: TextAlign.center,
          style: displayStyle(compact ? 14 : 19, color: accent, height: 1.5),
        ),
        const SizedBox(height: 3),
        Text(
          families.join(' و'),
          textAlign: TextAlign.center,
          style: displayStyle(compact ? 22 : 30, color: ink, height: 1.5),
        ),
        const SizedBox(height: 4),
        Text(
          'بدعوتكم لحضور حفل الزفاف',
          textAlign: TextAlign.center,
          style: displayStyle(compact ? 13 : 18, color: accent, height: 1.5),
        ),
      ],
    );
  }
}
