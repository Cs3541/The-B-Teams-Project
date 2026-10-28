import 'package:flutter/material.dart';

import 'settings_screen.dart';

class AppTopBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final TextStyle? titleStyle;
  final bool? centerTitle;
  final Color? backgroundColor;

  const AppTopBar({
    super.key,
    required this.title,
    this.titleStyle,
    this.centerTitle,
    this.backgroundColor,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  void _openPage(BuildContext context, String title) {
    final navigator = Navigator.of(context);
    final currentPage = ModalRoute.of(context)?.settings.name;
    if (currentPage == title) return;
    final route = MaterialPageRoute<void>(
      settings: RouteSettings(name: title),
      builder: (_) => title == 'Settings'
          ? const SettingsScreen()
          : Scaffold(appBar: AppTopBar(title: title)),
    );
    if (currentPage == 'Settings' || currentPage == 'Profile') {
      navigator.pushReplacement(route);
    } else {
      navigator.push(route);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title, style: titleStyle),
      centerTitle: centerTitle,
      backgroundColor: backgroundColor,
      actions: [
        IconButton(
          tooltip: 'Settings',
          icon: const Icon(Icons.settings),
          onPressed: () => _openPage(context, 'Settings'),
        ),
        IconButton(
          tooltip: 'Profile',
          icon: const Icon(Icons.account_circle),
          onPressed: () => _openPage(context, 'Profile'),
        ),
      ],
    );
  }
}
