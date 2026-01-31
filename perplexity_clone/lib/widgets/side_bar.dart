import 'package:flutter/material.dart';
import 'package:perplexity_clone/theme/colors.dart';
import 'package:perplexity_clone/widgets/side_bar_button.dart';


class SideBar extends StatefulWidget {
  const SideBar({super.key});

  @override
  State<SideBar> createState() => _SideBarState();
}

class _SideBarState extends State<SideBar> {
  bool isCollapsed = true;
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    // Expand if user manually opened it OR if hovering
    final bool isWide = !isCollapsed || isHovered;

    return MouseRegion(
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        width: isWide ? 150 : 64,
        color: AppColors.sideNav,
        child: Column(
          children: [
            const SizedBox(height: 16),
            Icon(
              Icons.auto_awesome_mosaic,
              color: AppColors.whiteColor,
              size: isWide ? 60 : 30,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: !isWide
                    ? CrossAxisAlignment.center
                    : CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),
                  SideBarButton(
                    isCollapsed: !isWide,
                    icon: Icons.add,
                    text: "Home",
                  ),
                  SideBarButton(
                    isCollapsed: !isWide,
                    icon: Icons.search,
                    text: "Search",
                  ),
                  SideBarButton(
                    isCollapsed: !isWide,
                    icon: Icons.language,
                    text: "Spaces",
                  ),
                  SideBarButton(
                    isCollapsed: !isWide,
                    icon: Icons.auto_awesome,
                    text: "Discover",
                  ),
                  SideBarButton(
                    isCollapsed: !isWide,
                    icon: Icons.cloud_outlined,
                    text: "Library",
                  ),
                  const Spacer(),
                ],
              ),
            ),
            GestureDetector(
              onTap: () {
                setState(() {
                  isCollapsed = !isCollapsed;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 100),
                margin: EdgeInsets.symmetric(vertical: 14),
                child: Icon(
                  isCollapsed
                      ? Icons.keyboard_arrow_right
                      : Icons.keyboard_arrow_left,
                  color: AppColors.iconGrey,
                  size: 22,
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}