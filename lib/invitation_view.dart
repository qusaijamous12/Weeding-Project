import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:url_launcher/url_launcher.dart';

import 'invitation.dart';
import 'motion.dart';
import 'studio_theme.dart';

class InvitationCover extends StatelessWidget {
  const InvitationCover({
    super.key,
    required this.invitation,
    this.thumbnail = false,
    this.onDetails,
    this.viewportHeight,
  });

  final Invitation invitation;
  final bool thumbnail;
  final VoidCallback? onDetails;
  final double? viewportHeight;

  @override
  Widget build(BuildContext context) {
    final style = invitation.style;
    final coverInk = style.photoCover ? const Color(0xFFFFFBF1) : style.ink;
    final coverAccent = style.photoCover
        ? const Color(0xFFFFE8BE)
        : style.accent;
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final headingSize = thumbnail ? 36.0 : (width * .12).clamp(37.0, 86.0);
        final names = [
          invitation.groom.isEmpty ? 'العريس' : invitation.groom,
          invitation.bride.isEmpty ? 'العروس' : invitation.bride,
        ];
        return ConstrainedBox(
          constraints: BoxConstraints(
            minWidth: width,
            minHeight: thumbnail
                ? 242
                : style.photoCover && viewportHeight != null
                ? viewportHeight!
                : (width * .99).clamp(365.0, 610.0),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned.fill(
                child: ColoredBox(
                  color: style.photoCover ? ink : style.paper,
                  child: AnimatedSwitcher(
                    duration: reduceMotion(context)
                        ? Duration.zero
                        : const Duration(milliseconds: 550),
                    child: Image.asset(
                      style.artwork,
                      key: ValueKey(style),
                      width: double.infinity,
                      height: double.infinity,
                      fit: style == InvitationStyle.night
                          ? BoxFit.fill
                          : BoxFit.cover,
                      excludeFromSemantics: true,
                    ),
                  ),
                ),
              ),
              if (style.photoCover)
                const Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Color(0x300A1014),
                          Color(0xBF0A1014),
                          Color(0xB50A1014),
                        ],
                        stops: [0, .48, 1],
                      ),
                    ),
                  ),
                ),
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: width * (thumbnail ? .14 : .18),
                  vertical: thumbnail ? 35 : 68,
                ),
                child: MotionReveal(
                  delay: thumbnail
                      ? Duration.zero
                      : const Duration(milliseconds: 100),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (style == InvitationStyle.night)
                        Seal(color: coverAccent, size: thumbnail ? 25 : 43)
                      else
                        _Flourish(color: coverAccent),
                      SizedBox(height: thumbnail ? 8 : 20),
                      Text(
                        'دعوة زفاف',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: coverInk,
                          fontSize: thumbnail ? 11 : 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (!thumbnail) ...[
                        const SizedBox(height: 12),
                        Text(
                          'بكل محبة ندعوكم لمشاركتنا فرحة زفافنا',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: coverInk,
                            fontSize: 14,
                            height: 1.7,
                          ),
                        ),
                      ],
                      SizedBox(height: thumbnail ? 7 : 17),
                      Wrap(
                        direction: !thumbnail && style == InvitationStyle.night
                            ? Axis.vertical
                            : Axis.horizontal,
                        alignment: WrapAlignment.center,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: thumbnail ? 7 : 14,
                        children: [
                          Text(
                            names.first,
                            textAlign: TextAlign.center,
                            style: displayStyle(headingSize, color: coverInk),
                          ),
                          Text(
                            'و',
                            style: displayStyle(
                              headingSize * .57,
                              color: coverAccent,
                            ),
                          ),
                          Text(
                            names.last,
                            textAlign: TextAlign.center,
                            style: displayStyle(headingSize, color: coverInk),
                          ),
                        ],
                      ),
                      SizedBox(height: thumbnail ? 4 : 14),
                      Text(
                        jordanDate(invitation.date, includeDay: !thumbnail),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: coverInk,
                          fontSize: thumbnail ? 10 : 14,
                          fontWeight: FontWeight.w600,
                          height: 1.75,
                        ),
                      ),
                      if (onDetails != null) ...[
                        const SizedBox(height: 21),
                        TextButton.icon(
                          onPressed: onDetails,
                          icon: const Icon(
                            Icons.keyboard_arrow_down_rounded,
                            size: 19,
                          ),
                          label: const Text('تفاصيل الحفل'),
                          style: TextButton.styleFrom(
                            foregroundColor: coverInk,
                            backgroundColor: style.photoCover
                                ? const Color(0x440A1014)
                                : style.paper.withValues(alpha: .78),
                            side: style.photoCover
                                ? const BorderSide(color: Color(0x88FFFBF1))
                                : null,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class InvitationContent extends StatefulWidget {
  const InvitationContent({
    super.key,
    required this.invitation,
    this.interactive = true,
    this.viewportHeight,
  });

  final Invitation invitation;
  final bool interactive;
  final double? viewportHeight;

  @override
  State<InvitationContent> createState() => _InvitationContentState();
}

class _InvitationContentState extends State<InvitationContent> {
  final _details = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final invitation = widget.invitation;
    final style = invitation.style;

    return AnimatedContainer(
      duration: reduceMotion(context)
          ? Duration.zero
          : const Duration(milliseconds: 450),
      color: Color.lerp(
        style.paper,
        style == InvitationStyle.night ? ink : Colors.white,
        .34,
      )!,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InvitationCover(
            invitation: invitation,
            viewportHeight: widget.viewportHeight,
            onDetails: widget.interactive
                ? () {
                    final target = _details.currentContext;
                    if (target != null) {
                      Scrollable.ensureVisible(
                        target,
                        duration: reduceMotion(context)
                            ? Duration.zero
                            : const Duration(milliseconds: 350),
                        curve: Curves.easeOutCubic,
                      );
                    }
                  }
                : null,
          ),
          if (style.photoCover)
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 46, 24, 24),
              child: Column(
                children: [
                  _Flourish(color: style.accent),
                  const SizedBox(height: 12),
                  Text(
                    'أهلًا وسهلًا بكم',
                    textAlign: TextAlign.center,
                    style: displayStyle(36, color: style.ink),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'يسعدنا حضوركم ومشاركتكم فرحتنا',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: style.ink),
                  ),
                ],
              ),
            ),
          if (invitation.hasFamilies)
            _Section(
              style: style,
              title: 'أهل العروسين',
              icon: Icons.favorite_border_rounded,
              child: Wrap(
                alignment: WrapAlignment.center,
                spacing: 34,
                runSpacing: 22,
                children: [
                  if (invitation.groomFather.isNotEmpty ||
                      invitation.groomMother.isNotEmpty)
                    _Family(
                      title: 'عائلة العريس',
                      father: invitation.groomFather,
                      mother: invitation.groomMother,
                      style: style,
                    ),
                  if (invitation.brideFather.isNotEmpty ||
                      invitation.brideMother.isNotEmpty)
                    _Family(
                      title: 'عائلة العروس',
                      father: invitation.brideFather,
                      mother: invitation.brideMother,
                      style: style,
                    ),
                ],
              ),
            ),
          if (style.photoCover) ...[
            _Section(
              style: style,
              title: 'الوقت المتبقي للزفاف',
              icon: Icons.hourglass_bottom_rounded,
              child: RepaintBoundary(
                child: _Countdown(instant: invitation.instant, style: style),
              ),
            ),
            Padding(
              key: _details,
              padding: const EdgeInsets.fromLTRB(20, 30, 20, 13),
              child: Text(
                'تفاصيل الحفل',
                textAlign: TextAlign.center,
                style: displayStyle(41, color: style.ink),
              ),
            ),
            _Section(
              style: style,
              title: 'التاريخ',
              icon: Icons.calendar_month_outlined,
              child: Text(
                jordanDate(invitation.date),
                textAlign: TextAlign.center,
                style: TextStyle(color: style.ink),
              ),
            ),
          ] else
            _Section(
              key: _details,
              style: style,
              title: 'موعد الزفاف',
              icon: Icons.calendar_month_outlined,
              child: Column(
                children: [
                  Text(
                    jordanDate(invitation.date),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: style.ink,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    '${jordanTime(invitation.date)} · بتوقيت الأردن',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: style.ink, fontSize: 13),
                  ),
                  const SizedBox(height: 22),
                  RepaintBoundary(
                    child: _Countdown(
                      instant: invitation.instant,
                      style: style,
                    ),
                  ),
                ],
              ),
            ),
          if (invitation.location.isNotEmpty)
            _Section(
              style: style,
              title: 'مكان الحفل',
              icon: Icons.location_on_outlined,
              child: Column(
                children: [
                  Text(
                    invitation.location,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: style.ink,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (widget.interactive && invitation.mapUri != null) ...[
                    const SizedBox(height: 14),
                    OutlinedButton.icon(
                      onPressed: () => _openMap(invitation.mapUri!),
                      icon: const Icon(Icons.north_west_rounded, size: 16),
                      label: const Text('فتح الخريطة'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: style.ink,
                        side: BorderSide(color: style.swatch),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          if (style.photoCover)
            _Section(
              style: style,
              title: 'وقت الحفل',
              icon: Icons.schedule_rounded,
              child: Text(
                '${jordanTime(invitation.date)} · بتوقيت الأردن',
                textAlign: TextAlign.center,
                style: TextStyle(color: style.ink),
              ),
            ),
          if (invitation.message.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 29, 22, 42),
              child: Text(
                invitation.message,
                textAlign: TextAlign.center,
                style: displayStyle(28, color: style.ink, height: 1.45),
              ),
            ),
          if (style.photoCover) const SizedBox(height: 30),
        ],
      ),
    );
  }

  Future<void> _openMap(Uri uri) async {
    final opened = await launchUrl(uri, webOnlyWindowName: '_blank');
    if (!opened && mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('تعذّر فتح الخريطة.')));
    }
  }
}

