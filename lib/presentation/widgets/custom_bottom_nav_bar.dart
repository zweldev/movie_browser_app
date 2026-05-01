import 'package:flutter/material.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  const CustomBottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 20),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.black.withValues(alpha: 0.55)
            : colorScheme.surface.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.14)
              : colorScheme.outlineVariant.withValues(alpha: 0.65),
          width: 0.6,
        ),
      ),
      child: Row(
        children: [
          _NavItem(
            icon: Icons.movie_outlined,
            selectedIcon: Icons.movie,
            label: 'Movies',
            isSelected: selectedIndex == 0,
            isDark: isDark,
            colorScheme: colorScheme,
            onTap: () => onDestinationSelected(0),
          ),
          _NavItem(
            icon: Icons.search_outlined,
            selectedIcon: Icons.search,
            label: 'Search',
            isSelected: selectedIndex == 1,
            isDark: isDark,
            colorScheme: colorScheme,
            onTap: () => onDestinationSelected(1),
          ),
          _NavItem(
            icon: Icons.favorite_border,
            selectedIcon: Icons.favorite,
            label: 'Favorites',
            isSelected: selectedIndex == 2,
            isDark: isDark,
            colorScheme: colorScheme,
            onTap: () => onDestinationSelected(2),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final bool isSelected;
  final bool isDark;
  final ColorScheme colorScheme;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.isSelected,
    required this.isDark,
    required this.colorScheme,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: isSelected
                  ? (isDark
                      ? Colors.white.withValues(alpha: 0.12)
                      : colorScheme.surfaceContainerHighest
                          .withValues(alpha: 0.92))
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              isSelected ? selectedIcon : icon,
              size: isSelected ? 20 : 18,
              color: isSelected
                  ? colorScheme.onSurface
                  : colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
        ),
      ),
    );
  }
}
