import 'dart:convert';

import 'package:flutter/widgets.dart';

enum InvitationStyle {
  olive(
    'olive',
    'غصن زيتون',
    'عاجي دافئ وأغصان زيتون',
    Color(0xFFF4EDDA),
    Color(0xFF26382A),
    Color(0xFF506247),
    Color(0xFFD6DCC8),
  ),
  night(
    'night',
    'ليلة مخملية',
    'أخضر مخملي وتفاصيل ذهبية',
    Color(0xFF172A23),
    Color(0xFFF4E8CE),
    Color(0xFFE2C490),
    Color(0xFFBDA36F),
  ),
  rose(
    'rose',
    'ورد الجوري',
    'وردي هادئ وورد الجوري',
    Color(0xFFF1DFDC),
    Color(0xFF53332D),
    Color(0xFF884D53),
    Color(0xFFE5BFC1),
  ),
  jasmine(
    'jasmine',
    'مساء الياسمين',
    'أزهار بيضاء ومدخل حجري عند الغروب',
    Color(0xFFF6F4EF),
    Color(0xFF243047),
    Color(0xFF405775),
    Color(0xFFC9D4E1),
    photoCover: true,
  ),
  candlelight(
    'candlelight',
    'على ضوء الشموع',
    'فوانيس ذهبية وأزهار عاجية',
    Color(0xFFFAF2E8),
    Color(0xFF442E24),
    Color(0xFF815838),
    Color(0xFFE5C5A5),
    photoCover: true,
  ),
  ivoryArches(
    'ivory-arches',
    'أقواس عاجية',
    'طبقات ورق عاجية بتصميم معماري',
    Color(0xFFFAF3E5),
    Color(0xFF372B23),
    Color(0xFF7D5635),
    Color(0xFFE4CFAD),
    modernCover: true,
  ),
  burgundySatin(
    'burgundy-satin',
    'حرير خمري',
    'حرير خمري ولمسات وردية دافئة',
    Color(0xFFFFF1EF),
    Color(0xFF431620),
    Color(0xFF84374E),
    Color(0xFFE0A9B5),
    modernCover: true,
  ),
  mistBlue(
    'mist-blue',
    'ضوء أزرق',
    'أزرق ضبابي وظلال أغصان ناعمة',
    Color(0xFFEAF3F9),
    Color(0xFF203B56),
    Color(0xFF385C7F),
    Color(0xFFB9D1E2),
    modernCover: true,
  ),
  pearlLace(
    'pearl-lace',
    'لؤلؤ ودانتيل',
    'بوابة لؤلؤية وستائر عاجية مضيئة',
    Color(0xFFF8EEE4),
    Color(0xFF563C32),
    Color(0xFF886750),
    Color(0xFFDCC6AC),
    ceremony: true,
  ),
  champagneRose(
    'champagne-rose',
    'ورد الشامبانيا',
    'ورود ناعمة وأقواس بلون الشامبانيا',
    Color(0xFFFAEFEC),
    Color(0xFF623F42),
    Color(0xFF976870),
    Color(0xFFE2C4C8),
    ceremony: true,
  ),
  sageGarden(
    'sage-garden',
    'حديقة المريمية',
    'ياسمين أبيض وستائر خضراء هادئة',
    Color(0xFFF0F3EB),
    Color(0xFF354A3D),
    Color(0xFF60745E),
    Color(0xFFCDD8C4),
    ceremony: true,
  );

  const InvitationStyle(
    this.slug,
    this.title,
    this.description,
    this.paper,
    this.ink,
    this.accent,
    this.swatch, {
    this.photoCover = false,
    this.modernCover = false,
    this.ceremony = false,
  });

  final String slug;
  final String title;
  final String description;
  final Color paper;
  final Color ink;
  final Color accent;
  final Color swatch;
  final bool photoCover;
  final bool modernCover;
  final bool ceremony;

  String get collection => ceremony
      ? 'مجموعة المراسم'
      : modernCover
      ? 'المجموعة المودرن'
      : 'المجموعة الكلاسيكية';

  String get artwork => 'assets/images/$slug.webp';
  String get doorsArtwork => 'assets/images/$slug-doors.webp';

  static InvitationStyle fromSlug(Object? slug) =>
      values.firstWhere((style) => style.slug == slug, orElse: () => olive);
}

enum InvitationMusic {
  softKeys('soft-keys', 'بيانو هادئ'),
  warmStrings('warm-strings', 'أوتار دافئة');

  const InvitationMusic(this.id, this.title);

  final String id;
  final String title;

  static InvitationMusic? fromId(Object? id) {
    for (final track in values) {
      if (track.id == id) return track;
    }
    return null;
  }
}

