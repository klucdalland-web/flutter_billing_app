import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.onPressed,
    required this.label,
    this.icon,
    this.borderRadius = 18.0,
    this.padding = const EdgeInsets.symmetric(vertical: 18),
    this.isFullWidth = true,
    this.textStyle,
    this.isLoading = false,
    this.useAccent = false,
  });

  final VoidCallback? onPressed;
  final String label;
  final IconData? icon;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final bool isFullWidth;
  final TextStyle? textStyle;
  final bool isLoading;
  final bool useAccent;

  @override
  Widget build(BuildContext context) {
    final gradient = useAccent ? AppTheme.accentGradient : AppTheme.primaryGradient;
    final enabled = onPressed != null && !isLoading;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      child: Opacity(
        opacity: enabled ? 1 : 0.45,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: enabled ? onPressed : null,
            borderRadius: BorderRadius.circular(borderRadius),
            child: Ink(
              width: isFullWidth ? double.infinity : null,
              padding: padding,
              decoration: BoxDecoration(
                gradient: gradient,
                borderRadius: BorderRadius.circular(borderRadius),
                boxShadow: [
                  BoxShadow(
                    color: (useAccent ? AppTheme.accentColor : AppTheme.primaryColor)
                        .withValues(alpha: 0.35),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: isFullWidth ? MainAxisSize.max : MainAxisSize.min,
                children: [
                  if (isLoading)
                    const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2.5,
                      ),
                    )
                  else if (icon != null) ...[
                    Icon(icon, color: Colors.white, size: 22),
                    const SizedBox(width: 10),
                  ],
                  Text(
                    label,
                    style: textStyle ??
                        const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                          letterSpacing: 0.3,
                        ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
