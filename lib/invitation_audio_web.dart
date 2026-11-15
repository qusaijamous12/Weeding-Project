import 'dart:js_interop';
import 'dart:ui_web' as ui_web;

import 'package:web/web.dart' as web;

class InvitationAudio {
  InvitationAudio(String asset)
    : _element = web.HTMLAudioElement()
        ..preload = 'none'
        ..loop = true
        ..src = ui_web.assetManager.getAssetUrl(asset);

  final web.HTMLAudioElement _element;
  JSFunction? _gestureListener;

  bool get paused => _element.paused;

  void listenForTap(void Function() onTap) {
    // Run play() inside the browser's trusted input event, before Flutter's
    // gesture handling can consume it.
    final listener = ((web.Event event) {
      if (event.isTrusted) onTap();
    }).toJS;
    _gestureListener = listener;
    web.document.addEventListener('click', listener, true.toJS);
    web.document.addEventListener('touchend', listener, true.toJS);
  }

  void stopListeningForTap() {
    final listener = _gestureListener;
    if (listener == null) return;
    web.document.removeEventListener('click', listener, true.toJS);
    web.document.removeEventListener('touchend', listener, true.toJS);
    _gestureListener = null;
  }

  Future<void> play() async {
    await _element.play().toDart;
  }

  void pause() => _element.pause();

  void dispose() {
    stopListeningForTap();
    _element.pause();
    _element.removeAttribute('src');
    _element.load();
  }
}
