import 'package:flutter/material.dart';

import 'drafts.dart';
import 'editor.dart';
import 'invitation.dart';
import 'invitation_view.dart';
import 'motion.dart';
import 'studio_theme.dart';

class Studio extends StatefulWidget {
  const Studio({super.key, required this.drafts});
  final Drafts drafts;

  @override
  State<Studio> createState() => _StudioState();
}

class _StudioState extends State<Studio> {
  final _gallery = GlobalKey();

  void _browse() {
    final section = _gallery.currentContext;
    if (section != null) {
      Scrollable.ensureVisible(
        section,
        duration: reduceMotion(context)
            ? Duration.zero
            : const Duration(milliseconds: 450),
        curve: Curves.easeOutCubic,
      );
    }
  }

  void _edit(InvitationStyle style) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) =>
            Editor(drafts: widget.drafts, initial: Invitation.empty(style)),
      ),
    );
  }

  void _preview(InvitationStyle style) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (previewContext) => GuestPage(
          invitation: Invitation.example(style),
          preview: true,
          onChoose: () {
            Navigator.of(previewContext).pop();
            _edit(style);
          },
        ),
      ),
    );
  }

  void _saved() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => _SavedDrafts(
          drafts: widget.drafts,
          onCreate: () {
            Navigator.of(context).pop();
            _browse();
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 700;
        final margin = compact ? 20.0 : 40.0;
        return Column(
          children: [
            DecoratedBox(
              decoration: const BoxDecoration(
                color: canvas,
                border: Border(bottom: BorderSide(color: outline)),
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1240),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: margin),
                    child: _Header(
                      compact: compact,
                      onBrowse: _browse,
                      onSaved: _saved,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1240),
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: margin),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          SizedBox(height: compact ? 37 : 52),
                          _Hero(compact: compact, onBrowse: _browse),
                          SizedBox(height: compact ? 53 : 66),
                          _Gallery(
                            key: _gallery,
                            onPreview: _preview,
                            onChoose: _edit,
                          ),
                          SizedBox(height: compact ? 48 : 69),
                          const Divider(height: 1, color: outline),
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 24),
                            child: Text(
                              'وِصال · استوديو دعوات الزفاف',
                              style: TextStyle(color: muted, fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    ),
  );
}

class _Header extends StatelessWidget {
  const _Header({
    required this.compact,
    required this.onBrowse,
    required this.onSaved,
  });
  final bool compact;
  final VoidCallback onBrowse;
  final VoidCallback onSaved;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: compact ? 67 : 76,
    child: Row(
      children: [
        const Seal(size: 39),
        const SizedBox(width: 9),
        Text('وِصال', style: displayStyle(36, height: 1)),
        if (!compact) ...[
          const SizedBox(width: 15),
          Container(color: outline, height: 23, width: 1),
          const SizedBox(width: 14),
          const Text(
            'استوديو دعوات الزفاف',
            style: TextStyle(color: muted, fontSize: 12),
          ),
        ],
        const Spacer(),
        if (!compact) ...[
          TextButton(onPressed: onBrowse, child: const Text('التصاميم')),
          const SizedBox(width: 13),
        ],
        OutlinedButton.icon(
          onPressed: onSaved,
          icon: const Icon(Icons.folder_open_outlined, size: 18),
          label: const Text('دعواتي'),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(0, 40),
            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
          ),
        ),
      ],
    ),
  );
}

class _Hero extends StatelessWidget {
  const _Hero({required this.compact, required this.onBrowse});
  final bool compact;
  final VoidCallback onBrowse;

  @override
  Widget build(BuildContext context) {
    final copy = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const MotionReveal(child: _Eyebrow('دعوات زفاف رقمية')),
        SizedBox(height: compact ? 20 : 21),
        MotionReveal(
          delay: const Duration(milliseconds: 90),
          child: Text.rich(
            TextSpan(
              text: 'دعوة تُشبه',
              children: [
                TextSpan(
                  text: '\nفرحتكم.',
                  style: TextStyle(color: olive),
                ),
              ],
            ),
            style: displayStyle(compact ? 59 : 83, height: 1.07),
          ),
        ),
        SizedBox(height: compact ? 17 : 22),
        const MotionReveal(
          delay: Duration(milliseconds: 180),
          child: Text(
            'اختاروا التصميم، أضيفوا أسماءكم وتفاصيل الحفل، وشاركوا فرحتكم برابط واحد.',
            style: TextStyle(color: muted, fontSize: 16, height: 1.9),
          ),
        ),
        SizedBox(height: compact ? 22 : 27),
        MotionReveal(
          delay: const Duration(milliseconds: 270),
          child: FilledButton.icon(
            onPressed: onBrowse,
            icon: const Icon(Icons.arrow_downward_rounded, size: 17),
            label: const Text('تصفّح التصاميم'),
          ),
        ),
      ],
    );

    if (compact) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          copy,
          const SizedBox(height: 29),
          const MotionReveal(
            delay: Duration(milliseconds: 150),
            distance: 30,
            child: HoverLift(child: _StudioPhoto()),
          ),
        ],
      );
    }
    return Row(
      children: [
        Expanded(flex: 4, child: copy),
        const SizedBox(width: 38),
        const Expanded(
          flex: 6,
          child: MotionReveal(
            delay: Duration(milliseconds: 150),
            distance: 30,
            child: HoverLift(child: _StudioPhoto()),
          ),
        ),
      ],
    );
  }
}

class _StudioPhoto extends StatelessWidget {
  const _StudioPhoto();

