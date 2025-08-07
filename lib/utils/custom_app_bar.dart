import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rental_management_system_flutter/bloc/auth/auth_bloc.dart';
import 'package:rental_management_system_flutter/bloc/auth/auth_event.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool logoutOnBack;

  const CustomAppBar({super.key, required this.title, this.actions, this.leading, this.logoutOnBack = false});

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
        icon: logoutOnBack ? const Icon(Icons.logout, color: Colors.white) : leading ?? const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () {
          if (logoutOnBack) {
            context.read<AuthBloc>().add(LogoutRequested());
            Navigator.of(context).pop(true);
          } else {
            Navigator.of(context).pop(true);
          }
        },
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
