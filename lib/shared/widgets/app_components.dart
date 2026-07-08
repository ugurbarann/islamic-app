import 'package:flutter/material.dart';

import '../../app/theme/app_design_system.dart';
import 'glass_panel.dart';
import 'premium_scaffold.dart';

class AppHeader extends StatelessWidget {
  const AppHeader({
    required this.title,
    this.subtitle,
    this.trailing,
    super.key,
  });

  final String title;
  final String? subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.headlineMedium),
              if (subtitle != null) ...[
                const SizedBox(height: AppSpacing.xs),
                Text(
                  subtitle!,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.muted,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ],
          ),
        ),
        ?trailing,
      ],
    );
  }
}

class GlassCard extends GlassPanel {
  const GlassCard({
    required super.child,
    super.padding,
    super.borderRadius,
    super.color,
    super.onTap,
    super.shadow,
    super.key,
  });
}

class SoftCard extends GlassPanel {
  const SoftCard({
    required super.child,
    super.padding = const EdgeInsets.all(AppSpacing.md),
    super.borderRadius = AppRadii.lg,
    super.onTap,
    super.key,
  }) : super(color: AppColors.surfaceGlass, shadow: false);
}

class AppSectionHeader extends PremiumSectionHeader {
  const AppSectionHeader({
    required super.title,
    super.actionLabel,
    super.onAction,
    super.key,
  });
}

class AppListTile extends PremiumListTile {
  const AppListTile({
    required super.title,
    super.subtitle,
    super.leading,
    super.trailing,
    super.onTap,
    super.isThreeLine,
    super.key,
  });
}

class AppFeatureTile extends StatelessWidget {
  const AppFeatureTile({
    required this.label,
    required this.icon,
    this.onTap,
    super.key,
  });

  final String label;
  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(
        vertical: AppSpacing.md,
        horizontal: AppSpacing.xs,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppColors.primary, size: 28),
          const SizedBox(height: AppSpacing.xs),
          FittedBox(
            child: Text(
              label,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: AppColors.ink,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AppPrimaryButton extends StatelessWidget {
  const AppPrimaryButton({
    required this.label,
    required this.onPressed,
    this.icon,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    if (icon == null) {
      return FilledButton(onPressed: onPressed, child: Text(label));
    }
    return FilledButton.icon(
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(label),
    );
  }
}

class AppSecondaryButton extends StatelessWidget {
  const AppSecondaryButton({
    required this.label,
    required this.onPressed,
    this.icon,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    if (icon == null) {
      return OutlinedButton(onPressed: onPressed, child: Text(label));
    }
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(label),
    );
  }
}

class AppIconButton extends StatelessWidget {
  const AppIconButton({
    required this.icon,
    required this.onPressed,
    this.tooltip,
    super.key,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.surface.withValues(alpha: 0.82),
        boxShadow: AppShadows.soft,
      ),
      child: IconButton(
        tooltip: tooltip,
        onPressed: onPressed,
        color: AppColors.primary,
        icon: Icon(icon),
      ),
    );
  }
}

class EmptyState extends PremiumStateView {
  const EmptyState({
    required super.title,
    super.message,
    super.icon = Icons.inbox_outlined,
    super.key,
  });
}

class ErrorState extends PremiumStateView {
  const ErrorState({
    required super.title,
    super.message,
    super.icon = Icons.error_outline,
    super.key,
  });
}

class LoadingState extends PremiumStateView {
  const LoadingState({required super.title, super.key}) : super(loading: true);
}

class AppPage extends PremiumScaffold {
  const AppPage({
    required super.title,
    required super.body,
    super.actions,
    super.bottomNavigationBar,
    super.key,
  });
}
