import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_design_system.dart';
import '../../../../shared/widgets/app_components.dart';
import '../../../../shared/widgets/glass_panel.dart';
import '../../../../shared/widgets/premium_scaffold.dart';
import '../controllers/quran_controller.dart';

class QuranSearchScreen extends ConsumerStatefulWidget {
  const QuranSearchScreen({super.key});

  @override
  ConsumerState<QuranSearchScreen> createState() => _QuranSearchScreenState();
}

class _QuranSearchScreenState extends ConsumerState<QuranSearchScreen> {
  final _controller = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final resultsAsync = ref.watch(quranSearchProvider(_query));

    return PremiumScaffold(
      title: 'Ayet Ara',
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            sliver: SliverToBoxAdapter(
              child: GlassPanel(
                borderRadius: 28,
                shadow: false,
                child: TextField(
                  controller: _controller,
                  autofocus: true,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.search_outlined),
                    hintText: 'Meal veya Arapça metin ara',
                    border: InputBorder.none,
                  ),
                  textInputAction: TextInputAction.search,
                  onChanged: (value) => setState(() => _query = value),
                ),
              ),
            ),
          ),
          if (_query.trim().length < 2)
            const SliverFillRemaining(
              hasScrollBody: false,
              child: EmptyState(
                title: 'Aramak için en az 2 karakter yazın',
                icon: Icons.search_outlined,
              ),
            )
          else
            resultsAsync.when(
              data: (results) {
                if (results.isEmpty) {
                  return const SliverFillRemaining(
                    hasScrollBody: false,
                    child: EmptyState(
                      title: 'Sonuç bulunamadı',
                      message: 'Farklı bir kelime deneyebilirsiniz.',
                      icon: Icons.search_off_outlined,
                    ),
                  );
                }

                return SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 112),
                  sliver: SliverList.builder(
                    itemCount: results.length,
                    itemBuilder: (context, index) {
                      final ayah = results[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: GlassPanel(
                          borderRadius: 24,
                          shadow: false,
                          onTap: () => context.push(
                            '/quran/surah/${ayah.surahNumber}?ayah=${ayah.ayahNumber}',
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${ayah.surahNumber}:${ayah.ayahNumber}',
                                style: Theme.of(context).textTheme.labelLarge
                                    ?.copyWith(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w900,
                                    ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                ayah.turkishTranslation,
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
              loading: () => const SliverFillRemaining(
                hasScrollBody: false,
                child: LoadingState(title: 'Aranıyor'),
              ),
              error: (error, stackTrace) => SliverFillRemaining(
                hasScrollBody: false,
                child: ErrorState(
                  title: 'Arama yapılamadı',
                  message: error.toString(),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
