import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:url_launcher/url_launcher.dart';

import 'drafts.dart';
import 'invitation.dart';
import 'invitation_view.dart';
import 'shared_invitation.dart';
import 'studio_theme.dart';

enum _Field {
  groom('اسم العريس', requiredForSharing: true),
  bride('اسم العروس', requiredForSharing: true),
  groomFamily('اسم عائلة العريس'),
  brideFamily('اسم عائلة العروس'),
  groomFather('اسم والد العريس'),
  groomMother('اسم والدة العريس'),
  brideFather('اسم والد العروس'),
  brideMother('اسم والدة العروس'),
  venue('اسم القاعة', requiredForSharing: true),
  city('المدينة', requiredForSharing: true),
  mapLink('رابط الموقع على الخريطة', limit: 500),
  address('العنوان التفصيلي · اختياري', limit: 240),
  venueImageUrl('رابط صورة القاعة · اختياري', limit: 500),
  rsvpPhone('رقم واتساب لاستقبال ردود الحضور · اختياري', limit: 40),
  message('كلمة ختامية', limit: 280);

  const _Field(this.label, {this.limit = 120, this.requiredForSharing = false});
  final String label;
  final int limit;
  final bool requiredForSharing;
}

class Editor extends StatefulWidget {
  const Editor({
    super.key,
    required this.drafts,
    required this.initial,
    this.draftId,
  });
  final Drafts drafts;
  final Invitation initial;
  final String? draftId;

  @override
  State<Editor> createState() => _EditorState();
}

class _EditorState extends State<Editor> {
  final _form = GlobalKey<FormState>();
  late final Map<_Field, TextEditingController> _fields;
  late final String _draftId;
  late InvitationStyle _style;
  InvitationMusic? _music;
  late DateTime _date;
  TimeOfDay? _endTime;
  bool _publishing = false;

  @override
  void initState() {
    super.initState();
    final initial = widget.initial;
    _draftId =
        widget.draftId ?? DateTime.now().microsecondsSinceEpoch.toString();
    _style = initial.style;
    _music = initial.music;
    _date = initial.date;
    _endTime = initial.endDate == null
        ? null
        : TimeOfDay.fromDateTime(initial.endDate!);
    _fields = {
      _Field.groom: TextEditingController(text: initial.groom),
      _Field.bride: TextEditingController(text: initial.bride),
      _Field.groomFamily: TextEditingController(text: initial.groomFamily),
      _Field.brideFamily: TextEditingController(text: initial.brideFamily),
      _Field.groomFather: TextEditingController(text: initial.groomFather),
      _Field.groomMother: TextEditingController(text: initial.groomMother),
      _Field.brideFather: TextEditingController(text: initial.brideFather),
      _Field.brideMother: TextEditingController(text: initial.brideMother),
      _Field.venue: TextEditingController(text: initial.venue),
      _Field.city: TextEditingController(text: initial.city),
      _Field.mapLink: TextEditingController(text: initial.mapLink),
      _Field.message: TextEditingController(text: initial.message),
      _Field.address: TextEditingController(text: initial.address),
      _Field.rsvpPhone: TextEditingController(text: initial.rsvpPhone),
      _Field.venueImageUrl: TextEditingController(text: initial.venueImageUrl),
    };
  }

  @override
  void dispose() {
    for (final controller in _fields.values) {
      controller.dispose();
    }
    super.dispose();
  }

  String _value(_Field field) => _fields[field]!.text.trim();

  Invitation get _invitation => Invitation(
    style: _style,
    groom: _value(_Field.groom),
    bride: _value(_Field.bride),
    groomFather: _value(_Field.groomFather),
    groomMother: _value(_Field.groomMother),
    brideFather: _value(_Field.brideFather),
    brideMother: _value(_Field.brideMother),
    venue: _value(_Field.venue),
    city: _value(_Field.city),
    mapLink: _value(_Field.mapLink),
    message: _value(_Field.message),
    music: _music,
    date: _date,
    address: _value(_Field.address),
    rsvpPhone: Invitation.normalizeRsvpPhone(_value(_Field.rsvpPhone)),
    endDate: _endDate,
    venueImageUrl: _value(_Field.venueImageUrl),
    groomFamily: _value(_Field.groomFamily),
    brideFamily: _value(_Field.brideFamily),
  );

