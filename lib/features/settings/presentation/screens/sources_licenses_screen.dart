import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../shared/widgets/app_components.dart';
import '../../../../shared/widgets/premium_scaffold.dart';

class SourcesLicensesScreen extends StatelessWidget {
  const SourcesLicensesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PremiumScaffold(
      title: 'Kaynaklar ve Lisanslar',
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 112),
        children: [
          _SourceCard(
            title: 'Kur’an metni ve Türkçe meal',
            description:
                'quran-json 3.1.2 verileri kullanılmıştır. Kaynak paket '
                'CC BY-SA 4.0 lisansı ile sunulur. Arapça metnin kaynak '
                'notu The Noble Qur’an Encyclopedia’ya dayanmaktadır.',
            linkLabel: 'quran-json kaynağını aç',
            url: 'https://github.com/risan/quran-json',
          ),
          const SizedBox(height: 12),
          _SourceCard(
            title: 'Kırk Hadis-i Nevevî',
            description:
                'Türkçe hadis verileri fawazahmed0/hadith-api projesinin '
                'tur-nawawi sürümünden alınmıştır. Kaynak proje Unlicense '
                'ile kamu malı kullanımına sunulmuştur.',
            linkLabel: 'Hadis kaynağını aç',
            url: 'https://github.com/fawazahmed0/hadith-api',
          ),
          const SizedBox(height: 12),
          _SourceCard(
            title: 'Konum ve cami verileri',
            description:
                'Cami ve adres sonuçları Google Maps Platform veya '
                'OpenStreetMap verilerinden sağlanabilir. OpenStreetMap '
                'verileri Open Data Commons Open Database License (ODbL) '
                'koşullarına tabidir. © OpenStreetMap katkıcıları.',
            linkLabel: 'OpenStreetMap telif bilgisini aç',
            url: 'https://www.openstreetmap.org/copyright',
          ),
          const SizedBox(height: 12),
          _SourceCard(
            title: 'Açık kaynak yazılım lisansları',
            description:
                'Uygulamada kullanılan Flutter ve diğer açık kaynak '
                'paketlerin lisans bildirimlerini görüntüleyebilirsiniz.',
            linkLabel: 'Paket lisanslarını göster',
            onTap: () => showLicensePage(
              context: context,
              applicationName: 'İslami Cep',
              applicationVersion: '1.0.5',
            ),
          ),
        ],
      ),
    );
  }
}

class _SourceCard extends StatelessWidget {
  const _SourceCard({
    required this.title,
    required this.description,
    required this.linkLabel,
    this.url,
    this.onTap,
  });

  final String title;
  final String description;
  final String linkLabel;
  final String? url;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Text(description),
          const SizedBox(height: 10),
          TextButton.icon(
            onPressed:
                onTap ??
                () => launchUrl(
                  Uri.parse(url!),
                  mode: LaunchMode.externalApplication,
                ),
            icon: const Icon(Icons.open_in_new_rounded),
            label: Text(linkLabel),
          ),
        ],
      ),
    );
  }
}