class Invitation {
  const Invitation({
    required this.style,
    required this.groom,
    required this.bride,
    this.groomFather = '',
    this.groomMother = '',
    this.brideFather = '',
    this.brideMother = '',
    required this.date,
    required this.venue,
    required this.city,
    this.mapLink = '',
    this.message = '',
    this.music,
    this.address = '',
    this.endDate,
    this.rsvpPhone = '',
    this.venueImageUrl = '',
    this.groomFamily = '',
    this.brideFamily = '',
  });

  final InvitationStyle style;
  final String groom;
  final String bride;
  final String groomFather;
  final String groomMother;
  final String brideFather;
  final String brideMother;
  // UTC-shaped calendar fields representing wall time in Jordan.
  final DateTime date;
  final String venue;
  final String city;
  final String mapLink;
  final String message;
  final InvitationMusic? music;
  final String address;
  final DateTime? endDate;
  final String rsvpPhone;
  final String venueImageUrl;
  final String groomFamily;
  final String brideFamily;

  bool get hasHostingFamilies =>
      groomFamily.isNotEmpty || brideFamily.isNotEmpty;

  static String normalizeRsvpPhone(String value) {
    var phone = westernDigits(value.trim()).replaceAll(RegExp(r'[\s()+-]'), '');
    if (phone.startsWith('00')) phone = phone.substring(2);
    if (RegExp(r'^07[789][0-9]{7}$').hasMatch(phone)) {
      phone = '962${phone.substring(1)}';
    }
    return RegExp(r'^[1-9][0-9]{7,14}$').hasMatch(phone) ? phone : '';
  }

  Uri rsvpUri({
    required String name,
    required bool attending,
    required int guests,
    String note = '',
  }) {
    final phone = normalizeRsvpPhone(rsvpPhone);
    if (phone.isEmpty) throw StateError('No RSVP phone configured');
    if (name.trim().isEmpty || guests < 1 || guests > 20) {
      throw ArgumentError('Invalid RSVP details');
    }
    return Uri.https('wa.me', '/$phone', {
      'text': [
        'رد على دعوة زفاف $couple',
        'الاسم: ${name.trim()}',
        attending ? 'نتشرف بالحضور' : 'نعتذر عن الحضور',
        if (attending) 'عدد الضيوف: $guests',
        if (note.trim().isNotEmpty) 'رسالة للعروسين: ${note.trim()}',
      ].join('\n'),
    });
  }

  static const jordanOffset = Duration(hours: 3);
  DateTime get instant => date.subtract(jordanOffset);
  String get couple => '$groom و$bride';
  String get location =>
      [venue, city].where((value) => value.isNotEmpty).join('، ');
  String get timeLabel {
    final end = endDate;
    if (end == null) return jordanTime(date);
    return 'من ${jordanTime(date)} إلى ${jordanTime(end)}'
        '${end.day != date.day ? ' في اليوم التالي' : ''}';
  }

  bool get hasFamilies => [
    groomFather,
    groomMother,
    brideFather,
    brideMother,
  ].any((name) => name.isNotEmpty);

  static DateTime jordanNow() => DateTime.now().toUtc().add(jordanOffset);

  static Invitation example(InvitationStyle style, {DateTime? now}) {
    final upcoming = (now ?? jordanNow()).add(const Duration(days: 45));
    return Invitation(
      style: style,
      groom: 'عمر',
      bride: 'ليان',
      groomFather: 'خالد العبدالله',
      groomMother: 'منى الحسن',
      brideFather: 'أحمد النجار',
      brideMother: 'هناء الخطيب',
      groomFamily: 'آل العبدالله',
      brideFamily: 'آل النجار',
      date: DateTime.utc(upcoming.year, upcoming.month, upcoming.day, 19),
      venue: 'قاعة الياسمين',
      city: 'عمّان',
      message: 'بحضوركم تكتمل فرحتنا',
    );
  }

  static Invitation empty(InvitationStyle style) {
    final upcoming = jordanNow().add(const Duration(days: 30));
    return Invitation(
      style: style,
      groom: '',
      bride: '',
      date: DateTime.utc(upcoming.year, upcoming.month, upcoming.day, 19),
      venue: '',
      city: 'عمّان',
    );
  }

  Map<String, Object> toJson() => {
    'v': 1,
    'style': style.slug,
    'groom': groom,
    'bride': bride,
    'groomFather': groomFather,
    'groomMother': groomMother,
    'brideFather': brideFather,
    'brideMother': brideMother,
    'date': date.toIso8601String(),
    'venue': venue,
    'city': city,
    'mapLink': mapLink,
    'message': message,
    if (music case final track?) 'music': track.id,
    if (address.isNotEmpty) 'address': address,
    if (endDate case final end?) 'endDate': end.toIso8601String(),
    if (rsvpPhone.isNotEmpty) 'rsvpPhone': rsvpPhone,
    if (venueImageUrl.isNotEmpty) 'venueImageUrl': venueImageUrl,
    if (groomFamily.isNotEmpty) 'groomFamily': groomFamily,
    if (brideFamily.isNotEmpty) 'brideFamily': brideFamily,
  };

