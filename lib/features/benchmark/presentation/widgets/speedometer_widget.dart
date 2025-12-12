import 'dart:math';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

/// Cyberpunk-style speedometer widget using CustomPainter
class SpeedometerWidget extends StatefulWidget {
  final double tokensPerSecond;
  final double maxSpeed;

  const SpeedometerWidget({
    super.key,
    required this.tokensPerSecond,
    this.maxSpeed = 100.0,
  });

  @override
  State<SpeedometerWidget> createState() => _SpeedometerWidgetState();
}

class _SpeedometerWidgetState extends State<SpeedometerWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  double _currentSpeed = 0.0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: widget.tokensPerSecond)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _controller.forward();
  }

  @override
  void didUpdateWidget(SpeedometerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.tokensPerSecond != widget.tokensPerSecond) {
      _animation = Tween<double>(
        begin: _currentSpeed,
        end: widget.tokensPerSecond,
      ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        _currentSpeed = _animation.value;
        return CustomPaint(
          size: const Size(300, 300),
          painter: _SpeedometerPainter(
            speed: _currentSpeed,
            maxSpeed: widget.maxSpeed,
          ),
        );
      },
    );
  }
}

class _SpeedometerPainter extends CustomPainter {
  final double speed;
  final double maxSpeed;

  _SpeedometerPainter({
    required this.speed,
    required this.maxSpeed,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 20;

    // Draw outer glow circle
    final glowPaint = Paint()
      ..color = AppTheme.neonCyan.withOpacity(0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 20
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15);
    canvas.drawCircle(center, radius, glowPaint);

    // Draw background arc
    final bgArcPaint = Paint()
      ..color = AppTheme.darkBgTertiary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 15
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      pi * 0.75,
      pi * 1.5,
      false,
      bgArcPaint,
    );

    // Draw speed arc (gradient from cyan to magenta)
    final speedPercent = (speed / maxSpeed).clamp(0.0, 1.0);
    final sweepAngle = pi * 1.5 * speedPercent;

    final speedArcPaint = Paint()
      ..shader = SweepGradient(
        startAngle: pi * 0.75,
        endAngle: pi * 0.75 + sweepAngle,
        colors: [
          AppTheme.neonCyan,
          AppTheme.neonBlue,
          AppTheme.neonMagenta,
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 15
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      pi * 0.75,
      sweepAngle,
      false,
      speedArcPaint,
    );

    // Draw needle
    final needleAngle = pi * 0.75 + sweepAngle;
    final needleLength = radius - 30;
    final needleEnd = Offset(
      center.dx + needleLength * cos(needleAngle),
      center.dy + needleLength * sin(needleAngle),
    );

    final needlePaint = Paint()
      ..color = AppTheme.neonCyan
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);

    canvas.drawLine(center, needleEnd, needlePaint);

    // Draw center circle
    final centerCirclePaint = Paint()
      ..color = AppTheme.darkBgSecondary
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 15, centerCirclePaint);

    final centerBorderPaint = Paint()
      ..color = AppTheme.neonCyan
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(center, 15, centerBorderPaint);

    // Draw speed text
    final textPainter = TextPainter(
      text: TextSpan(
        text: speed.toStringAsFixed(1),
        style: const TextStyle(
          color: AppTheme.neonCyan,
          fontSize: 36,
          fontWeight: FontWeight.bold,
          fontFamily: 'Orbitron',
          shadows: [
            Shadow(
              color: AppTheme.neonCyan,
              blurRadius: 10,
            ),
          ],
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        center.dx - textPainter.width / 2,
        center.dy + 40,
      ),
    );

    // Draw "T/S" label
    final labelPainter = TextPainter(
      text: const TextSpan(
        text: 'TOKENS/SEC',
        style: TextStyle(
          color: AppTheme.textSecondary,
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 2,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    labelPainter.layout();
    labelPainter.paint(
      canvas,
      Offset(
        center.dx - labelPainter.width / 2,
        center.dy + 80,
      ),
    );
  }

  @override
  bool shouldRepaint(_SpeedometerPainter oldDelegate) {
    return oldDelegate.speed != speed || oldDelegate.maxSpeed != maxSpeed;
  }
}
