class InvitationAudio {
  InvitationAudio(String asset) {
    throw UnsupportedError('Invitation audio is available on the web.');
  }

  bool get paused => true;

  void listenForTap(void Function() onTap) {}

  void stopListeningForTap() {}

  Future<void> play() async {}

  void pause() {}

  void dispose() {}
}