  DateTime? get _endDate {
    final time = _endTime;
    if (time == null) return null;
    final end = DateTime.utc(
      _date.year,
      _date.month,
      _date.day,
      time.hour,
      time.minute,
    );
    return end.isAfter(_date) ? end : end.add(const Duration(days: 1));
  }

  Future<void> _pickEndTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime:
          _endTime ??
          TimeOfDay.fromDateTime(_date.add(const Duration(hours: 3))),
    );
    if (picked != null && mounted) setState(() => _endTime = picked);
  }

  Future<void> _pickDate() async {
    final first = DateTime(_date.year < 2000 ? _date.year : 2000);
    final last = DateTime(_date.year > 2100 ? _date.year : 2100, 12, 31);
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(_date.year, _date.month, _date.day),
      firstDate: first,
      lastDate: last,
    );
    if (picked != null && mounted) {
      setState(() {
        _date = DateTime.utc(
          picked.year,
          picked.month,
          picked.day,
          _date.hour,
          _date.minute,
        );
      });
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_date),
    );
    if (picked != null && mounted) {
      setState(() {
        _date = DateTime.utc(
          _date.year,
          _date.month,
          _date.day,
          picked.hour,
          picked.minute,
        );
      });
    }
  }

  void _preview() => Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => GuestPage(invitation: _invitation, preview: true),
    ),
  );

  void _feedback(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _save() async {
    try {
      await widget.drafts.save(Draft(_draftId, _invitation));
      _feedback('تم حفظ المسودة في دعواتي.');
    } on Exception {
      _feedback('تعذّر حفظ المسودة في هذا المتصفح.');
    }
  }

  Future<void> _share() async {
    if (!_form.currentState!.validate()) {
      _feedback('أضيفوا الأسماء والقاعة والمدينة وأصلحوا الحقول المحدّدة.');
      return;
    }
    final invitation = _invitation;
    setState(() => _publishing = true);
    final Uri shareUri;
    try {
      shareUri = await SharedInvitation.publish(invitation, Uri.base);
    } on Exception {
      _feedback('تعذّر إنشاء رابط الدعوة. حاولوا مرة أخرى.');
      return;
    } finally {
      if (mounted) setState(() => _publishing = false);
    }
    if (!mounted) return;
    final link = shareUri.toString();
    final message = 'دعوة زفاف ${invitation.couple}\n$link';
    await showDialog<void>(
      context: context,
      builder: (dialog) => AlertDialog(
        title: const Text('مشاركة الدعوة'),
        content: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 410),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(invitation.couple, style: displayStyle(34)),
              const SizedBox(height: 9),
              const Text(
                'يعرض الرابط هذه النسخة من الدعوة. إذا عدّلتم التفاصيل، شاركوا رابطًا جديدًا.',
              ),
              const SizedBox(height: 9),
              Directionality(
                textDirection: TextDirection.ltr,
                child: SelectableText(link),
              ),
              if (Uri.base.host == 'localhost' ||
                  Uri.base.host == '127.0.0.1') ...[
                const SizedBox(height: 8),
                const Text(
                  'انشروا التطبيق على عنوان ويب عام قبل مشاركة الرابط مع الضيوف.',
                  style: TextStyle(color: muted, fontSize: 12),
                ),
              ],
            ],
          ),
        ),
        actions: [
          OutlinedButton.icon(
            onPressed: () async {
              final opened = await launchUrl(
                Uri.https('wa.me', '/', {'text': message}),
                webOnlyWindowName: '_blank',
              );
              if (!opened) _feedback('تعذّر فتح واتساب.');
            },
            icon: const Icon(Icons.chat_bubble_outline, size: 17),
            label: const Text('واتساب'),
          ),
          FilledButton.icon(
            onPressed: () async {
              try {
                await Clipboard.setData(ClipboardData(text: link));
                if (dialog.mounted) Navigator.pop(dialog);
                _feedback('تم نسخ رابط الدعوة.');
              } on Exception {
                _feedback('تعذّر نسخ رابط الدعوة.');
              }
            },
            icon: const Icon(Icons.link_rounded, size: 18),
            label: const Text('نسخ الرابط'),
          ),
        ],
      ),
    );
  }

  Widget _field(_Field field) {
    return TextFormField(
      controller: _fields[field],
      textDirection:
          field == _Field.mapLink ||
              field == _Field.rsvpPhone ||
              field == _Field.venueImageUrl
          ? TextDirection.ltr
          : null,
      keyboardType: field == _Field.rsvpPhone
          ? TextInputType.phone
          : field == _Field.mapLink || field == _Field.venueImageUrl
          ? TextInputType.url
          : TextInputType.text,
      maxLines: field == _Field.message ? 2 : 1,
      inputFormatters: [LengthLimitingTextInputFormatter(field.limit)],
      decoration: InputDecoration(
        labelText: field.label,
        hintText: field == _Field.rsvpPhone
            ? '079 123 4567'
            : field == _Field.mapLink
            ? 'https://maps.app.goo.gl/…'
            : null,
      ),
      onChanged: (_) => setState(() {}),
      validator: (text) {
        final value = text?.trim() ?? '';
        if (field.requiredForSharing && value.isEmpty) {
          return 'هذا الحقل مطلوب للمشاركة';
        }
        if ((field == _Field.mapLink || field == _Field.venueImageUrl) &&
            value.isNotEmpty) {
          final uri = Uri.tryParse(value);
          if (uri == null || uri.scheme != 'https' || uri.host.isEmpty) {
            return 'أدخلوا رابطًا يبدأ بـ https://';
          }
        }
        if (field == _Field.rsvpPhone &&
            value.isNotEmpty &&
            Invitation.normalizeRsvpPhone(value).isEmpty) {
          return 'أدخلوا رقمًا أردنيًا أو رقمًا دوليًا مع رمز الدولة';
        }
        return null;
      },
    );
  }

  Widget _pair(Widget first, Widget second) => LayoutBuilder(
    builder: (context, constraints) {
      if (constraints.maxWidth < 390) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [first, const SizedBox(height: 13), second],
        );
      }
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: first),
          const SizedBox(width: 12),
          Expanded(child: second),
        ],
      );
    },
  );

  Widget _section(String label, List<Widget> fields) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Text(label, style: displayStyle(27)),
      const SizedBox(height: 13),
      for (var index = 0; index < fields.length; index++) ...[
        if (index != 0) const SizedBox(height: 13),
        fields[index],
      ],
      const SizedBox(height: 23),
      const Divider(height: 1, color: outline),
      const SizedBox(height: 23),
    ],
  );

  @override
  Widget build(BuildContext context) {
    final form = Form(
      key: _form,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('تحرير الدعوة', style: displayStyle(51)),
          const SizedBox(height: 18),
          _section('التصميم', [
            Wrap(
              spacing: 8,
              runSpacing: 7,
              children: [
                for (final style in InvitationStyle.values)
                  ChoiceChip(
                    label: Text(style.title),
                    selected: style == _style,
                    avatar: CircleAvatar(
                      backgroundColor: style.swatch,
                      radius: 7,
                    ),
                    onSelected: (_) => setState(() => _style = style),
                  ),
              ],
            ),
          ]),
          if (_style.ceremony)
            Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: Text(
                'مجموعة المراسم · افتحوا «معاينة كضيف» لتجربة فتح البطاقة.',
                style: TextStyle(color: _style.accent, height: 1.7),
              ),
            ),
          _section('أسماء العائلات في بداية الدعوة · اختياري', [
            _pair(_field(_Field.groomFamily), _field(_Field.brideFamily)),
            const Text(
              'اكتبوا الأسماء كما تفضّلون ظهورها، مثل «آل العبدالله» و«آل النجار».',
            ),
          ]),
          _section('أسماء العروسين', [
            _pair(_field(_Field.groom), _field(_Field.bride)),
          ]),
          _section('أسماء الأهل · اختياري', [
            _pair(_field(_Field.groomFather), _field(_Field.groomMother)),
            _pair(_field(_Field.brideFather), _field(_Field.brideMother)),
          ]),
          _section('موعد الزفاف · بتوقيت الأردن', [
            _pair(
              OutlinedButton.icon(
                onPressed: _pickDate,
                icon: const Icon(Icons.calendar_today_outlined, size: 17),
                label: Text(jordanDate(_date, includeDay: false)),
              ),
              OutlinedButton.icon(
                onPressed: _pickTime,
                icon: const Icon(Icons.schedule_rounded, size: 18),
                label: Text(jordanTime(_date)),
              ),
            ),
            Wrap(
              spacing: 8,
              children: [
                OutlinedButton.icon(
                  onPressed: _pickEndTime,
                  icon: const Icon(Icons.more_time_rounded, size: 18),
                  label: Text(
                    _endDate == null
                        ? 'إضافة وقت انتهاء الحفل'
                        : 'ينتهي ${jordanTime(_endDate!)}',
                  ),
                ),
                if (_endTime != null)
                  TextButton(
                    onPressed: () => setState(() => _endTime = null),
                    child: const Text('حذف وقت الانتهاء'),
                  ),
              ],
            ),
            if (_endDate != null && _endDate!.day != _date.day)
              const Text('وقت الانتهاء بعد منتصف الليل في اليوم التالي.'),
          ]),
          _section('مكان الحفل', [
            _pair(_field(_Field.venue), _field(_Field.city)),
            _field(_Field.mapLink),
            _field(_Field.address),
            if (_style.ceremony) _field(_Field.venueImageUrl),
          ]),
          _section('تأكيد الحضور عبر واتساب · اختياري', [
            _field(_Field.rsvpPhone),
            const Text(
              'سيظهر للضيوف نموذج الاسم وعدد الحاضرين والرسالة. يفتح واتساب بردّ جاهز يرسله الضيف إلى هذا الرقم.',
            ),
          ]),
          _section('موسيقى الدعوة · اختياري', [
            Wrap(
              spacing: 8,
              runSpacing: 7,
              children: [
                ChoiceChip(
                  label: const Text('بدون موسيقى'),
                  selected: _music == null,
                  onSelected: (_) => setState(() => _music = null),
                ),
                for (final track in InvitationMusic.values)
                  ChoiceChip(
                    label: Text(track.title),
                    selected: _music == track,
                    onSelected: (_) => setState(() => _music = track),
                  ),
              ],
            ),
            const Text(
              'جرّبوا المقطع في «معاينة كضيف». يبدأ عند فتح الدعوة أو عند أول لمسة إذا منع المتصفح التشغيل التلقائي.',
            ),
          ]),
          _field(_Field.message),
          const SizedBox(height: 24),
          Wrap(
            spacing: 9,
            runSpacing: 9,
            children: [
              FilledButton.icon(
                onPressed: _publishing ? null : _share,
                icon: _publishing
                    ? const SizedBox.square(
                        dimension: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.link_rounded, size: 18),
                label: Text(
                  _publishing ? 'جارٍ إنشاء الرابط…' : 'مشاركة الدعوة',
                ),
              ),
              OutlinedButton.icon(
                onPressed: _save,
                icon: const Icon(Icons.save_outlined, size: 18),
                label: const Text('حفظ المسودة'),
              ),
            ],
          ),
        ],
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text('وِصال', style: displayStyle(32)),
        actions: [
          Padding(
            padding: const EdgeInsetsDirectional.only(end: 14),
            child: TextButton.icon(
              onPressed: _preview,
              icon: const Icon(Icons.visibility_outlined, size: 19),
              label: const Text('معاينة كضيف'),
            ),
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= 900;
          final margin = wide ? 35.0 : 19.0;
          return SingleChildScrollView(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1240),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(margin, 24, margin, 48),
                  child: wide
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: form),
                            const SizedBox(width: 40),
                            Expanded(
                              child: _livePreview(
                                (constraints.maxHeight - 83).clamp(
                                  420.0,
                                  760.0,
                                ),
                              ),
                            ),
                          ],
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            form,
                            const SizedBox(height: 34),
                            _livePreview(null),
                          ],
                        ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _livePreview(double? height) {
    final content = InvitationContent(
      invitation: _invitation,
      interactive: false,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Padding(
          padding: EdgeInsets.only(bottom: 10),
          child: Text(
            'معاينة مباشرة',
            style: TextStyle(color: muted, fontWeight: FontWeight.w600),
          ),
        ),
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: height == null
              ? content
              : SizedBox(
                  height: height,
                  child: SingleChildScrollView(primary: false, child: content),
                ),
        ),
      ],
    );
  }
}
