import 'package:flutter/material.dart';

class GlassPanel extends StatelessWidget {
  const GlassPanel({
    required this.child,
    this.padding = const EdgeInsets.all(18),
    this.borderRadius = 28,
    this.color,
    this.onTap,
    this.shadow = true,
    super.key,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final Color? color;
  final VoidCallback? onTap;
  final bool shadow;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(borderRadius);
    final panel = Ink(
      padding: padding,
      decoration: BoxDecoration(
        borderRadius: radius,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color ?? Colors.white.withValues(alpha: 0.82),
            (color ?? const Color(0xFFEAF6FF)).withValues(alpha: 0.64),
          ],
        ),
        border: Border.all(color: Colors.white.withValues(alpha: 0.72)),
        boxShadow: shadow
            ? [
                BoxShadow(
                  color: const Color(0xFF4F83C5).withValues(alpha: 0.07),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ]
            : null,
      ),
      child: child,
    );

    return ClipRRect(
      borderRadius: radius,
      child: Material(
        color: Colors.transparent,
        child: onTap == null ? panel : InkWell(onTap: onTap, child: panel),
      ),
    );
  }
}
