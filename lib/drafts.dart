import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'invitation.dart';

class Draft {
  const Draft(this.id, this.invitation);
  final String id;
  final Invitation invitation;
}

class Drafts extends ChangeNotifier {
  late final _preferences = SharedPreferencesAsync();
  final _drafts = <Draft>[];
  Future<void> _pending = Future<void>.value();

  static const _key = 'wisal-invitation-drafts-v1';

  List<Draft> get items => List.unmodifiable(_drafts);

  Future<void> load() async {
    final stored = await _preferences.getString(_key);
    if (stored == null) return;
    try {
      final decoded = jsonDecode(stored);
      if (decoded is! List) return;
      for (final entry in decoded) {
        if (entry is! Map<String, dynamic> || entry['id'] is! String) continue;
        final invitation = Invitation.fromJson(entry['invitation']);
        if (invitation != null) {
          _drafts.add(Draft(entry['id'] as String, invitation));
        }
      }
    } on FormatException {
      return;
    }
  }

  Future<void> save(Draft draft) => _change(
    () => [draft, ..._drafts.where((existing) => existing.id != draft.id)],
  );

  Future<void> remove(Draft draft) => _change(
    () => _drafts.where((existing) => existing.id != draft.id).toList(),
  );

  Future<void> _change(List<Draft> Function() next) {
    final write = _pending.then((_) async {
      final updated = next();
      final encoded = jsonEncode([
        for (final draft in updated)
          {'id': draft.id, 'invitation': draft.invitation.toJson()},
      ]);
      await _preferences.setString(_key, encoded);
      _drafts
        ..clear()
        ..addAll(updated);
      notifyListeners();
    });
    _pending = write.catchError((Object _) {});
    return write;
  }
}
