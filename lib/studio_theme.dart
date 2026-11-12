import 'package:flutter/material.dart';

import 'motion.dart';

const canvas = Color(0xFFF9F7F1);
const surface = Color(0xFFFFFDF8);
const ink = Color(0xFF222C22);
const muted = Color(0xFF586154);
const olive = Color(0xFF354936);
const outline = Color(0xFFE5E0D2);
const arabicDisplay = 'Amiri';

ThemeData studioTheme() {
  return ThemeData(
    useMaterial3: true,
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: StudioPageTransitions(),
        TargetPlatform.iOS: StudioPageTransitions(),
        TargetPlatform.macOS: StudioPageTransitions(),
        TargetPlatform.windows: StudioPageTransitions(),
        TargetPlatform.linux: StudioPageTransitions(),
        TargetPlatform.fuchsia: StudioPageTransitions(),
      },
    ),
    fontFamily: 'Noto Sans Arabic',
    scaffoldBackgroundColor: canvas,
    colorScheme: const ColorScheme.light(
      primary: olive,
      onPrimary: Colors.white,
      primaryContainer: Color(0xFFE0E7D8),
      onPrimaryContainer: ink,
      secondary: muted,
      secondaryContainer: Color(0xFFE0E7D8),
      onSecondaryContainer: olive,
      surface: surface,
      surfaceContainerHighest: Color(0xFFF0EEE4),
      onSurface: ink,
      outline: outline,
      outlineVariant: outline,
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
        minimumSize: const Size(0, 48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
        minimumSize: const Size(0, 46),
        side: const BorderSide(color: outline),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surface,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: outline),
      ),
    ),
  );
}

TextStyle displayStyle(
  double size, {
  Color color = ink,
  double height = 1.14,
}) => TextStyle(
  fontFamily: arabicDisplay,
  fontSize: size,
  color: color,
  height: height,
);

class Seal extends StatelessWidget {
  const Seal({super.key, this.color = olive, this.size = 38});
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) =>
      CustomPaint(size: Size.square(size), painter: _SealPainter(color));
}

class _SealPainter extends CustomPainter {
  const _SealPainter(this.color);
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / 40;
    canvas.scale(scale);
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 1.15;
    canvas.drawCircle(const Offset(20, 20), 18.5, paint);
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(15.3, 20), width: 13, height: 16),
      paint,
    );
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(24.7, 20), width: 13, height: 16),
      paint,
    );
    canvas.drawCircle(const Offset(20, 8.8), 1, paint);
  }

  @override
  bool shouldRepaint(_SealPainter oldDelegate) => oldDelegate.color != color;
}
