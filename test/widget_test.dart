import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:wedding_project/drafts.dart';
import 'package:wedding_project/invitation.dart';
import 'package:wedding_project/invitation_view.dart';
import 'package:wedding_project/main.dart';
import 'package:wedding_project/motion.dart';

void main() {
  testWidgets('sections reveal on scroll and honor reduced motion', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: 1200),
                MotionReveal(child: Text('Scroll reveal')),
                SizedBox(height: 200),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    final text = find.text('Scroll reveal');
    final opacity = find
        .ancestor(of: text, matching: find.byType(Opacity))
        .first;
    expect(tester.widget<Opacity>(opacity).opacity, 0);
    await tester.ensureVisible(text);
    await tester.pumpAndSettle();
    expect(tester.widget<Opacity>(opacity).opacity, 1);

    await tester.pumpWidget(
      const MaterialApp(
        home: MediaQuery(
          data: MediaQueryData(disableAnimations: true),
          child: MotionReveal(
            delay: Duration(milliseconds: 300),
            child: Text('Reduced motion'),
          ),
        ),
      ),
    );
    final reduced = find
        .ancestor(
          of: find.text('Reduced motion'),
          matching: find.byType(Opacity),
        )
        .first;
    expect(tester.widget<Opacity>(reduced).opacity, 1);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('the studio requires a session and sign-out locks it again', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1280, 950);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final sessions = StreamController<String?>(sync: true);
    addTearDown(sessions.close);
    await tester.pumpWidget(
      AuthGate(
        sessions: sessions.stream,
        onSignIn: (email, password) async {
          expect(email, 'guest@example.com');
          expect(password, 'test-password');
          sessions.add('guest');
        },
        onSignOut: () async => sessions.add(null),
        onRetry: () {},
        content: (signOut) => WisalApp(drafts: Drafts(), onSignOut: signOut),
      ),
    );
    expect(find.text('معرض التصاميم'), findsNothing);
    sessions.add(null);
    await tester.pumpAndSettle();
    expect(find.text('تسجيل الدخول'), findsOneWidget);
    expect(find.text('معرض التصاميم'), findsNothing);

    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'guest@example.com');
    await tester.enterText(fields.at(1), 'test-password');
    await tester.tap(find.text('دخول'));
    await tester.pumpAndSettle();
    expect(find.text('معرض التصاميم'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.logout_rounded));
    await tester.pumpAndSettle();
    expect(find.text('تسجيل الدخول'), findsOneWidget);
    expect(find.text('معرض التصاميم'), findsNothing);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  test('guest link preserves Arabic details, location and Jordan time', () {
    const map = 'https://maps.app.goo.gl/test';
    final invite = Invitation(
      style: InvitationStyle.rose,
      groom: 'عمر',
      bride: 'ليان',
      groomFather: 'خالد',
      brideMother: 'هناء',
      date: DateTime.utc(2027, 9, 17, 19, 15),
      venue: 'قاعة الياسمين',
      city: 'عمّان',
      mapLink: map,
    );
    final link = invite.shareUri(
      Uri.parse('https://example.com/wisal/?ref=studio'),
    );
    expect(link.path, '/wisal/');
    expect(link.hasQuery, isFalse);
    final restored = Invitation.fromLink(Uri.parse(link.toString()))!;
    expect(restored.toJson(), invite.toJson());
    expect(restored.instant, DateTime.utc(2027, 9, 17, 16, 15));
    expect(restored.mapUri.toString(), map);
    expect(
      Invitation.fromLink(Uri.parse('https://example.com/#/i/bad')),
      isNull,
    );
  });

  test('invitation music is optional and survives serialization', () {
    final original = Invitation.example(InvitationStyle.jasmine).toJson();
    expect(original.containsKey('music'), isFalse);
    expect(Invitation.fromJson(original)!.music, isNull);

    for (final track in InvitationMusic.values) {
      final saved = {...original, 'music': track.id};
      final invitation = Invitation.fromJson(saved)!;
      expect(invitation.music, track);
      expect(invitation.toJson(), saved);
      expect(
        Invitation.fromLink(
          invitation.shareUri(Uri.parse('https://example.com/')),
        )!.music,
        track,
      );
    }

    expect(
      Invitation.fromJson({...original, 'music': 'unknown'})!.music,
      isNull,
    );
  });

  testWidgets('gallery opens a reusable design and updates the guest preview', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1280, 950);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(WisalApp(drafts: Drafts()));
    await tester.pumpAndSettle();
    expect(find.text('معرض التصاميم'), findsOneWidget);
    for (final style in InvitationStyle.values) {
      expect(find.text(style.title), findsOneWidget);
    }

    final choose = find.text('استخدم التصميم').at(1);
    await tester.ensureVisible(choose);
    await tester.tap(choose);
    await tester.pumpAndSettle();
    expect(find.text('تحرير الدعوة'), findsOneWidget);
    expect(find.widgetWithText(ChoiceChip, 'ليلة مخملية'), findsOneWidget);

    final inputs = find.byType(TextFormField);
    await tester.enterText(inputs.first, 'يزن');
    await tester.enterText(inputs.at(1), 'سارة');
    await tester.tap(find.widgetWithText(ChoiceChip, 'ورد الجوري'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('معاينة كضيف'));
    await tester.pumpAndSettle();
    expect(find.text('يزن'), findsOneWidget);
    expect(find.text('سارة'), findsOneWidget);
    final cover = tester.widget<InvitationCover>(find.byType(InvitationCover));
    expect(cover.invitation.style, InvitationStyle.rose);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets(
    'photo templates fill the mobile viewport and link to event cards',
    (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      for (final style in [
        InvitationStyle.jasmine,
        InvitationStyle.candlelight,
      ]) {
        final invitation = Invitation.example(style);
        await tester.pumpWidget(
          WisalApp(drafts: Drafts(), invitation: invitation),
        );
        await tester.pumpAndSettle();
        expect(tester.getSize(find.byType(InvitationCover)).height, 844);
        expect(find.text('الوقت المتبقي للزفاف'), findsOneWidget);
        expect(find.text('التاريخ'), findsOneWidget);
        expect(find.text('وقت الحفل'), findsOneWidget);

        await tester.tap(find.widgetWithText(TextButton, 'تفاصيل الحفل'));
        await tester.pumpAndSettle();
        expect(
          tester
              .state<ScrollableState>(find.byType(Scrollable).first)
              .position
              .pixels,
          greaterThan(844),
        );
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox.shrink());
      }
    },
  );

  testWidgets('guest invitation lays out on a narrow phone', (tester) async {
    tester.view.physicalSize = const Size(360, 780);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final invitation = Invitation.example(InvitationStyle.night);
    await tester.pumpWidget(WisalApp(drafts: Drafts(), invitation: invitation));
    await tester.pumpAndSettle();

    expect(find.text('عمر'), findsOneWidget);
    expect(find.text('أهل العروسين'), findsOneWidget);
    expect(find.text('موعد الزفاف'), findsOneWidget);
    expect(find.text('مكان الحفل'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('modern designs survive sharing and render on a narrow phone', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 780);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    for (final style in InvitationStyle.values.where(
      (style) => style.modernCover,
    )) {
      final sample = Invitation.example(style);
      final restored = Invitation.fromLink(
        sample.shareUri(Uri.parse('https://example.com/')),
      )!;
      expect(restored.style, style);
      await tester.pumpWidget(WisalApp(drafts: Drafts(), invitation: restored));
      await tester.pumpAndSettle();
      expect(find.text('عمر'), findsOneWidget);
      expect(find.text('ليان'), findsOneWidget);
      expect(find.text('تفاصيل الحفل'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    }
  });
}
