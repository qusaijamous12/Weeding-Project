import 'package:material_ui/material_ui.dart';

import 'invitation.dart';
import 'motion.dart';
import 'studio_theme.dart';

class InvitationCountdown extends StatefulWidget {
  const InvitationCountdown({
    super.key,
    required this.instant,
    required this.style,
  });
  final DateTime instant;
  final InvitationStyle style;

  @override
  State<InvitationCountdown> createState() => _InvitationCountdownState();
}

class _InvitationCountdownState extends State<InvitationCountdown> {
  final _ticks = Stream.periodic(const Duration(seconds: 1), (tick) => tick);

  @override
  Widget build(BuildContext context) {
    final style = widget.style;
    return StreamBuilder<int>(
      stream: _ticks,
      builder: (context, snapshot) {
        final left = widget.instant.difference(DateTime.now().toUtc());
        if (left.inSeconds <= 0) {
          return Text(
            'حلّ موعد الزفاف',
            style: displayStyle(24, color: style.accent),
          );
        }
        return Wrap(
          spacing: 8,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children: [
            _TimeUnit(left.inDays, 'يوم', style),
            _TimeUnit(left.inHours % 24, 'ساعة', style),
            _TimeUnit(left.inMinutes % 60, 'دقيقة', style),
            _TimeUnit(left.inSeconds % 60, 'ثانية', style),
          ],
        );
      },
    );
  }
}

class _TimeUnit extends StatelessWidget {
  const _TimeUnit(this.value, this.unit, this.style);
  final int value;
  final String unit;
  final InvitationStyle style;

  @override
  Widget build(BuildContext context) => Container(
    constraints: const BoxConstraints(minWidth: 55),
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: style.swatch.withValues(alpha: .65)),
    ),
    child: Column(
      children: [
        AnimatedSwitcher(
          duration: reduceMotion(context)
              ? Duration.zero
              : const Duration(milliseconds: 240),
          transitionBuilder: (child, animation) => FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: animation.drive(
                Tween(begin: const Offset(0, .18), end: Offset.zero),
              ),
              child: child,
            ),
          ),
          child: Text(
            arabicDigits(value.toString().padLeft(2, '0')),
            key: ValueKey(value),
            style: displayStyle(25, color: style.ink),
          ),
        ),
        Text(unit, style: TextStyle(fontSize: 11, color: style.ink)),
      ],
    ),
  );
}
