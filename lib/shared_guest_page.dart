import 'package:material_ui/material_ui.dart';

import 'invitation.dart';
import 'invitation_view.dart';

class SharedGuestPage extends StatefulWidget {
  const SharedGuestPage({super.key, required this.load});
  final Future<Invitation?> Function() load;

  @override
  State<SharedGuestPage> createState() => _SharedGuestPageState();
}

class _SharedGuestPageState extends State<SharedGuestPage> {
  late Future<Invitation?> _invitation = widget.load();

  @override
  Widget build(BuildContext context) => FutureBuilder<Invitation?>(
    future: _invitation,
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Scaffold(
          body: Center(
            child: CircularProgressIndicator(semanticsLabel: 'جارٍ فتح الدعوة'),
          ),
        );
      }
      if (snapshot.hasError) {
        return Scaffold(
          body: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('تعذّر فتح الدعوة.'),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: () => setState(() => _invitation = widget.load()),
                  child: const Text('إعادة المحاولة'),
                ),
              ],
            ),
          ),
        );
      }
      if (snapshot.data case final invitation?) {
        return GuestPage(invitation: invitation);
      }
      return const Scaffold(body: Center(child: Text('رابط الدعوة غير صالح.')));
    },
  );
}
