import 'package:flutter/material.dart';

class ThemeToggleButton extends StatefulWidget {
  final VoidCallback onPressed;

  const ThemeToggleButton({super.key, required this.onPressed});

  @override
  State<ThemeToggleButton> createState() => _ThemeToggleButtonState();
}

class _ThemeToggleButtonState extends State<ThemeToggleButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _rotation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _rotation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _controller.forward();
  }

  @override
  void didUpdateWidget(ThemeToggleButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    _controller.forward(from: 0.0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: isDark
            ? Colors.black.withValues(alpha: 0.4)
            : colorScheme.surface.withValues(alpha: 0.95),
        shape: BoxShape.circle,
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.25)
              : colorScheme.outlineVariant.withValues(alpha: 0.7),
          width: 0.6,
        ),
      ),
      child: IconButton(
        onPressed: () {
          widget.onPressed();
          _controller.forward(from: 0.0);
        },
        icon: RotationTransition(
          turns: _rotation,
          child: Icon(
            isDark ? Icons.light_mode : Icons.dark_mode,
            color: colorScheme.onSurface,
            size: 20,
          ),
        ),
        splashRadius: 20,
      ),
    );
  }
}
