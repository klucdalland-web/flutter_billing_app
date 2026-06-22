import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class AppPageHeader extends StatelessWidget implements PreferredSizeWidget {
  const AppPageHeader({
    super.key,
    required this.title,
    this.onBack,
    this.actions,
  });

  final String title;
  final VoidCallback? onBack;
  final List<Widget>? actions;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title),
      leading: onBack == null
          ? null
          : IconButton(
              icon: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppTheme.surfaceColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.borderColor),
                ),
                child: const Icon(Icons.arrow_back_rounded, size: 20),
              ),
              onPressed: onBack,
            ),
      actions: actions,
    );
  }
}
