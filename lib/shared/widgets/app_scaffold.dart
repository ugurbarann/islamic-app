import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/app_design_system.dart';

class AppScaffold extends StatelessWidget {
  const AppScaffold({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: navigationShell,
      bottomNavigationBar: FloatingBottomNavigation(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: _onDestinationSelected,
      ),
    );
  }

  void _onDestinationSelected(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }
}

class FloatingBottomNavigation extends StatelessWidget {
  const FloatingBottomNavigation({
    required this.selectedIndex,
    required this.onDestinationSelected,
    super.key,
  });

  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bottomInset = MediaQuery.viewPaddingOf(context).bottom;
    final radius = BorderRadius.circular(AppRadii.xxl);

    return Padding(
      padding: EdgeInsets.fromLTRB(18, 0, 18, bottomInset > 0 ? 8 : 12),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: radius,
          boxShadow: AppShadows.dock,
        ),
        child: ClipRRect(
          borderRadius: radius,
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
            child: Container(
              height: 76,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
              decoration: BoxDecoration(
                borderRadius: radius,
                color: isDark
                    ? const Color(0xFF10243F).withValues(alpha: 0.92)
                    : Colors.white.withValues(alpha: 0.90),
                border: Border.all(color: Colors.white.withValues(alpha: 0.72)),
              ),
              child: Row(
                children: [
                  for (var index = 0; index < _items.length; index++)
                    Expanded(
                      child: _FloatingNavItem(
                        item: _items[index],
                        selected: selectedIndex == index,
                        onTap: () => onDestinationSelected(index),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  static const _items = [
    _FloatingNavItemData(
      icon: Icons.home_outlined,
      selectedIcon: Icons.home_rounded,
      label: 'Ana',
      semanticLabel: 'Ana Sayfa',
    ),
    _FloatingNavItemData(
      icon: Icons.today_outlined,
      selectedIcon: Icons.today_rounded,
      label: 'Bugün',
    ),
    _FloatingNavItemData(
      icon: Icons.menu_book_outlined,
      selectedIcon: Icons.menu_book_rounded,
      label: 'Kur\'an',
    ),
    _FloatingNavItemData(
      icon: Icons.explore_outlined,
      selectedIcon: Icons.explore_rounded,
      label: 'Keşfet',
    ),
    _FloatingNavItemData(
      icon: Icons.settings_outlined,
      selectedIcon: Icons.settings_rounded,
      label: 'Ayarlar',
    ),
  ];
}

class _FloatingNavItemData {
  const _FloatingNavItemData({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    this.semanticLabel,
  });

  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final String? semanticLabel;
}

class _FloatingNavItem extends StatelessWidget {
  const _FloatingNavItem({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  final _FloatingNavItemData item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.primary : const Color(0xFF3C4350);

    return Semantics(
      button: true,
      selected: selected,
      label: item.semanticLabel ?? item.label,
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: SizedBox(
          height: 62,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOutCubic,
                width: selected ? 56 : 42,
                height: 34,
                decoration: BoxDecoration(
                  color: selected
                      ? AppColors.primarySoft.withValues(alpha: 0.86)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Icon(
                  selected ? item.selectedIcon : item.icon,
                  color: color,
                  size: 26,
                ),
              ),
              const SizedBox(height: 3),
              SizedBox(
                height: 18,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    item.label,
                    maxLines: 1,
                    softWrap: false,
                    overflow: TextOverflow.visible,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: color,
                      fontSize: 13,
                      height: 1,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
