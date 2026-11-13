import 'package:firebase_core/firebase_core.dart';
import 'package:material_ui/material_ui.dart';

import 'firebase_options.dart';
import 'invitation.dart';
import 'shared_guest_page.dart';
import 'shared_invitation.dart';
import 'studio_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final id = SharedInvitation.idFromLink(Uri.base);

  runApp(
    MaterialApp(
      title: 'وِصال | دعوة زفاف',
      debugShowCheckedModeBanner: false,
      theme: studioTheme(),
      locale: const Locale('ar', 'JO'),
      supportedLocales: const [Locale('ar', 'JO')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      home: id == null
          ? const Scaffold(body: Center(child: Text('رابط الدعوة غير صالح.')))
          : SharedGuestPage(load: () => _openInvitation(id)),
    ),
  );
}

Future<Invitation?> _openInvitation(String id) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform)
      .timeout(const Duration(seconds: 15));
  return SharedInvitation.open(id);
}
