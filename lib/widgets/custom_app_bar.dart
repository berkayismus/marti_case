import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback onResetPressed;

  const CustomAppBar({
    super.key,
    required this.title,
    required this.onResetPressed,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title),
      backgroundColor: Colors.orange,
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: onResetPressed,
          tooltip: 'Rotayı Sıfırla',
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
