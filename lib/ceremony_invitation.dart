import 'package:material_ui/material_ui.dart';
import 'package:url_launcher/url_launcher.dart';

import 'invitation.dart';
import 'invitation_hosts.dart';
import 'invitation_countdown.dart';
import 'invitation_rsvp.dart';
import 'motion.dart';
import 'studio_theme.dart';

class CeremonyCover extends StatelessWidget {
  const CeremonyCover({
    super.key,
    required this.invitation,
    this.thumbnail = false,
    this.viewportHeight,
    this.onDetails,
  });

  final Invitation invitation;
  final bool thumbnail;
  final double? viewportHeight;
  final VoidCallback? onDetails;

  @override
  Widget build(BuildContext context) {
    final style = invitation.style;
    return LayoutBuilder(
      builder: (context, constraints) {
        final nameSize = thumbnail
            ? 35.0
            : (constraints.maxWidth * .16).clamp(48.0, 82.0);
        return ConstrainedBox(
          constraints: BoxConstraints(
            minWidth: constraints.maxWidth,
            minHeight: thumbnail ? 300 : (viewportHeight ?? 760),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned.fill(
                child: Image.asset(
                  style.artwork,
                  fit: BoxFit.cover,
                  excludeFromSemantics: true,
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: thumbnail ? 25 : 40,
                  vertical: thumbnail
                      ? 35
                      : invitation.hasHostingFamilies
                      ? 62
                      : 94,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (invitation.hasHostingFamilies) ...[
                      InvitationHosts(
                        invitation: invitation,
                        ink: style.ink,
                        accent: style.accent,
                        compact: thumbnail,
                      ),
                      SizedBox(height: thumbnail ? 15 : 25),
                    ],
                    Text(
                      'حفل زفاف',
                      style: displayStyle(
                        thumbnail ? 21 : 31,
                        color: style.ink,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      jordanDate(invitation.date, includeDay: false),
                      textAlign: TextAlign.center,
                      style: displayStyle(
                        thumbnail ? 16 : 22,
                        color: style.accent,
                      ),
                    ),
                    SizedBox(
                      height: thumbnail
                          ? 24
                          : invitation.hasHostingFamilies
                          ? 32
                          : 62,
                    ),
                    Text(
                      invitation.groom.isEmpty ? 'العريس' : invitation.groom,
                      textAlign: TextAlign.center,
                      style: displayStyle(
                        nameSize,
                        color: style.ink,
                        height: 1.4,
                      ),
                    ),
                    Text(
                      'و',
                      style: displayStyle(
                        thumbnail ? 22 : 32,
                        color: style.accent,
                      ),
                    ),
                    Text(
                      invitation.bride.isEmpty ? 'العروس' : invitation.bride,
                      textAlign: TextAlign.center,
                      style: displayStyle(
                        nameSize,
                        color: style.ink,
                        height: 1.4,
                      ),
                    ),
                    if (onDetails != null) ...[
                      SizedBox(height: invitation.hasHostingFamilies ? 32 : 56),
                      TextButton(
                        onPressed: onDetails,
                        style: TextButton.styleFrom(
                          foregroundColor: style.ink,
                          backgroundColor: style.paper.withValues(alpha: .84),
                          shape: const StadiumBorder(),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'تفاصيل يومنا',
                              style: displayStyle(22, color: style.ink),
                            ),
                            const Icon(Icons.keyboard_arrow_down_rounded),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class CeremonyOpening extends StatefulWidget {
  const CeremonyOpening({super.key, required this.style, required this.child});

  final InvitationStyle style;
  final Widget child;

  @override
  State<CeremonyOpening> createState() => _CeremonyOpeningState();
}

class _CeremonyOpeningState extends State<CeremonyOpening>
    with SingleTickerProviderStateMixin {
  late final _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1250),
  );
  bool _opened = false;

  void _open() {
    if (_controller.isAnimating || _opened) return;
    if (reduceMotion(context)) {
      setState(() => _opened = true);
      return;
    }
    _controller.forward().then((_) {
      if (mounted) setState(() => _opened = true);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Stack(
    fit: StackFit.expand,
    children: [
      ExcludeSemantics(
        excluding: !_opened,
        child: AbsorbPointer(absorbing: !_opened, child: widget.child),
      ),
      if (!_opened)
        LayoutBuilder(
          builder: (context, viewport) {
            final width = viewport.maxWidth;
            final height = viewport.maxHeight;
            return Semantics(
              button: true,
              label: 'فتح الدعوة',
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  final progress = Curves.easeInOutCubic.transform(
                    _controller.value,
                  );
                  return Stack(
                    fit: StackFit.expand,
                    children: [
                      for (final left in [true, false])
                        Positioned(
                          left: left ? 0 : width / 2,
                          top: 0,
                          width: width / 2,
                          height: height,
                          child: FractionalTranslation(
                            translation: Offset(
                              (left ? -1 : 1) * progress * 1.08,
                              0,
                            ),
                            child: ClipRect(
                              child: OverflowBox(
                                alignment: left
                                    ? Alignment.centerLeft
                                    : Alignment.centerRight,
                                minWidth: width,
                                maxWidth: width,
                                minHeight: height,
                                maxHeight: height,
                                child: ColoredBox(
                                  color: widget.style.paper,
                                  child: Image.asset(
                                    widget.style.doorsArtwork,
                                    fit: BoxFit.cover,
                                    width: width,
                                    height: height,
                                    excludeFromSemantics: true,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      if (!_controller.isAnimating)
                        Positioned(
                          left: 25,
                          right: 25,
                          bottom: height * .14,
                          child: Center(
                            child: FilledButton.icon(
                              onPressed: _open,
                              icon: const Icon(
                                Icons.auto_awesome_outlined,
                                size: 18,
                              ),
                              label: const Text('افتحوا الدعوة'),
                              style: FilledButton.styleFrom(
                                backgroundColor: widget.style.ink,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 27,
                                  vertical: 17,
                                ),
                                shape: const StadiumBorder(),
                              ),
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
            );
          },
        ),
    ],
  );
}

class CeremonyContent extends StatefulWidget {
  const CeremonyContent({
    super.key,
    required this.invitation,
    this.interactive = true,
    this.viewportHeight,
  });

  final Invitation invitation;
  final bool interactive;
  final double? viewportHeight;

  @override
  State<CeremonyContent> createState() => _CeremonyContentState();
}

class _CeremonyContentState extends State<CeremonyContent> {
  final _details = GlobalKey();

  Widget _title(String title) => Column(
    children: [
      Text(
        title,
        textAlign: TextAlign.center,
        style: displayStyle(
          34,
          color: widget.invitation.style.ink,
          height: 1.4,
        ),
      ),
      const SizedBox(height: 17),
      SizedBox(
        width: 78,
        child: Divider(color: widget.invitation.style.swatch),
      ),
      const SizedBox(height: 30),
    ],
  );

  Widget _section(Widget child) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 38),
    child: child,
  );

  Widget _detail(String label, String value) => Padding(
    padding: const EdgeInsets.only(bottom: 25),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          label,
          style: displayStyle(23, color: widget.invitation.style.accent),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: displayStyle(
            27,
            color: widget.invitation.style.ink,
            height: 1.6,
          ),
        ),
      ],
    ),
  );

  Future<void> _openMap() async {
    final uri = widget.invitation.mapUri;
    if (uri == null) return;
    try {
      if (await launchUrl(uri, webOnlyWindowName: '_blank')) return;
    } catch (_) {
      // Keep the invitation available when the external map cannot open.
    }
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تعذّر فتح الخريطة. حاولوا مرة أخرى.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final invitation = widget.invitation;
    final style = invitation.style;
    return ColoredBox(
      color: style.paper,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CeremonyCover(
            invitation: invitation,
            viewportHeight: widget.viewportHeight,
            onDetails: widget.interactive
                ? () => Scrollable.ensureVisible(
                    _details.currentContext!,
                    duration: reduceMotion(context)
                        ? Duration.zero
                        : const Duration(milliseconds: 500),
                    curve: Curves.easeInOutCubic,
                  )
                : null,
          ),
          _section(
            Column(
              children: [
                if (invitation.hasFamilies) ...[
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 45,
                    runSpacing: 24,
                    children: [
                      for (final family in [
                        [invitation.groomFather, invitation.groomMother],
                        [invitation.brideFather, invitation.brideMother],
                      ])
                        if (family.any((name) => name.isNotEmpty))
                          SizedBox(
                            width: 210,
                            child: Text(
                              family
                                  .where((name) => name.isNotEmpty)
                                  .join('\n'),
                              textAlign: TextAlign.center,
                              style: displayStyle(
                                25,
                                color: style.accent,
                                height: 1.7,
                              ),
                            ),
                          ),
                    ],
                  ),
                  const SizedBox(height: 30),
                ],
                Text(
                  'يتشرفون بدعوتكم لمشاركتهم فرحة زفاف',
                  textAlign: TextAlign.center,
                  style: displayStyle(24, color: style.ink, height: 1.8),
                ),
                const SizedBox(height: 25),
                Text(
                  invitation.couple,
                  textAlign: TextAlign.center,
                  style: displayStyle(45, color: style.ink, height: 1.5),
                ),
                const SizedBox(height: 25),
                Text(
                  invitation.message.isEmpty
                      ? 'بكل الحب، ننتظركم لتكتمل فرحتنا بحضوركم.'
                      : invitation.message,
                  textAlign: TextAlign.center,
                  style: displayStyle(26, color: style.accent, height: 1.9),
                ),
              ],
            ),
          ),
          _section(
            Column(
              children: [
                _title('العدّ التنازلي ليومنا المنتظر'),
                RepaintBoundary(
                  child: InvitationCountdown(
                    instant: invitation.instant,
                    style: style,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'أيام قليلة ونلتقي بأحبابنا',
                  textAlign: TextAlign.center,
                  style: displayStyle(25, color: style.accent, height: 1.7),
                ),
              ],
            ),
          ),
          Padding(
            key: _details,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 38),
            child: Column(
              children: [
                _title('تفاصيل حفل الزفاف'),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(25, 28, 25, 3),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: .62),
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(
                      color: style.swatch.withValues(alpha: .6),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _detail('التاريخ', jordanDate(invitation.date)),
                      _detail(
                        'موعد الحفل · بتوقيت الأردن',
                        invitation.timeLabel,
                      ),
                      _detail('مكان الحفل', invitation.location),
                      if (invitation.address.isNotEmpty)
                        _detail('العنوان', invitation.address),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (invitation.mapUri != null)
            _section(
              Column(
                children: [
                  _title('هنا نجتمع لنحتفل'),
                  if (Uri.tryParse(invitation.venueImageUrl)?.scheme == 'https')
                    Padding(
                      padding: const EdgeInsets.only(bottom: 24),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: Image.network(
                          invitation.venueImageUrl,
                          width: double.infinity,
                          height: 260,
                          fit: BoxFit.cover,
                          semanticLabel: 'صورة ${invitation.venue}',
                          errorBuilder: (context, error, stack) => Padding(
                            padding: const EdgeInsets.all(20),
                            child: Text(
                              'تعذّر تحميل صورة القاعة.',
                              style: TextStyle(color: style.accent),
                            ),
                          ),
                        ),
                      ),
                    ),
                  Text(
                    invitation.location,
                    textAlign: TextAlign.center,
                    style: displayStyle(27, color: style.ink, height: 1.7),
                  ),
                  if (invitation.address.isNotEmpty)
                    Text(
                      invitation.address,
                      textAlign: TextAlign.center,
                      style: displayStyle(22, color: style.accent, height: 1.7),
                    ),
                  const SizedBox(height: 22),
                  OutlinedButton.icon(
                    onPressed: widget.interactive ? _openMap : null,
                    icon: const Icon(Icons.location_on_outlined, size: 20),
                    label: const Text('فتح الموقع في الخرائط'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: style.ink,
                      side: BorderSide(color: style.swatch),
                      shape: const StadiumBorder(),
                    ),
                  ),
                ],
              ),
            ),
          if (invitation.rsvpPhone.isNotEmpty)
            _section(
              InvitationRsvp(
                invitation: invitation,
                interactive: widget.interactive,
              ),
            ),
          _section(
            Column(
              children: [
                Text(
                  'بحضوركم تكتمل فرحتنا',
                  textAlign: TextAlign.center,
                  style: displayStyle(34, color: style.ink, height: 1.7),
                ),
                const SizedBox(height: 15),
                Text(
                  'دام الفرح عامرًا في قلوبكم وبيوتكم',
                  textAlign: TextAlign.center,
                  style: displayStyle(23, color: style.accent, height: 1.8),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
