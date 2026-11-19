import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:wedding_project/ceremony_invitation.dart';
import 'package:wedding_project/drafts.dart';
import 'package:wedding_project/editor.dart';
import 'package:wedding_project/invitation.dart';
import 'package:wedding_project/invitation_rsvp.dart';
import 'package:wedding_project/invitation_view.dart';
import 'package:wedding_project/main.dart';
import 'package:wedding_project/studio_theme.dart';

Invitation sample(InvitationStyle style) => Invitation(
  style: style,
  groom: 'عمر',
  bride: 'ليان',
  date: DateTime.utc(2027, 12, 31, 21, 30),
  endDate: DateTime.utc(2028, 1, 1, 1),
  venue: 'قاعة الياسمين',
  city: 'عمّان',
  address: 'شارع الحرية',
  rsvpPhone: '962791234567',
);

void main() {
  testWidgets('ceremony thumbnails fill the available card width', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 600,
              child: Stack(
                children: [
                  CeremonyCover(
                    invitation: sample(InvitationStyle.pearlLace),
                    thumbnail: true,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.getSize(find.byType(CeremonyCover)).width, 600);
    final background = find.descendant(
      of: find.byType(CeremonyCover),
      matching: find.byType(Image),
    );
    expect(tester.getSize(background).width, 600);
    expect(tester.takeException(), isNull);
  });

  test('ceremony details survive drafts and both invitation formats', () {
    for (final style in InvitationStyle.values.where(
      (style) => style.ceremony,
    )) {
      final invitation = sample(style);
      final saved = invitation.toJson();
      expect(Invitation.fromJson(saved)!.toJson(), saved);
      expect(
        Invitation.fromLink(
          invitation.shareUri(Uri.parse('https://example.com/')),
        )!.toJson(),
        saved,
      );
      expect(invitation.timeLabel, contains('في اليوم التالي'));
      expect(
        invitation.mapUri!.queryParameters['query'],
        contains('شارع الحرية'),
      );
    }
    final legacy = Invitation.example(InvitationStyle.olive).toJson();
    final restored = Invitation.fromJson(legacy)!;
    expect(restored.address, isEmpty);
    expect(restored.rsvpPhone, isEmpty);
    expect(restored.endDate, isNull);
    expect(restored.toJson(), legacy);
    expect(
      Invitation.fromJson({...legacy, 'endDate': 'invalid'})!.endDate,
      isNull,
    );
  });

  test(
    'hosting families survive serialization and old links stay optional',
    () {
      final old = sample(InvitationStyle.pearlLace).toJson();
      expect(Invitation.fromJson(old)!.hasHostingFamilies, isFalse);
      for (final families in [
        {'groomFamily': 'آل العبدالله', 'brideFamily': 'آل النجار'},
        {'groomFamily': 'آل العبدالله'},
        {'brideFamily': 'آل النجار'},
      ]) {
        final stored = {...old, ...families};
        final invitation = Invitation.fromJson(stored)!;
        expect(invitation.hasHostingFamilies, isTrue);
        expect(invitation.toJson(), stored);
        expect(
          Invitation.fromLink(
            invitation.shareUri(Uri.parse('https://example.com/')),
          )!.toJson(),
          stored,
        );
      }
    },
  );

  testWidgets('family names lead every invitation cover', (tester) async {
    tester.view.physicalSize = const Size(390, 1100);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    for (final style in InvitationStyle.values) {
      final invitation = Invitation.example(style);
      await tester.pumpWidget(
        MaterialApp(
          theme: studioTheme(),
          home: Scaffold(
            body: SingleChildScrollView(
              child: InvitationCover(invitation: invitation),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final family = find.text('آل العبدالله وآل النجار');
      expect(family, findsOneWidget);
      expect(
        tester.getTopLeft(family).dy,
        lessThan(tester.getTopLeft(find.text('عمر')).dy),
      );
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    }
  });

  test(
    'RSVP normalizes numbers and formats attendance and decline messages',
    () {
      expect(westernDigits('١۲3'), '123');
      for (final input in [
        '079 123 4567',
        '+962 (79) 123-4567',
        '00962791234567',
        '٠٧٩١٢٣٤٥٦٧',
      ]) {
        expect(Invitation.normalizeRsvpPhone(input), '962791234567');
      }
      expect(Invitation.normalizeRsvpPhone('07912'), isEmpty);
      expect(Invitation.normalizeRsvpPhone('https://example.com'), isEmpty);
      final invitation = sample(InvitationStyle.pearlLace);
      final response = invitation.rsvpUri(
        name: ' لانا ',
        attending: true,
        guests: 3,
        note: 'ألف مبروك & فرحتنا كبيرة',
      );
      expect(response.host, 'wa.me');
      expect(response.path, '/962791234567');
      expect(response.queryParameters['text'], contains('الاسم: لانا'));
      expect(response.queryParameters['text'], contains('عدد الضيوف: 3'));
      expect(
        response.queryParameters['text'],
        contains('ألف مبروك & فرحتنا كبيرة'),
      );
      final declined = invitation.rsvpUri(
        name: 'لانا',
        attending: false,
        guests: 1,
      );
      expect(declined.queryParameters['text'], contains('نعتذر عن الحضور'));
      expect(declined.queryParameters['text'], isNot(contains('عدد الضيوف')));
    },
  );

  testWidgets('all ceremony doors open and preserve narrow-phone details', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 780);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    for (final style in InvitationStyle.values.where(
      (style) => style.ceremony,
    )) {
      await tester.pumpWidget(
        WisalApp(drafts: Drafts(), invitation: sample(style)),
      );
      await tester.pumpAndSettle();
      expect(find.text('افتحوا الدعوة'), findsOneWidget);
      await tester.tap(find.text('افتحوا الدعوة'));
      await tester.pumpAndSettle();
      expect(find.text('افتحوا الدعوة'), findsNothing);
      expect(find.byType(CeremonyCover), findsOneWidget);
      expect(find.byType(InvitationRsvp), findsOneWidget);
      await tester.tap(find.text('تفاصيل يومنا'));
      await tester.pumpAndSettle();
      expect(
        tester
            .state<ScrollableState>(find.byType(Scrollable).first)
            .position
            .pixels,
        greaterThan(780),
      );
      expect(find.text('شارع الحرية'), findsNWidgets(2));
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    }
  });

  testWidgets(
    'RSVP validates required fields and hides guest count for decline',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: studioTheme(),
          home: Scaffold(
            body: SingleChildScrollView(
              child: InvitationRsvp(
                invitation: sample(InvitationStyle.pearlLace),
              ),
            ),
          ),
        ),
      );
      final send = find.text('تأكيد الرد عبر واتساب');
      await tester.ensureVisible(send);
      await tester.tap(send);
      await tester.pumpAndSettle();
      expect(find.text('أضيفوا الاسم الكامل'), findsOneWidget);
      await tester.enterText(find.byType(TextFormField).at(1), '0');
      await tester.ensureVisible(send);
      await tester.tap(send);
      await tester.pumpAndSettle();
      expect(find.text('أدخلوا عددًا من ١ إلى ٢٠'), findsOneWidget);
      await tester.enterText(find.byType(TextFormField).at(1), '٣');
      expect(
        tester
            .widget<TextFormField>(find.byType(TextFormField).at(1))
            .controller!
            .text,
        '3',
      );
      final decline = find.text('نعتذر عن الحضور');
      await tester.ensureVisible(decline);
      await tester.tap(decline);
      await tester.pumpAndSettle();
      expect(find.byType(TextFormField), findsNWidgets(2));
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('editor preview preserves new details across template changes', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1280, 950);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(
        theme: studioTheme(),
        home: Editor(
          drafts: Drafts(),
          initial: sample(InvitationStyle.pearlLace),
        ),
      ),
    );
    await tester.pumpAndSettle();
    final choice = find.widgetWithText(ChoiceChip, 'ورد الشامبانيا');
    await tester.ensureVisible(choice);
    await tester.tap(choice);
    await tester.pumpAndSettle();
    await tester.tap(find.text('معاينة كضيف'));
    await tester.pumpAndSettle();
    final guest = tester.widget<GuestPage>(find.byType(GuestPage));
    expect(guest.invitation.style, InvitationStyle.champagneRose);
    expect(guest.invitation.address, 'شارع الحرية');
    expect(guest.invitation.rsvpPhone, '962791234567');
    expect(guest.invitation.endDate, DateTime.utc(2028, 1, 1, 1));
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('doors respect reduced-motion preference', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(disableAnimations: true),
          child: Scaffold(
            body: CeremonyOpening(
              style: InvitationStyle.pearlLace,
              child: const Center(child: Text('الدعوة')),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('افتحوا الدعوة'));
    await tester.pump();
    expect(find.text('افتحوا الدعوة'), findsNothing);
  });
}