  @override
  Widget build(BuildContext context) => AspectRatio(
    aspectRatio: 1.5,
    child: ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final scale = constraints.maxWidth / 720;
          return Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(
                'assets/images/studio.webp',
                fit: BoxFit.cover,
                excludeFromSemantics: true,
              ),
              Align(
                alignment: const Alignment(.04, -.065),
                child: ExcludeSemantics(
                  child: Transform.rotate(
                    angle: -.185,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Seal(color: const Color(0xFF62664B), size: 37 * scale),
                        SizedBox(height: 15 * scale),
                        Text(
                          'دعوة زفاف',
                          style: TextStyle(
                            fontSize: 15 * scale,
                            color: const Color(0xFF474C35),
                          ),
                        ),
                        SizedBox(height: 5 * scale),
                        Text(
                          'عمر وليان',
                          style: displayStyle(
                            49 * scale,
                            color: const Color(0xFF3D4430),
                          ),
                        ),
                        SizedBox(height: 10 * scale),
                        Text(
                          'عمّان · الأردن',
                          style: TextStyle(
                            fontSize: 14 * scale,
                            color: const Color(0xFF474C35),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    ),
  );
}

class _Eyebrow extends StatelessWidget {
  const _Eyebrow(this.label);
  final String label;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(width: 25, height: 1, color: const Color(0xFF858C70)),
      const SizedBox(width: 9),
      Text(
        label,
        style: const TextStyle(
          color: olive,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
    ],
  );
}

class _Gallery extends StatelessWidget {
  const _Gallery({super.key, required this.onPreview, required this.onChoose});
  final ValueChanged<InvitationStyle> onPreview;
  final ValueChanged<InvitationStyle> onChoose;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final columns = constraints.maxWidth >= 790
          ? 3
          : (constraints.maxWidth >= 540 ? 2 : 1);
      final width = (constraints.maxWidth - (columns - 1) * 20) / columns;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Divider(height: 1, color: outline),
          const SizedBox(height: 24),
          Text('معرض التصاميم', style: displayStyle(50)),
          const SizedBox(height: 2),
          const Text(
            'عاينوا كل تصميم واختاروا الأقرب لأسلوبكم.',
            style: TextStyle(fontSize: 14, color: muted, height: 1.7),
          ),
          const SizedBox(height: 22),
          Wrap(
            spacing: 20,
            runSpacing: 20,
            children: [
              for (final style in InvitationStyle.values)
                SizedBox(
                  width: width,
                  child: MotionReveal(
                    delay: Duration(milliseconds: style.index * 90),
                    child: HoverLift(
                      child: _TemplateCard(
                        style: style,
                        onPreview: () => onPreview(style),
                        onChoose: () => onChoose(style),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      );
    },
  );
}

class _TemplateCard extends StatelessWidget {
  const _TemplateCard({
    required this.style,
    required this.onPreview,
    required this.onChoose,
  });
  final InvitationStyle style;
  final VoidCallback onPreview;
  final VoidCallback onChoose;

  @override
  Widget build(BuildContext context) => Material(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
      side: const BorderSide(color: outline),
    ),
    clipBehavior: Clip.antiAlias,
    color: surface,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          button: true,
          label: 'معاينة ${style.title}',
          excludeSemantics: true,
          onTap: onPreview,
          child: Stack(
            children: [
              InvitationCover(
                invitation: Invitation.example(style),
                thumbnail: true,
              ),
              Positioned.fill(
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(onTap: onPreview),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(15, 12, 15, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(child: Text(style.title, style: displayStyle(27))),
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: style.swatch,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 3),
              Text(
                style.description,
                style: const TextStyle(color: muted, fontSize: 12),
              ),
              const SizedBox(height: 10),
              const Divider(height: 1, color: outline),
              const SizedBox(height: 5),
              Wrap(
                spacing: 2,
                runSpacing: 3,
                alignment: WrapAlignment.spaceBetween,
                children: [
                  TextButton.icon(
                    onPressed: onPreview,
                    icon: const Icon(Icons.visibility_outlined, size: 16),
                    label: const Text('معاينة'),
                  ),
                  TextButton.icon(
                    onPressed: onChoose,
                    icon: const Icon(Icons.arrow_back_rounded, size: 16),
                    label: const Text('استخدم التصميم'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _SavedDrafts extends StatelessWidget {
  const _SavedDrafts({required this.drafts, required this.onCreate});
  final Drafts drafts;
  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('دعواتي')),
    body: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 750),
        child: ListenableBuilder(
          listenable: drafts,
          builder: (context, _) {
            final items = drafts.items;
            return ListView(
              padding: const EdgeInsets.all(24),
              children: [
                const Text(
                  'المسودات المحفوظة على هذا المتصفح',
                  style: TextStyle(color: muted),
                ),
                const SizedBox(height: 18),
                if (items.isEmpty)
                  Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: FilledButton(
                      onPressed: onCreate,
                      child: const Text('اختيار تصميم'),
                    ),
                  ),
                for (final draft in items)
                  Card(
                    color: surface,
                    child: ListTile(
                      leading: Seal(color: draft.invitation.style.accent),
                      title: Text(draft.invitation.couple),
                      subtitle: Text(
                        '${draft.invitation.style.title} · ${jordanDate(draft.invitation.date)}',
                      ),
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => Editor(
                            drafts: drafts,
                            initial: draft.invitation,
                            draftId: draft.id,
                          ),
                        ),
                      ),
                      trailing: IconButton(
                        tooltip: 'حذف المسودة',
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () => _delete(context, draft),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    ),
  );

  Future<void> _delete(BuildContext context, Draft draft) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialog) => AlertDialog(
        title: const Text('حذف المسودة؟'),
        content: Text(draft.invitation.couple),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialog),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialog, true),
            child: const Text('حذف'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    try {
      await drafts.remove(draft);
    } on Exception {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('تعذّر حفظ التغيير.')));
      }
    }
  }
}
