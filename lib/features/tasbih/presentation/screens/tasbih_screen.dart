import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';

import '../../../../shared/widgets/glass_panel.dart';
import '../../../../shared/widgets/premium_scaffold.dart';
import '../controllers/tasbih_controller.dart';

class TasbihScreen extends ConsumerWidget {
  const TasbihScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasbihAsync = ref.watch(tasbihControllerProvider);

    return PremiumScaffold(
      title: 'Tesbih',
      body: tasbihAsync.when(
        data: (state) => ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 112),
          children: [
            _CounterSurface(count: state.count),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      ref.read(tasbihControllerProvider.notifier).reset();
                    },
                    icon: const Icon(Icons.refresh_outlined),
                    label: const Text('Sıfırla'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: state.count == 0
                        ? null
                        : () {
                            ref
                                .read(tasbihControllerProvider.notifier)
                                .saveSession();
                          },
                    icon: const Icon(Icons.save_outlined),
                    label: const Text('Kaydet'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: state.sessions.isEmpty
                  ? null
                  : () {
                      ref
                          .read(tasbihControllerProvider.notifier)
                          .continueLatestSession();
                    },
              icon: const Icon(Icons.play_arrow_outlined),
              label: const Text('Devam Et'),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Zikir Geçmişi',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                TextButton.icon(
                  onPressed: () => _confirmClearHistory(context, ref),
                  icon: const Icon(Icons.delete_outline_rounded),
                  label: const Text('Tüm Geçmişi Sil'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (state.sessions.isEmpty)
              const PremiumListTile(
                title: 'Henüz kayıtlı zikir yok.',
                leading: Icon(Icons.history_outlined),
              )
            else
              for (final session in state.sessions)
                PremiumListTile(
                  leading: const Icon(Icons.history_outlined),
                  title: '${session.count} zikir',
                  subtitle: _formatDateTime(session.savedAt),
                ),
          ],
        ),
        loading: () =>
            const PremiumStateView(title: 'Tesbih yükleniyor', loading: true),
        error: (error, stackTrace) => PremiumStateView(
          title: 'Tesbih yüklenemedi',
          message: error.toString(),
          icon: Icons.error_outline,
        ),
      ),
    );
  }
}

class _CounterSurface extends ConsumerWidget {
  const _CounterSurface({required this.count});

  final int count;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final hapticEnabled =
        ref
            .watch(tasbihPreferencesControllerProvider)
            .asData
            ?.value
            .hapticFeedbackEnabled ??
        true;

    return GlassPanel(
      borderRadius: 34,
      padding: EdgeInsets.zero,
      onTap: () {
        if (hapticEnabled) {
          HapticFeedback.selectionClick();
        }
        ref.read(tasbihControllerProvider.notifier).increment();
      },
      child: SizedBox(
        height: 260,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Tesbih', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            Text(
              '$count',
              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                color: colorScheme.primary,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 12),
            const Text('Artırmak için dokunun'),
          ],
        ),
      ),
    );
  }
}

Future<void> _confirmClearHistory(BuildContext context, WidgetRef ref) async {
  final state = ref.read(tasbihControllerProvider).asData?.value;
  if (state == null || state.sessions.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Silinecek zikir geçmişi yok.')),
    );
    return;
  }

  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Zikir geçmişi silinsin mi?'),
      content: const Text(
        'Kaydedilen tüm zikir geçmişi silinecek. Bu işlem geri alınamaz.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Vazgeç'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('Sil'),
        ),
      ],
    ),
  );

  if (confirmed != true) {
    return;
  }

  final cleared = await ref
      .read(tasbihControllerProvider.notifier)
      .clearHistory();
  if (!context.mounted) {
    return;
  }
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        cleared ? 'Zikir geçmişi silindi.' : 'Silinecek zikir geçmişi yok.',
      ),
    ),
  );
}

String _formatDateTime(DateTime value) {
  final day = value.day.toString().padLeft(2, '0');
  final month = value.month.toString().padLeft(2, '0');
  final year = value.year.toString();
  final hour = value.hour.toString().padLeft(2, '0');
  final minute = value.minute.toString().padLeft(2, '0');
  return '$day.$month.$year $hour:$minute';
}
