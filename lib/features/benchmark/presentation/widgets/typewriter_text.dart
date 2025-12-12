import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class TypewriterText extends StatefulWidget {
  final String text;
  final TextStyle? style;

  const TypewriterText({
    super.key,
    required this.text,
    this.style,
  });

  @override
  State<TypewriterText> createState() => _TypewriterTextState();
}

class _TypewriterTextState extends State<TypewriterText>
    with SingleTickerProviderStateMixin {
  late AnimationController _cursorController;
  String _displayedText = '';
  Timer? _typingTimer;

  @override
  void initState() {
    super.initState();
    _cursorController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..repeat(reverse: true);
    _startTyping();
  }

  @override
  void didUpdateWidget(TypewriterText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.text != oldWidget.text) {
      _startTyping();
    }
  }

  void _startTyping() {
    _typingTimer?.cancel();
    setState(() {
      _displayedText = '';
    });

    if (widget.text.isEmpty) return;

    const typingSpeed = Duration(milliseconds: 20);
    int currentIndex = 0;

    _typingTimer = Timer.periodic(typingSpeed, (timer) {
      if (currentIndex < widget.text.length) {
        setState(() {
          _displayedText += widget.text[currentIndex];
          currentIndex++;
        });
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _cursorController.dispose();
    _typingTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '> ',
          style: widget.style?.copyWith(color: AppTheme.neonGreen) ??
              const TextStyle(
                color: AppTheme.neonGreen,
                fontFamily: 'RobotoMono',
                fontSize: 14,
              ),
        ),
        Expanded(
          child: Text(
            _displayedText,
            style: widget.style ??
                const TextStyle(
                  color: AppTheme.textPrimary,
                  fontFamily: 'RobotoMono',
                  fontSize: 14,
                  height: 1.5,
                ),
          ),
        ),
        AnimatedBuilder(
          animation: _cursorController,
          builder: (context, child) {
            return Opacity(
              opacity: _cursorController.value,
              child: Container(
                width: 8,
                height: 16,
                color: AppTheme.neonCyan,
              ),
            );
          },
        ),
      ],
    );
  }
}
