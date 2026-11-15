import 'package:material_ui/material_ui.dart';

import 'invitation.dart';
import 'invitation_audio_stub.dart'
    if (dart.library.js_interop) 'invitation_audio_web.dart';

class InvitationMusicButton extends StatefulWidget {
  const InvitationMusicButton({
    super.key,
    required this.track,
    required this.autoplay,
  });

  final InvitationMusic track;
  final bool autoplay;

  @override
  State<InvitationMusicButton> createState() => _InvitationMusicButtonState();
}

class _InvitationMusicButtonState extends State<InvitationMusicButton> {
  InvitationAudio? _audio;
  bool _playing = false;
  bool _loading = false;

  InvitationAudio get _player =>
      _audio ??= InvitationAudio('assets/music/${widget.track.id}.m4a');

  @override
  void initState() {
    super.initState();
    if (widget.autoplay) {
      _player.listenForTap(() => _play());
      _play();
    }
  }

  Future<void> _toggle() async {
    if (_playing) {
      _audio?.pause();
      setState(() => _playing = false);
      return;
    }

    await _play(reportFailure: true);
  }

  Future<void> _play({bool reportFailure = false}) async {
    if (_loading || _playing) return;
    setState(() => _loading = true);
    try {
      final audio = _player;
      await audio.play();
      if (mounted && !audio.paused) {
        audio.stopListeningForTap();
        setState(() => _playing = true);
      }
    } catch (_) {
      if (mounted && reportFailure) {
        if (!widget.autoplay) {
          _audio?.dispose();
          _audio = null;
        }
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تعذّر تشغيل الموسيقى. حاولوا مرة أخرى.'),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _audio?.dispose();
    _audio = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.autoplay) {
      if (_loading || _playing) return const SizedBox.shrink();
      return TextButton(
        onPressed: () => _play(reportFailure: true),
        style: TextButton.styleFrom(
          backgroundColor: const Color(0xFFF6EAD7),
          foregroundColor: const Color(0xFF26382A),
        ),
        child: const Text('المس الشاشة لسماع الموسيقى'),
      );
    }
    return FloatingActionButton.small(
      heroTag: null,
      tooltip: _loading
          ? 'جارٍ تحميل الموسيقى'
          : _playing
          ? 'إيقاف الموسيقى مؤقتًا'
          : 'تشغيل الموسيقى',
      backgroundColor: const Color(0xFFF6EAD7),
      foregroundColor: const Color(0xFF26382A),
      onPressed: _loading ? null : _toggle,
      child: _loading
          ? const SizedBox.square(
              dimension: 17,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Icon(_playing ? Icons.pause_rounded : Icons.music_note_rounded),
    );
  }
}
