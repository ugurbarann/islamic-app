import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'ad_config.dart';
import 'ad_providers.dart';

class AdPrivacyOptionsButton extends ConsumerStatefulWidget {
  const AdPrivacyOptionsButton({super.key});

  @override
  ConsumerState<AdPrivacyOptionsButton> createState() =>
      _AdPrivacyOptionsButtonState();
}

class _AdPrivacyOptionsButtonState
    extends ConsumerState<AdPrivacyOptionsButton> {
  bool _isRequired = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _refreshRequirement();
  }

  Future<void> _refreshRequirement() async {
    if (!AdConfig.isSupported) {
      return;
    }
    final isRequired = await ref
        .read(adConsentServiceProvider)
        .isPrivacyOptionsRequired();
    if (mounted) {
      setState(() => _isRequired = isRequired);
    }
  }

  Future<void> _showPrivacyOptions() async {
    setState(() => _isLoading = true);
    final success = await ref
        .read(adConsentServiceProvider)
        .showPrivacyOptions();
    if (!mounted) {
      return;
    }
    setState(() => _isLoading = false);
    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Reklam gizlilik tercihleri şu anda açılamadı.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isRequired) {
      return const SizedBox.shrink();
    }

    return OutlinedButton.icon(
      onPressed: _isLoading ? null : _showPrivacyOptions,
      icon: const Icon(Icons.tune_rounded),
      label: Text(
        _isLoading
            ? 'Gizlilik tercihleri açılıyor'
            : 'Reklam Gizlilik Tercihlerini Yönet',
      ),
    );
  }
}
