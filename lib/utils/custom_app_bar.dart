import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:m18_residences/bloc/auth/auth_bloc.dart';
import 'package:m18_residences/bloc/auth/auth_event.dart';
import 'package:m18_residences/features/login/login_page.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool logoutOnBack;
  final bool showRefresh;
  final VoidCallback? onRefresh;

  const CustomAppBar({
    super.key,
    required this.title,
    this.actions,
    this.leading,
    this.logoutOnBack = false,
    this.showRefresh = false,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appBarTheme = theme.appBarTheme;

    List<Widget> actionWidgets = [];
    if (actions != null) {
      actionWidgets.addAll(actions!);
    }
    if (showRefresh) {
      actionWidgets.add(IconButton(icon: const Icon(Icons.refresh, color: Colors.white), tooltip: 'Refresh', onPressed: onRefresh));
    }

    return AppBar(
      title: Text(title, style: appBarTheme.titleTextStyle),
      backgroundColor: appBarTheme.backgroundColor,
      iconTheme: appBarTheme.iconTheme,
      actionsIconTheme: appBarTheme.actionsIconTheme ?? appBarTheme.iconTheme,
      actions: actionWidgets.isNotEmpty ? actionWidgets : null,
      elevation: appBarTheme.elevation ?? 4,
      leading: IconButton(
        icon: logoutOnBack ? const Icon(Icons.logout, color: Colors.white) : leading ?? const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () {
          if (logoutOnBack) {
            context.read<AuthBloc>().add(LogoutRequested());
            Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (_) => LoginPage()), (route) => false);
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