class _Section extends StatelessWidget {
  const _Section({
    super.key,
    required this.style,
    required this.title,
    required this.icon,
    required this.child,
  });

  final InvitationStyle style;
  final String title;
  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final iconWidget = Icon(
      icon,
      size: 21,
      color: style.photoCover ? style.paper : style.accent,
    );
    final content = Column(
      children: [
        if (style.photoCover)
          Container(
            padding: const EdgeInsets.all(11),
            decoration: BoxDecoration(
              color: style.accent,
              borderRadius: BorderRadius.circular(11),
            ),
            child: iconWidget,
          )
        else
          iconWidget,
        const SizedBox(height: 10),
        Text(
          title,
          textAlign: TextAlign.center,
          style: displayStyle(34, color: style.ink),
        ),
        const SizedBox(height: 14),
        child,
      ],
    );
    if (style.photoCover) {
      return Center(
        child: Container(
          width: double.infinity,
          constraints: const BoxConstraints(maxWidth: 520),
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 7),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 23),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: .65),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: style.swatch),
          ),
          child: content,
        ),
      );
    }
    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: style.swatch.withValues(alpha: .48)),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 34),
      child: content,
    );
  }
}

class _Family extends StatelessWidget {
  const _Family({
    required this.title,
    required this.father,
    required this.mother,
    required this.style,
  });
  final String title;
  final String father;
  final String mother;
  final InvitationStyle style;

