import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:url_launcher/url_launcher.dart';

import 'invitation.dart';
import 'studio_theme.dart';

class InvitationRsvp extends StatefulWidget {
  const InvitationRsvp({
    super.key,
    required this.invitation,
    this.interactive = true,
  });

  final Invitation invitation;
  final bool interactive;

  @override
  State<InvitationRsvp> createState() => _InvitationRsvpState();
}

class _InvitationRsvpState extends State<InvitationRsvp> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _count = TextEditingController(text: '1');
  final _note = TextEditingController();
  bool _attending = true;
  bool _opening = false;

  @override
  void dispose() {
    _name.dispose();
    _count.dispose();
    _note.dispose();
    super.dispose();
  }

  Future<void> _respond() async {
    if (!_form.currentState!.validate()) return;
    final uri = widget.invitation.rsvpUri(
      name: _name.text,
      attending: _attending,
      guests: _attending ? int.parse(_count.text) : 1,
      note: _note.text,
    );
    setState(() => _opening = true);
    try {
      final opened = await launchUrl(uri, webOnlyWindowName: '_blank');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              opened
                  ? 'فتحنا واتساب برسالتكم. اضغطوا إرسال لتأكيد الرد.'
                  : 'تعذّر فتح واتساب. حاولوا مرة أخرى.',
            ),
          ),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تعذّر فتح واتساب. حاولوا مرة أخرى.')),
        );
      }
    } finally {
      if (mounted) setState(() => _opening = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final style = widget.invitation.style;
    return Theme(
      data: Theme.of(context).copyWith(
        colorScheme: Theme.of(context).colorScheme.copyWith(
          primary: style.ink,
          onPrimary: Colors.white,
          primaryContainer: style.swatch,
          onPrimaryContainer: style.ink,
          onSurface: style.ink,
          outline: style.swatch,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white.withValues(alpha: .7),
          labelStyle: TextStyle(color: style.ink),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: style.swatch),
          ),
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(25),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: .6),
          border: Border.all(color: style.swatch.withValues(alpha: .65)),
          borderRadius: BorderRadius.circular(28),
        ),
        child: Form(
          key: _form,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'بانتظار حضوركم',
                textAlign: TextAlign.center,
                style: displayStyle(34, color: style.ink),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _name,
                enabled: widget.interactive,
                textInputAction: TextInputAction.next,
                inputFormatters: [LengthLimitingTextInputFormatter(120)],
                decoration: const InputDecoration(labelText: 'الاسم الكامل'),
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'أضيفوا الاسم الكامل'
                    : null,
              ),
              const SizedBox(height: 18),
              Text('هل ستحضرون؟', style: displayStyle(24, color: style.ink)),
              const SizedBox(height: 7),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ChoiceChip(
                    label: const Text('نتشرف بالحضور'),
                    selected: _attending,
                    onSelected: widget.interactive
                        ? (_) => setState(() => _attending = true)
                        : null,
                  ),
                  ChoiceChip(
                    label: const Text('نعتذر عن الحضور'),
                    selected: !_attending,
                    onSelected: widget.interactive
                        ? (_) => setState(() => _attending = false)
                        : null,
                  ),
                ],
              ),
              if (_attending) ...[
                const SizedBox(height: 18),
                TextFormField(
                  controller: _count,
                  enabled: widget.interactive,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    TextInputFormatter.withFunction(
                      (oldValue, newValue) =>
                          newValue.copyWith(text: westernDigits(newValue.text)),
                    ),
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(2),
                  ],
                  decoration: const InputDecoration(
                    labelText: 'عدد الضيوف شاملًا صاحب الرد',
                  ),
                  validator: (value) {
                    final count = int.tryParse(value ?? '') ?? 0;
                    return count < 1 || count > 20
                        ? 'أدخلوا عددًا من ١ إلى ٢٠'
                        : null;
                  },
                ),
              ],
              const SizedBox(height: 18),
              TextFormField(
                controller: _note,
                enabled: widget.interactive,
                minLines: 3,
                maxLines: 5,
                inputFormatters: [LengthLimitingTextInputFormatter(280)],
                decoration: const InputDecoration(
                  labelText: 'رسالة للعروسين · اختياري',
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'رح نفتح واتساب برسالة جاهزة. اضغطوا إرسال هناك حتى يصل ردّكم للعروسين.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: style.accent,
                  height: 1.8,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 15),
              FilledButton.icon(
                onPressed: widget.interactive && !_opening ? _respond : null,
                icon: const Icon(Icons.chat_bubble_outline_rounded, size: 18),
                label: Text(
                  _opening ? 'جارٍ فتح واتساب…' : 'تأكيد الرد عبر واتساب',
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: style.ink,
                  foregroundColor: Colors.white,
                  shape: const StadiumBorder(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