  static Invitation? fromJson(Object? source) {
    if (source is! Map<String, dynamic> || source['v'] != 1) return null;
    String read(String key, {int limit = 120}) {
      final value = source[key];
      return value is String && value.characters.length <= limit ? value : '';
    }

    final date = DateTime.tryParse(read('date'));
    if (date == null || !date.isUtc) return null;
    final parsedEnd = DateTime.tryParse(read('endDate', limit: 40));
    return Invitation(
      style: InvitationStyle.fromSlug(source['style']),
      groom: read('groom'),
      bride: read('bride'),
      groomFather: read('groomFather'),
      groomMother: read('groomMother'),
      brideFather: read('brideFather'),
      brideMother: read('brideMother'),
      date: date,
      venue: read('venue'),
      city: read('city'),
      mapLink: read('mapLink', limit: 500),
      message: read('message', limit: 280),
      music: InvitationMusic.fromId(source['music']),
      address: read('address', limit: 240),
      endDate: parsedEnd != null && parsedEnd.isUtc && parsedEnd.isAfter(date)
          ? parsedEnd
          : null,
      rsvpPhone: normalizeRsvpPhone(read('rsvpPhone', limit: 40)),
      venueImageUrl: read('venueImageUrl', limit: 500),
      groomFamily: read('groomFamily'),
      brideFamily: read('brideFamily'),
    );
  }

  static const linkPrefix = '/i/';

  Uri shareUri(Uri origin) {
    final encoded = base64Url
        .encode(utf8.encode(jsonEncode(toJson())))
        .replaceAll('=', '');
    return Uri(
      scheme: origin.scheme,
      host: origin.host,
      port: origin.hasPort ? origin.port : null,
      path: origin.path,
      fragment: '$linkPrefix$encoded',
    );
  }

  static Invitation? fromLink(Uri uri) {
    if (!uri.fragment.startsWith(linkPrefix) || uri.fragment.length > 20000) {
      return null;
    }
    try {
      final payload = uri.fragment.substring(linkPrefix.length);
      return fromJson(
        jsonDecode(utf8.decode(base64Url.decode(base64Url.normalize(payload)))),
      );
    } on FormatException {
      return null;
    }
  }

  Uri? get mapUri {
    final custom = Uri.tryParse(mapLink);
    if (custom != null && custom.scheme == 'https' && custom.host.isNotEmpty) {
      return custom;
    }
    if (location.isEmpty) return null;
    return Uri.https('www.google.com', '/maps/search/', {
      'api': '1',
      'query': [
        location,
        address,
        'الأردن',
      ].where((part) => part.isNotEmpty).join('، '),
    });
  }
}

const _months = [
  'كانون الثاني',
  'شباط',
  'آذار',
  'نيسان',
  'أيار',
  'حزيران',
  'تموز',
  'آب',
  'أيلول',
  'تشرين الأول',
  'تشرين الثاني',
  'كانون الأول',
];

const _weekdays = [
  'الإثنين',
  'الثلاثاء',
  'الأربعاء',
  'الخميس',
  'الجمعة',
  'السبت',
  'الأحد',
];

String arabicDigits(Object value) {
  const digits = '٠١٢٣٤٥٦٧٨٩';
  return value.toString().replaceAllMapped(
    RegExp('[0-9]'),
    (match) => digits[int.parse(match[0]!)],
  );
}

String westernDigits(String value) {
  const eastern = '٠١٢٣٤٥٦٧٨٩';
  const persian = '۰۱۲۳۴۵۶۷۸۹';
  return value.replaceAllMapped(RegExp('[٠-٩۰-۹]'), (match) {
    final digit = match[0]!;
    final index = eastern.indexOf(digit);
    return (index < 0 ? persian.indexOf(digit) : index).toString();
  });
}

String jordanDate(DateTime date, {bool includeDay = true}) =>
    '${includeDay ? '${_weekdays[date.weekday - 1]}، ' : ''}'
    '${arabicDigits(date.day)} ${_months[date.month - 1]} ${arabicDigits(date.year)}';

String jordanTime(DateTime date) {
  final hour = (date.hour + 11) % 12 + 1;
  final minute = date.minute.toString().padLeft(2, '0');
  return '${arabicDigits('$hour:$minute')} ${date.hour < 12 ? 'صباحًا' : 'مساءً'}';
}
