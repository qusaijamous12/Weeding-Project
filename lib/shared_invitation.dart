import 'package:cloud_firestore/cloud_firestore.dart';

import 'invitation.dart';

class SharedInvitation {
  static final _idPattern = RegExp(r'^[A-Za-z0-9]{20}$');

  static bool isLink(Uri uri) => uri.path.startsWith(Invitation.linkPrefix);

  static String? idFromLink(Uri uri) {
    if (!isLink(uri)) return null;
    final id = uri.path.substring(Invitation.linkPrefix.length);
    return _idPattern.hasMatch(id) ? id : null;
  }

  static CollectionReference<Map<String, dynamic>> get _invitations =>
      FirebaseFirestore.instance.collection('sharedInvitations');

  static Future<Uri> publish(Invitation invitation, Uri origin) async {
    final document = await _invitations
        .add(invitation.toJson())
        .timeout(const Duration(seconds: 15));
    return Uri(
      scheme: origin.scheme,
      host: origin.host,
      port: origin.hasPort ? origin.port : null,
      path: '${Invitation.linkPrefix}${document.id}',
    );
  }

  static Future<Invitation?> open(String id) async {
    final snapshot = await _invitations
        .doc(id)
        .get()
        .timeout(const Duration(seconds: 15));
    return Invitation.fromJson(snapshot.data());
  }
}
