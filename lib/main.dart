import 'dart:async';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import 'drafts.dart';
import 'firebase_options.dart';
import 'invitation.dart';
import 'invitation_view.dart';
import 'shared_guest_page.dart';
import 'shared_invitation.dart';
import 'sign_in.dart';
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
  final drafts = Drafts();
  if (SharedInvitation.isLink(address)) {
    final id = SharedInvitation.idFromLink(address);
    runApp(
      WisalApp(
        drafts: drafts,
        invalidLink: id == null,
        loadInvitation: id == null ? null : () => _openSharedInvitation(id),
      ),
    );
    return;
  }
  if (address.fragment.startsWith(Invitation.linkPrefix)) {
    final invitation = Invitation.fromLink(address);
    runApp(
      WisalApp(
        drafts: drafts,
        invitation: invitation,
        invalidLink: invitation == null,
      ),
    );
    unawaited(_initializeGuestAnalytics());
    return;
  }

  try {
    await drafts.load();
  } on Exception {
    // The editor can open when browser storage is disabled.
  }
  runApp(
    _FirebaseEntry(
      content: (onSignOut) => WisalApp(drafts: drafts, onSignOut: onSignOut),
    ),
  );
}

Future<Invitation?> _openSharedInvitation(String id) async {
  final app = await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  ).timeout(const Duration(seconds: 15));
  unawaited(_initializeAnalytics(app));
  return SharedInvitation.open(id);
}

Future<void> _initializeGuestAnalytics() async {
  if (!kIsWeb) return;
  try {
    final app = await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    await _initializeAnalytics(app);
  } on Exception catch (error) {
    debugPrint('Firebase services unavailable (${error.runtimeType}).');
  }
}

Future<void> _initializeAnalytics(FirebaseApp app) async {
  try {
    final address = Uri.base;
    final analytics = FirebaseAnalytics.instanceFor(
      app: app,
      webOptions: {
        'config': {
          // Exclude personal invitation details encoded in guest URLs.
          'page_location': Uri(
            scheme: address.scheme,
            host: address.host,
            port: address.hasPort ? address.port : null,
            path: SharedInvitation.isLink(address)
                ? Invitation.linkPrefix
                : address.path,
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

class _FirebaseEntry extends StatefulWidget {
  const _FirebaseEntry({required this.content});

  final Widget Function(Future<void> Function() onSignOut) content;

  @override
  State<_FirebaseEntry> createState() => _FirebaseEntryState();
}

class _FirebaseEntryState extends State<_FirebaseEntry> {
  late Future<FirebaseAuth> _firebase = _initialize();

  Future<FirebaseAuth> _initialize() async {
    final app = await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    ).timeout(const Duration(seconds: 15));
    final auth = FirebaseAuth.instanceFor(app: app);
    unawaited(_initializeAnalytics(app));
    return auth;
  }

  void _retry() => setState(() => _firebase = _initialize());

  @override
  Widget build(BuildContext context) => FutureBuilder<FirebaseAuth>(
    future: _firebase,
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return _authShell(const _AuthLoading());
      }
      if (snapshot.hasError) {
        return _authShell(_AuthUnavailable(onRetry: _retry));
      }
      final auth = snapshot.data;
      if (auth == null) return _authShell(const _AuthLoading());
      return AuthGate(
        key: ObjectKey(auth),
        sessions: auth.authStateChanges().map((user) => user?.uid),
        onSignIn: (email, password) async {
          await auth.signInWithEmailAndPassword(
            email: email,
            password: password,
          );
        },
        onSignOut: auth.signOut,
        onRetry: _retry,
        content: widget.content,
      );
    },
  );
}

class AuthGate extends StatelessWidget {
  const AuthGate({
    super.key,
    required this.sessions,
    required this.onSignIn,
    required this.onSignOut,
    required this.onRetry,
    required this.content,
  });

  final Stream<String?> sessions;
  final Future<void> Function(String email, String password) onSignIn;
  final Future<void> Function() onSignOut;
  final VoidCallback onRetry;
  final Widget Function(Future<void> Function() onSignOut) content;

  @override
  Widget build(BuildContext context) => StreamBuilder<String?>(
    stream: sessions,
    builder: (context, snapshot) {
      if (snapshot.hasError ||
          snapshot.connectionState == ConnectionState.done) {
        return _authShell(_AuthUnavailable(onRetry: onRetry));
      }
      if (snapshot.connectionState == ConnectionState.waiting) {
        return _authShell(const _AuthLoading());
      }
      final userId = snapshot.data;
      if (userId == null) {
        return _authShell(SignInPage(onSignIn: onSignIn));
      }
      return KeyedSubtree(key: ValueKey(userId), child: content(onSignOut));
    },
  );
}

// Keep the sign-in view outside the studio navigator.
Widget _authShell(Widget content) => MaterialApp(
  key: const ValueKey('authentication'),
  title: 'وِصال | دعوات الزفاف',
  debugShowCheckedModeBanner: false,
  theme: studioTheme(),
  locale: const Locale('ar', 'JO'),
  supportedLocales: const [Locale('ar', 'JO')],
  localizationsDelegates: GlobalMaterialLocalizations.delegates,
  builder: (_, _) => Overlay.wrap(child: content),
);

class _AuthLoading extends StatelessWidget {
  const _AuthLoading();

  @override
  Widget build(BuildContext context) => const Scaffold(
    body: Center(
      child: CircularProgressIndicator(
        semanticsLabel: 'التحقق من تسجيل الدخول',
      ),
    ),
  );
}

class _AuthUnavailable extends StatelessWidget {
  const _AuthUnavailable({required this.onRetry});
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('تعذّر الاتصال بخدمة تسجيل الدخول.'),
          const SizedBox(height: 12),
          FilledButton(onPressed: onRetry, child: const Text('إعادة المحاولة')),
        ],
      ),
    ),
  );
}

class WisalApp extends StatelessWidget {
  const WisalApp({
    super.key,
    required this.drafts,
    this.invitation,
    this.invalidLink = false,
    this.loadInvitation,
    this.onSignOut,
  });
  final Drafts drafts;
  final Invitation? invitation;
  final bool invalidLink;
  final Future<Invitation?> Function()? loadInvitation;
  final Future<void> Function()? onSignOut;

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'وِصال | دعوات الزفاف',
    debugShowCheckedModeBanner: false,
    theme: studioTheme(),
    locale: const Locale('ar', 'JO'),
    supportedLocales: const [Locale('ar', 'JO')],
    localizationsDelegates: GlobalMaterialLocalizations.delegates,
    routes: {'/': _landingPage},
    onGenerateInitialRoutes:
        invitation != null || invalidLink || loadInvitation != null
        ? (routeName) => [
            MaterialPageRoute<void>(
              settings: RouteSettings(name: routeName),
              builder: _landingPage,
            ),
          ]
        : null,
  );

  Widget _landingPage(BuildContext context) {
    if (loadInvitation case final load?) return SharedGuestPage(load: load);
    if (invitation case final invite?) return GuestPage(invitation: invite);
    if (invalidLink) {
      return const Scaffold(body: Center(child: Text('رابط الدعوة غير صالح.')));
    }
    return Studio(drafts: drafts, onSignOut: onSignOut);
  }
}
