import 'package:flutter/material.dart';
import 'dart:math' as math;

/// Custom painter that draws authentic playing card suit symbols.
/// These match the proportions and curves found on real card decks.
enum Suit { hearts, diamonds, clubs, spades }

class SuitIcon extends StatelessWidget {
  final Suit suit;
  final double size;
  final Color? colorOverride;

  const SuitIcon({
    super.key,
    required this.suit,
    this.size = 48,
    this.colorOverride,
  });

  Color get _defaultColor {
    switch (suit) {
      case Suit.hearts:
      case Suit.diamonds:
        return const Color(0xFFD32F2F);
      case Suit.clubs:
      case Suit.spades:
        return const Color(0xFF212121);
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _SuitPainter(suit: suit, color: colorOverride ?? _defaultColor),
    );
  }
}

class _SuitPainter extends CustomPainter {
  final Suit suit;
  final Color color;

  _SuitPainter({required this.suit, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    switch (suit) {
      case Suit.hearts:
        _drawHeart(canvas, size, paint);
        break;
      case Suit.diamonds:
        _drawDiamond(canvas, size, paint);
        break;
      case Suit.clubs:
        _drawClub(canvas, size, paint);
        break;
      case Suit.spades:
        _drawSpade(canvas, size, paint);
        break;
    }
  }

  void _drawHeart(Canvas canvas, Size size, Paint paint) {
    final w = size.width;
    final h = size.height;
    final path = Path();

    // Classic heart shape with proper curves
    path.moveTo(w * 0.5, h * 0.85);

    // Left side curve
    path.cubicTo(
      w * 0.1, h * 0.55,
      w * 0.0, h * 0.3,
      w * 0.25, h * 0.18,
    );

    // Top left bump
    path.cubicTo(
      w * 0.38, h * 0.1,
      w * 0.5, h * 0.18,
      w * 0.5, h * 0.32,
    );

    // Top right bump
    path.cubicTo(
      w * 0.5, h * 0.18,
      w * 0.62, h * 0.1,
      w * 0.75, h * 0.18,
    );

    // Right side curve
    path.cubicTo(
      w * 1.0, h * 0.3,
      w * 0.9, h * 0.55,
      w * 0.5, h * 0.85,
    );

    path.close();
    canvas.drawPath(path, paint);
  }

  void _drawDiamond(Canvas canvas, Size size, Paint paint) {
    final w = size.width;
    final h = size.height;
    final path = Path();

    // Diamond with slightly curved sides for authenticity
    path.moveTo(w * 0.5, h * 0.08);
    path.cubicTo(w * 0.55, h * 0.2, w * 0.85, h * 0.4, w * 0.92, h * 0.5);
    path.cubicTo(w * 0.85, h * 0.6, w * 0.55, h * 0.8, w * 0.5, h * 0.92);
    path.cubicTo(w * 0.45, h * 0.8, w * 0.15, h * 0.6, w * 0.08, h * 0.5);
    path.cubicTo(w * 0.15, h * 0.4, w * 0.45, h * 0.2, w * 0.5, h * 0.08);

    path.close();
    canvas.drawPath(path, paint);
  }

  void _drawClub(Canvas canvas, Size size, Paint paint) {
    final w = size.width;
    final h = size.height;
    final r = w * 0.19;

    // Three circles forming the clover
    // Top circle
    canvas.drawCircle(Offset(w * 0.5, h * 0.28), r, paint);
    // Bottom-left circle
    canvas.drawCircle(Offset(w * 0.3, h * 0.48), r, paint);
    // Bottom-right circle
    canvas.drawCircle(Offset(w * 0.7, h * 0.48), r, paint);

    // Stem
    final stemPath = Path();
    stemPath.moveTo(w * 0.42, h * 0.52);
    stemPath.lineTo(w * 0.38, h * 0.85);
    stemPath.lineTo(w * 0.62, h * 0.85);
    stemPath.lineTo(w * 0.58, h * 0.52);
    stemPath.close();
    canvas.drawPath(stemPath, paint);

    // Small connecting triangles between circles
    final connectPath = Path();
    connectPath.moveTo(w * 0.5, h * 0.42);
    connectPath.lineTo(w * 0.38, h * 0.42);
    connectPath.lineTo(w * 0.44, h * 0.32);
    connectPath.close();
    canvas.drawPath(connectPath, paint);

    final connectPath2 = Path();
    connectPath2.moveTo(w * 0.5, h * 0.42);
    connectPath2.lineTo(w * 0.62, h * 0.42);
    connectPath2.lineTo(w * 0.56, h * 0.32);
    connectPath2.close();
    canvas.drawPath(connectPath2, paint);
  }

  void _drawSpade(Canvas canvas, Size size, Paint paint) {
    final w = size.width;
    final h = size.height;
    final path = Path();

    // Spade is an inverted heart with a stem
    path.moveTo(w * 0.5, h * 0.08);

    // Left curve
    path.cubicTo(
      w * 0.1, h * 0.35,
      w * 0.0, h * 0.55,
      w * 0.25, h * 0.68,
    );

    // Bottom left
    path.cubicTo(
      w * 0.38, h * 0.74,
      w * 0.5, h * 0.65,
      w * 0.5, h * 0.55,
    );

    // Bottom right
    path.cubicTo(
      w * 0.5, h * 0.65,
      w * 0.62, h * 0.74,
      w * 0.75, h * 0.68,
    );

    // Right curve
    path.cubicTo(
      w * 1.0, h * 0.55,
      w * 0.9, h * 0.35,
      w * 0.5, h * 0.08,
    );

    path.close();
    canvas.drawPath(path, paint);

    // Stem
    final stemPath = Path();
    stemPath.moveTo(w * 0.42, h * 0.6);
    stemPath.lineTo(w * 0.38, h * 0.85);
    stemPath.lineTo(w * 0.62, h * 0.85);
    stemPath.lineTo(w * 0.58, h * 0.6);
    stemPath.close();
    canvas.drawPath(stemPath, paint);
  }

  @override
  bool shouldRepaint(covariant _SuitPainter oldDelegate) {
    return suit != oldDelegate.suit || color != oldDelegate.color;
  }
}

/// Helper to get Suit enum from string
Suit suitFromString(String name) {
  switch (name.toLowerCase()) {
    case 'hearts':
      return Suit.hearts;
    case 'diamonds':
      return Suit.diamonds;
    case 'clubs':
      return Suit.clubs;
    case 'spades':
      return Suit.spades;
    default:
      return Suit.spades;
  }
}

/// Get the unicode suit character
String suitSymbol(String name) {
  switch (name.toLowerCase()) {
    case 'hearts':
      return '\u2665';
    case 'diamonds':
      return '\u2666';
    case 'clubs':
      return '\u2663';
    case 'spades':
      return '\u2660';
    default:
      return '?';
  }
}

/// Whether a suit is red
bool isSuitRed(String name) {
  return name.toLowerCase() == 'hearts' || name.toLowerCase() == 'diamonds';
}

/// Get the suit color
Color suitColor(String name) {
  return isSuitRed(name) ? const Color(0xFFD32F2F) : const Color(0xFF212121);
}
