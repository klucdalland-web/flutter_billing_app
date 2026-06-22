import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class InputLabel extends StatelessWidget {
  const InputLabel({
    super.key,
    required this.text,
  });

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: AppTheme.primaryDark,
              fontSize: 13,
              letterSpacing: 0.2,
            ),
      ),
    );
  }
}
