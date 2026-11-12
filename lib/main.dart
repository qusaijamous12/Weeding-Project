import 'dart:async';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'drafts.dart';
import 'firebase_options.dart';
import 'invitation.dart';
import 'invitation_view.dart';
import 'studio.dart';
import 'studio_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  LicenseRegistry.addLicense(() async* {
    for (final font in ['Amiri', 'NotoSansArabic']) {
      yield LicenseEntryWithLineBreaks([
        font,
      ], await rootBundle.loadString('assets/fonts/$font-OFL.txt'));
    }
  });
  final address = Uri.base;
  final invitation = Invitation.fromLink(address);
  final invalidLink =
      address.fragment.startsWith(Invitation.linkPrefix) && invitation == null;
  final drafts = Drafts();
  if (invitation == null && !invalidLink) {
    try {
      await drafts.load();
    } on Exception {
      // The editor and guest links still work if browser storage is disabled.
    }
  }
  runApp(
    WisalApp(drafts: drafts, invitation: invitation, invalidLink: invalidLink),
  );
  // Remote SDK loading must not prevent guests from opening their invitations.
  unawaited(_initializeFirebase());
}

Future<void> _initializeFirebase() async {
  if (!kIsWeb) return;
  try {
    final app = await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    final address = Uri.base;
    final analytics = FirebaseAnalytics.instanceFor(
      app: app,
      webOptions: {
        'config': {
          // Guest URLs and page titles contain personal invitation details.
          'page_location': Uri(
            scheme: address.scheme,
            host: address.host,
            port: address.hasPort ? address.port : null,
            path: address.path,
          ).toString(),
          'page_title': 'وِصال | دعوات الزفاف',
          'page_referrer': '',
        },
      },
    );
    if (await analytics.isSupported()) {
      await analytics.setAnalyticsCollectionEnabled(true);
    }
  } on Exception catch (error) {
    debugPrint('Firebase services unavailable (${error.runtimeType}).');
  }
}

class WisalApp extends StatelessWidget {
  const WisalApp({
    super.key,
    required this.drafts,
    this.invitation,
    this.invalidLink = false,
  });
  final Drafts drafts;
  final Invitation? invitation;
  final bool invalidLink;

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'وِصال | دعوات الزفاف',
    debugShowCheckedModeBanner: false,
    theme: studioTheme(),
    locale: const Locale('ar', 'JO'),
    supportedLocales: const [Locale('ar', 'JO')],
    localizationsDelegates: GlobalMaterialLocalizations.delegates,
    routes: {'/': (_) => Studio(drafts: drafts)},
    onGenerateInitialRoutes: invitation != null || invalidLink
        ? (routeName) => [
            MaterialPageRoute<void>(
              settings: RouteSettings(name: routeName),
              builder: (_) => switch (invitation) {
                final invite? => GuestPage(invitation: invite),
                null => const Scaffold(
                  body: Center(child: Text('رابط الدعوة غير صالح.')),
                ),
              },
            ),
          ]
        : null,
  );
}
