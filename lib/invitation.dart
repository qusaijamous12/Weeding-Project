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
  });

  final String slug;
  final String title;
  final String description;
  final Color paper;
  final Color ink;
  final Color accent;
  final Color swatch;
  final bool photoCover;

  String get artwork => 'assets/images/$slug.webp';

  static InvitationStyle fromSlug(Object? slug) =>
      values.firstWhere((style) => style.slug == slug, orElse: () => olive);
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

  static const jordanOffset = Duration(hours: 3);
  DateTime get instant => date.subtract(jordanOffset);
  String get couple => '$groom و$bride';
  String get location =>
      [venue, city].where((value) => value.isNotEmpty).join('، ');
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
  };

  static Invitation? fromJson(Object? source) {
    if (source is! Map<String, dynamic> || source['v'] != 1) return null;
    String read(String key, {int limit = 120}) {
      final value = source[key];
      return value is String && value.characters.length <= limit ? value : '';
    }

    final date = DateTime.tryParse(read('date'));
    if (date == null || !date.isUtc) return null;
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
      'query': '$location، الأردن',
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

String jordanDate(DateTime date, {bool includeDay = true}) =>
    '${includeDay ? '${_weekdays[date.weekday - 1]}، ' : ''}'
    '${arabicDigits(date.day)} ${_months[date.month - 1]} ${arabicDigits(date.year)}';

String jordanTime(DateTime date) {
  final hour = (date.hour + 11) % 12 + 1;
  final minute = date.minute.toString().padLeft(2, '0');
  return '${arabicDigits('$hour:$minute')} ${date.hour < 12 ? 'صباحًا' : 'مساءً'}';
}
