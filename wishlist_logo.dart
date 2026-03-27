import 'package:flutter/material.dart';
import 'dart:math';

/// Custom logo widget for Wishlist App
class WishlistLogo extends StatefulWidget {
  final double size;
  final Color? color;
  final bool animated;

  const WishlistLogo({
    super.key,
    this.size = 32,
    this.color,
    this.animated = true,
  }) : super();

  @override
  State<WishlistLogo> createState() => _WishlistLogoState();
}

class _WishlistLogoState extends State<WishlistLogo>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    if (widget.animated) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.color ?? Theme.of(context).colorScheme.primary;

    return widget.animated
        ? AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Transform.scale(
                scale: 1 + (sin(_controller.value * pi) * 0.05),
                child: CustomPaint(
                  size: Size(widget.size, widget.size),
                  painter: WishlistLogoPainter(color: color),
                ),
              );
            },
          )
        : CustomPaint(
            size: Size(widget.size, widget.size),
            painter: WishlistLogoPainter(color: color),
          );
  }
}

class WishlistLogoPainter extends CustomPainter {
  final Color color;

  WishlistLogoPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final paintFill = Paint()
      ..color = color.withOpacity(0.2)
      ..style = PaintingStyle.fill;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 3;

    // Heart shape representing wish
    _drawHeart(canvas, center, radius, paint, paintFill);

    // Sparkle effects
    _drawSparkles(canvas, size, paint);
  }

  void _drawHeart(
    Canvas canvas,
    Offset center,
    double size,
    Paint paint,
    Paint paintFill,
  ) {
    final path = Path();
    final x = center.dx;
    final y = center.dy;

    // Create a more polished heart shape
    path.moveTo(x, y + size);

    // Left lobe
    path.cubicTo(
      x - size,
      y - size * 0.2,
      x - size * 1.1,
      y - size * 0.8,
      x - size * 0.4,
      y - size * 0.9,
    );

    // Top center
    path.cubicTo(
      x - size * 0.1,
      y - size * 1.2,
      x + size * 0.1,
      y - size * 1.2,
      x + size * 0.4,
      y - size * 0.9,
    );

    // Right lobe
    path.cubicTo(
      x + size * 1.1,
      y - size * 0.8,
      x + size,
      y - size * 0.2,
      x,
      y + size,
    );

    canvas.drawPath(path, paintFill);
    canvas.drawPath(path, paint);

    // Add gift ribbon effect
    paint.strokeWidth = 1.5;
    paint.style = PaintingStyle.stroke;
    
    // Vertical ribbon
    canvas.drawLine(
      Offset(x, y - size * 0.3),
      Offset(x, y + size * 0.5),
      paint,
    );
    
    // Horizontal ribbon
    canvas.drawLine(
      Offset(x - size * 0.4, y + size * 0.1),
      Offset(x + size * 0.4, y + size * 0.1),
      paint,
    );
  }

  void _drawSparkles(Canvas canvas, Size size, Paint paint) {
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 1.5;

    // Top-left sparkle
    canvas.drawCircle(Offset(size.width * 0.25, size.height * 0.2), 2, paint);
    canvas.drawLine(
      Offset(size.width * 0.25, size.height * 0.15),
      Offset(size.width * 0.25, size.height * 0.25),
      paint,
    );
    canvas.drawLine(
      Offset(size.width * 0.2, size.height * 0.2),
      Offset(size.width * 0.3, size.height * 0.2),
      paint,
    );

    // Top-right sparkle (smaller)
    canvas.drawCircle(Offset(size.width * 0.75, size.height * 0.25), 1.5, paint);
  }

  @override
  bool shouldRepaint(WishlistLogoPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}
