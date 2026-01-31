import 'package:flutter/material.dart';
import 'package:perplexity_clone/theme/colors.dart';

class SideBarButton extends StatefulWidget {
  final bool isCollapsed;
  final IconData icon;
  final String text;

  const SideBarButton({
    super.key,
    required this.isCollapsed,
    required this.icon,
    required this.text,
  });

  @override
  State<SideBarButton> createState() => _SideBarButtonState();
}

class _SideBarButtonState extends State<SideBarButton> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        decoration: BoxDecoration(
          color: isHovered ? AppColors.proButton.withValues(alpha: 0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: widget.isCollapsed
              ? MainAxisAlignment.center
              : MainAxisAlignment.start,
          children: [
            Icon(
              widget.icon,
              color: AppColors.iconGrey,
              size: 22,
            ),
            if (!widget.isCollapsed) ...[
              const SizedBox(width: 12),
              Text(
                widget.text,
                style: const TextStyle(
                  color: AppColors.textGrey,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}