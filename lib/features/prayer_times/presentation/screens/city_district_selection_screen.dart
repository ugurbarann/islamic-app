import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

import '../../../../shared/widgets/app_components.dart';
import '../../../../shared/widgets/premium_scaffold.dart';
import '../../domain/entities/current_location_resolution.dart';
import '../../domain/entities/turkish_city.dart';
import '../../domain/entities/turkish_district.dart';
import '../controllers/prayer_location_controller.dart';

class CityDistrictSelectionScreen extends ConsumerStatefulWidget {
  const CityDistrictSelectionScreen({super.key});

  @override
  ConsumerState<CityDistrictSelectionScreen> createState() =>
      _CityDistrictSelectionScreenState();
}

class _CityDistrictSelectionScreenState
    extends ConsumerState<CityDistrictSelectionScreen> {
  String? _locationMessage;
  CurrentLocationResolutionStatus? _locationStatus;
  bool _isResolvingLocation = false;

  @override
  Widget build(BuildContext context) {
    final citiesAsync = ref.watch(turkishCitiesProvider);
    final selectedLocationAsync = ref.watch(
      selectedPrayerLocationControllerProvider,
    );

    return PremiumScaffold(
      title: 'Şehir ve İlçe Seçimi',
      body: selectedLocationAsync.when(
        data: (selectedLocation) {
          final districtsAsync = ref.watch(
            turkishDistrictsProvider(selectedLocation.city.id),
          );

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 112),
            children: [
              AppListTile(
                leading: const Icon(Icons.location_city_outlined),
                title:
                    '${selectedLocation.city.name} / ${selectedLocation.district.name}',
                subtitle: 'Seçili namaz vakti konumu',
              ),
              const SizedBox(height: 12),
              _LocationPromptCard(
                isResolving: _isResolvingLocation,
                message: _locationMessage,
                status: _locationStatus,
                onUseLocation: _useCurrentLocation,
              ),
              const SizedBox(height: 20),
              Text('Şehir', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              citiesAsync.when(
                data: (cities) => _CitySelector(
                  cities: cities,
                  selectedCityId: selectedLocation.city.id,
                ),
                loading: () => const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: CircularProgressIndicator(),
                  ),
                ),
                error: (error, stackTrace) => _ErrorMessage(
                  message: 'Şehir listesi yüklenemedi.',
                  details: error.toString(),
                ),
              ),
              const SizedBox(height: 24),
              Text('İlçe', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              districtsAsync.when(
                data: (districts) => _DistrictSelector(
                  districts: districts,
                  selectedDistrictId: selectedLocation.district.id,
                ),
                loading: () => const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: CircularProgressIndicator(),
                  ),
                ),
                error: (error, stackTrace) => _ErrorMessage(
                  message: 'İlçe listesi yüklenemedi.',
                  details: error.toString(),
                ),
              ),
            ],
          );
        },
        loading: () => const PremiumStateView(
          title: 'Seçili konum yükleniyor',
          loading: true,
        ),
        error: (error, stackTrace) => _ErrorMessage(
          message: 'Seçili konum yüklenemedi.',
          details: error.toString(),
        ),
      ),
    );
  }

  Future<void> _useCurrentLocation() async {
    setState(() {
      _isResolvingLocation = true;
      _locationMessage = null;
    });

    final resolution = await ref
        .read(selectedPrayerLocationControllerProvider.notifier)
        .useCurrentLocation();

    if (!mounted) {
      return;
    }

    setState(() {
      _isResolvingLocation = false;
      _locationStatus = resolution.status;
      _locationMessage = _messageForResolution(resolution);
    });
  }

  String _messageForResolution(CurrentLocationResolution resolution) {
    final location = resolution.location;
    switch (resolution.status) {
      case CurrentLocationResolutionStatus.resolved:
        if (location == null) {
          return 'Konum çözümlenemedi. Şehir seçerek devam edebilirsiniz.';
        }
        return '${location.city.name} / ${location.district.name} seçildi.';
      case CurrentLocationResolutionStatus.permissionDenied:
        return 'Konum izni verilmedi. Tekrar deneyebilir veya şehir seçebilirsiniz.';
      case CurrentLocationResolutionStatus.permissionPermanentlyDenied:
        return 'Konum izni daha önce kapatılmış. iPhone Ayarları’ndan İslami Cep için konumu açın.';
      case CurrentLocationResolutionStatus.serviceDisabled:
        return 'Konum servisleri kapalı. Şehir seçerek devam edebilirsiniz.';
      case CurrentLocationResolutionStatus.unresolved:
        return 'Konum çözümlenemedi. Şehir seçerek devam edebilirsiniz.';
    }
  }
}

class _LocationPromptCard extends StatelessWidget {
  const _LocationPromptCard({
    required this.isResolving,
    required this.onUseLocation,
    this.message,
    this.status,
  });

  final bool isResolving;
  final String? message;
  final CurrentLocationResolutionStatus? status;
  final VoidCallback onUseLocation;

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      child: Padding(
        padding: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.my_location_outlined),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Konumla otomatik seçim',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'İsterseniz konumunuzu kullanarak desteklenen en yakın şehir ve '
              'ilçeyi otomatik seçebiliriz.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: isResolving ? null : onUseLocation,
              icon: isResolving
                  ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.my_location_outlined),
              label: const Text('Konumumu Kullan'),
            ),
            if (message != null) ...[
              const SizedBox(height: 12),
              Text(message!),
            ],
            if (status ==
                CurrentLocationResolutionStatus.permissionPermanentlyDenied)
              TextButton.icon(
                onPressed: Geolocator.openAppSettings,
                icon: const Icon(Icons.settings_outlined),
                label: const Text('Uygulama Ayarlarını Aç'),
              )
            else if (status == CurrentLocationResolutionStatus.serviceDisabled)
              TextButton.icon(
                onPressed: Geolocator.openLocationSettings,
                icon: const Icon(Icons.location_on_outlined),
                label: const Text('Konum Servislerini Aç'),
              ),
          ],
        ),
      ),
    );
  }
}

class _CitySelector extends ConsumerWidget {
  const _CitySelector({required this.cities, required this.selectedCityId});

  final List<TurkishCity> cities;
  final String selectedCityId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final city in cities)
          ChoiceChip(
            label: Text(city.name),
            selected: city.id == selectedCityId,
            onSelected: (_) {
              ref
                  .read(selectedPrayerLocationControllerProvider.notifier)
                  .selectCity(city);
            },
          ),
      ],
    );
  }
}

class _DistrictSelector extends ConsumerWidget {
  const _DistrictSelector({
    required this.districts,
    required this.selectedDistrictId,
  });

  final List<TurkishDistrict> districts;
  final String selectedDistrictId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        for (final district in districts)
          AppListTile(
            title: district.name,
            trailing: district.id == selectedDistrictId
                ? const Icon(Icons.check_circle)
                : const Icon(Icons.circle_outlined),
            onTap: () {
              ref
                  .read(selectedPrayerLocationControllerProvider.notifier)
                  .selectDistrict(district);
            },
          ),
      ],
    );
  }
}

class _ErrorMessage extends StatelessWidget {
  const _ErrorMessage({required this.message, required this.details});

  final String message;
  final String details;

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      child: Padding(
        padding: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(message, style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 4),
            Text(details),
          ],
        ),
      ),
    );
  }
}
