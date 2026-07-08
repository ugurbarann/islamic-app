import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/widgets/app_components.dart';
import '../../../../shared/widgets/premium_scaffold.dart';
import '../controllers/friday_reminder_controller.dart';

class FridayReminderScreen extends ConsumerWidget {
  const FridayReminderScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final preferenceAsync = ref.watch(fridayReminderControllerProvider);

    return PremiumScaffold(
      title: 'Cuma Hatırlatıcısı',
      body: preferenceAsync.when(
        data: (preference) => ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 112),
          children: [
            SoftCard(
              child: SwitchListTile(
                secondary: const Icon(Icons.event_available_outlined),
                title: const Text('Cuma Hatırlatıcısı'),
                subtitle: const Text('Her cuma 10:00\'da hatırlat'),
                value: preference.enabled,
                onChanged: (value) async {
                  final granted = await ref
                      .read(fridayReminderControllerProvider.notifier)
                      .setEnabled(value);
                  if (!context.mounted || granted) {
                    return;
                  }
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Bildirim izni verilmedi. Hatırlatıcı kapalı kaldı.',
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            AppListTile(
              leading: const Icon(Icons.notifications_active_outlined),
              title: preference.enabled
                  ? 'Yerel bildirim aktif'
                  : 'Yerel bildirim kapalı',
              subtitle: preference.enabled
                  ? 'Cuma günleri saat 10:00 için planlandı.'
                  : 'Açtığınızda Android bildirim izni istenir.',
            ),
          ],
        ),
        loading: () => const PremiumStateView(
          title: 'Cuma hatırlatıcısı yükleniyor',
          loading: true,
        ),
        error: (error, stackTrace) => PremiumStateView(
          title: 'Cuma hatırlatıcısı yüklenemedi',
          message: error.toString(),
          icon: Icons.error_outline,
        ),
      ),
    );
  }
}