  @override
  Widget build(BuildContext context) => ConstrainedBox(
    constraints: const BoxConstraints(minWidth: 142, maxWidth: 250),
    child: Column(
      children: [
        Text(
          title,
          style: TextStyle(color: style.accent, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 6),
        for (final name in [father, mother])
          if (name.isNotEmpty)
            Text(
              name,
              textAlign: TextAlign.center,
              style: TextStyle(color: style.ink, height: 1.85),
            ),
      ],
    ),
  );
}

class _Countdown extends StatefulWidget {
  const _Countdown({required this.instant, required this.style});
  final DateTime instant;
  final InvitationStyle style;

  @override
  State<_Countdown> createState() => _CountdownState();
}

class _CountdownState extends State<_Countdown> {
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

class _Flourish extends StatelessWidget {
  const _Flourish({required this.color});
  final Color color;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      SizedBox(width: 19, child: Divider(color: color, thickness: .65)),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 7),
        child: Transform.rotate(
          angle: .7854,
          child: Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              border: Border.all(color: color, width: .8),
            ),
          ),
        ),
      ),
      SizedBox(width: 19, child: Divider(color: color, thickness: .65)),
    ],
  );
}

class GuestPage extends StatelessWidget {
  const GuestPage({
    super.key,
    required this.invitation,
    this.onChoose,
    this.preview = false,
  });
  final Invitation invitation;
  final VoidCallback? onChoose;
  final bool preview;

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Color.lerp(invitation.style.paper, canvas, .16),
    appBar: preview
        ? AppBar(
            title: const Text('معاينة الدعوة'),
            actions: [
              if (onChoose != null)
                Padding(
                  padding: const EdgeInsetsDirectional.only(end: 15),
                  child: FilledButton(
                    onPressed: onChoose,
                    child: const Text('استخدم التصميم'),
                  ),
                ),
            ],
          )
        : null,
    body: LayoutBuilder(
      builder: (context, viewport) => SingleChildScrollView(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: invitation.style.photoCover ? 1040 : 820,
            ),
            child: InvitationContent(
              invitation: invitation,
              viewportHeight: viewport.maxHeight,
            ),
          ),
        ),
      ),
    ),
  );
}
