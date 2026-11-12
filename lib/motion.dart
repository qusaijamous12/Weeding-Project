import 'package:flutter/material.dart';

bool reduceMotion(BuildContext context) =>
    MediaQuery.disableAnimationsOf(context) ||
    MediaQuery.accessibleNavigationOf(context);

/// Reveals each section once, when it enters its scroll viewport.
class MotionReveal extends StatefulWidget {
  const MotionReveal({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.distance = 22,
  });

  final Widget child;
  final Duration delay;
  final double distance;

  @override
  State<MotionReveal> createState() => _MotionRevealState();
}

class _MotionRevealState extends State<MotionReveal>
    with SingleTickerProviderStateMixin {
  late final _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 700) + widget.delay,
  );
  late final _progress = CurvedAnimation(
    parent: _controller,
    curve: Interval(
      widget.delay.inMilliseconds / (700 + widget.delay.inMilliseconds),
      1,
      curve: Curves.easeOutCubic,
    ),
  );
  ScrollPosition? _position;
  bool _scheduled = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _position?.removeListener(_scheduleCheck);
    _position = Scrollable.maybeOf(context)?.position;
    if (reduceMotion(context)) {
      _controller.value = 1;
    } else if (!_controller.isCompleted) {
      _position?.addListener(_scheduleCheck);
      _scheduleCheck();
    }
  }

  void _scheduleCheck() {
    if (_scheduled || _controller.isAnimating || _controller.isCompleted) {
      return;
    }
    _scheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scheduled = false;
      if (!mounted || _controller.isCompleted) return;
      final box = context.findRenderObject();
      if (box is! RenderBox || !box.hasSize) return;
      var viewport = Offset.zero & MediaQuery.sizeOf(context);
      final scrollBox = Scrollable.maybeOf(context)?.context.findRenderObject();
      if (scrollBox is RenderBox && scrollBox.hasSize) {
        viewport = viewport.intersect(
          scrollBox.localToGlobal(Offset.zero) & scrollBox.size,
        );
      }
      final bounds = box.localToGlobal(Offset.zero) & box.size;
      if (bounds.overlaps(viewport)) {
        _position?.removeListener(_scheduleCheck);
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _position?.removeListener(_scheduleCheck);
    _progress.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _scheduleCheck();
    return AnimatedBuilder(
      animation: _progress,
      child: widget.child,
      builder: (context, child) => Opacity(
        opacity: _progress.value,
        alwaysIncludeSemantics: true,
        child: Transform.translate(
          offset: Offset(0, widget.distance * (1 - _progress.value)),
          child: child,
        ),
      ),
    );
  }
}

/// Gives pointer hover and keyboard focus the same gentle lift.
class HoverLift extends StatefulWidget {
  const HoverLift({super.key, required this.child});
  final Widget child;

  @override
  State<HoverLift> createState() => _HoverLiftState();
}

class _HoverLiftState extends State<HoverLift> {
  bool _hovered = false;
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    final active = _hovered || _focused;
    final reduced = reduceMotion(context);
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: Focus(
        canRequestFocus: false,
        onFocusChange: (value) => setState(() => _focused = value),
        child: AnimatedContainer(
          duration: reduced ? Duration.zero : const Duration(milliseconds: 260),
          curve: Curves.easeOutCubic,
          transform: Matrix4.translationValues(
            0,
            active && !reduced ? -7 : 0,
            0,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF26382A)
                    .withValues(alpha: active ? .13 : 0),
                blurRadius: active ? 28 : 0,
                offset: Offset(0, active ? 14 : 0),
              ),
            ],
          ),
          child: widget.child,
        ),
      ),
    );
  }
}

class StudioPageTransitions extends PageTransitionsBuilder {
  const StudioPageTransitions();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    if (reduceMotion(context)) return child;
    final progress = animation.drive(CurveTween(curve: Curves.easeOutCubic));
    return FadeTransition(
      opacity: progress,
      child: SlideTransition(
        position: progress.drive(
          Tween(begin: const Offset(0, .025), end: Offset.zero),
        ),
        child: child,
      ),
    );
  }
}
