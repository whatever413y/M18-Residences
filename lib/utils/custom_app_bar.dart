import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;

  const CustomAppBar({super.key, required this.title, this.actions});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appBarTheme = theme.appBarTheme;

    return AppBar(
      title: Text(title, style: appBarTheme.titleTextStyle),
      backgroundColor: appBarTheme.backgroundColor,
      iconTheme: appBarTheme.iconTheme,
      actionsIconTheme: appBarTheme.actionsIconTheme ?? appBarTheme.iconTheme,
      actions: actions,
      elevation: appBarTheme.elevation ?? 4,
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: appBarTheme.iconTheme?.color ?? Colors.white),
        onPressed: () => Navigator.of(context).pop(true),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
