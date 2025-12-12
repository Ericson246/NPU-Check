import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

/// Typewriter-style text widget with Matrix effect
class TypewriterText extends StatefulWidget {
  final String text;
  final TextStyle? style;
  final Duration typingSpeed;

  const TypewriterText({
    super.key,
    required this.text,
    this.style,
    this.typingSpeed = const Duration(milliseconds: 50),
  });

  @override
  State<TypewriterText> createState() => _TypewriterTextState();
}

class _TypewriterTextState extends State<TypewriterText>
    with SingleTickerProviderStateMixin {
  late AnimationController _cursorController;
  String _displayedText = '';

  @override
  void initState() {
    super.initState();
    _cursorController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void didUpdateWidget(TypewriterText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text) {
      setState(() {
        _displayedText = widget.text;
      });
    }
  }

  @override
  void dispose() {
    _cursorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.darkBgSecondary,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.neonCyan.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: AppTheme.neonGlow(AppTheme.neonCyan, intensity: 0.2),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Terminal prompt
          Text(
            '> ',
            style: widget.style?.copyWith(color: AppTheme.neonGreen) ??
                const TextStyle(
                  color: AppTheme.neonGreen,
                  fontFamily: 'RobotoMono',
                  fontSize: 14,
                ),
          ),
          // Text content
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
          // Blinking cursor
          AnimatedBuilder(
            animation: _cursorController,
            builder: (context, child) {
              return Opacity(
                opacity: _cursorController.value,
                child: Container(
                  width: 8,
                  height: 16,
                  decoration: BoxDecoration(
                    color: AppTheme.neonCyan,
                    boxShadow: AppTheme.neonGlow(AppTheme.neonCyan),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
