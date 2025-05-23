//دعم hover والضغط الطويل على أيقونات التنقل

import 'package:flutter/material.dart';

class BottomNavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final int index;
  final int selectedIndex;
  final Function(int) onTap;

  const BottomNavItem({
    super.key,
    required this.icon,
    required this.label,
    required this.index,
    required this.selectedIndex,
    required this.onTap,
  });

  void _showTooltip(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(milliseconds: 800),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isSelected = selectedIndex == index;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onLongPress: () => _showTooltip(context, label),
        child: Tooltip(
          message: label,
          child: Icon(
            icon,
            size: 30,
            color: isSelected ? const Color(0xFF1F6B61) : Colors.black,
          ),
        ),
      ),
    );
  }
}
