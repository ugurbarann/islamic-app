import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/config/app_config.dart';
import '../../../../shared/widgets/app_components.dart';
import '../../../../shared/widgets/premium_scaffold.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PremiumScaffold(
      title: 'Gizlilik Politikası',
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 112),
        children: [
          const SoftCard(child: _PolicyText()),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: () => launchUrl(
              Uri.parse(AppConfig.privacyPolicyUrl),
              mode: LaunchMode.externalApplication,
            ),
            icon: const Icon(Icons.open_in_new_rounded),
            label: const Text('Web Sürümünü Aç'),
          ),
        ],
      ),
    );
  }
}

class _PolicyText extends StatelessWidget {
  const _PolicyText();

  @override
  Widget build(BuildContext context) {
    final bodyStyle = Theme.of(context).textTheme.bodyMedium;
    final titleStyle = Theme.of(
      context,
    ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Son güncelleme: 10 Temmuz 2026', style: bodyStyle),
        const SizedBox(height: 16),
        Text('Toplanan ve kullanılan veriler', style: titleStyle),
        const SizedBox(height: 6),
        Text(
          'İslami Cep hesap oluşturmaz, reklam göstermez ve kullanıcıları '
          'izlemez. İzin verdiğinizde hassas konum; namaz vakti için il/ilçe '
          'seçmek, kıble yönünü hesaplamak ve yakındaki camileri göstermek '
          'amacıyla kullanılır. Konum izni isteğe bağlıdır.',
          style: bodyStyle,
        ),
        const SizedBox(height: 16),
        Text('Üçüncü taraf hizmetleri', style: titleStyle),
        const SizedBox(height: 6),
        Text(
          'Günlük içerik için Google Firebase/Firestore, namaz vakitleri için '
          'Ezan Vakti servisi, konum çözümleme ve cami araması için '
          'Google Maps Platform veya OpenStreetMap tabanlı hizmetler '
          'kullanılabilir. Bu hizmetlere yalnız ilgili özelliğin çalışması '
          'için gerekli istekler gönderilir.',
          style: bodyStyle,
        ),
        const SizedBox(height: 16),
        Text('Cihazda saklanan veriler', style: titleStyle),
        const SizedBox(height: 6),
        Text(
          'Seçtiğiniz şehir/ilçe, tema ve bildirim tercihleri, favoriler, '
          'okuma konumu ile çevrimdışı kullanılacak içerik ve cami önbelleği '
          'cihazınızda saklanır. Bunları uygulamayı kaldırarak veya ilgili '
          'önbellek temizleme seçeneğiyle silebilirsiniz.',
          style: bodyStyle,
        ),
        const SizedBox(height: 16),
        Text('Paylaşım, saklama ve haklarınız', style: titleStyle),
        const SizedBox(height: 6),
        Text(
          'Kişisel veriler satılmaz ve reklam amacıyla paylaşılmaz. Konum '
          'iznini iOS Ayarları üzerinden istediğiniz zaman kapatabilirsiniz. '
          'Uygulamanın işlettiği bir kullanıcı hesabı bulunmadığından '
          'sunucuda kullanıcı profili tutulmaz.',
          style: bodyStyle,
        ),
        const SizedBox(height: 16),
        Text('İletişim', style: titleStyle),
        const SizedBox(height: 6),
        Text(
          'Gizlilik veya destek talepleri için admin@ugurbaran.com adresine '
          'ulaşabilirsiniz. Veri uygulamalarımız değişirse bu politika '
          'güncellenir.',
          style: bodyStyle,
        ),
      ],
    );
  }
}
