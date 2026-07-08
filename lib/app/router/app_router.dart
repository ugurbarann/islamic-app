import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/daily_content/presentation/screens/daily_content_screen.dart';
import '../../features/duas/presentation/screens/dua_detail_screen.dart';
import '../../features/duas/presentation/screens/dua_list_screen.dart';
import '../../features/duas/presentation/screens/duas_screen.dart';
import '../../features/duas/presentation/screens/favorite_duas_screen.dart';
import '../../features/friday_reminder/presentation/screens/friday_reminder_screen.dart';
import '../../features/explore/presentation/screens/explore_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/islamic_knowledge/presentation/screens/esmaul_husna_detail_screen.dart';
import '../../features/islamic_knowledge/presentation/screens/esmaul_husna_screen.dart';
import '../../features/islamic_knowledge/presentation/screens/islamic_knowledge_screen.dart';
import '../../features/islamic_knowledge/presentation/screens/knowledge_article_detail_screen.dart';
import '../../features/islamic_knowledge/presentation/screens/knowledge_article_list_screen.dart';
import '../../features/nearby_mosques/presentation/screens/nearby_mosques_screen.dart';
import '../../features/prayer_times/presentation/screens/city_district_selection_screen.dart';
import '../../features/prayer_times/presentation/screens/prayer_notifications_screen.dart';
import '../../features/prayer_times/presentation/screens/prayer_times_screen.dart';
import '../../features/qibla/presentation/screens/qibla_screen.dart';
import '../../features/quran/presentation/screens/quran_bookmarks_screen.dart';
import '../../features/quran/presentation/screens/quran_last_read_screen.dart';
import '../../features/quran/presentation/screens/quran_screen.dart';
import '../../features/quran/presentation/screens/quran_search_screen.dart';
import '../../features/quran/presentation/screens/surah_detail_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import '../../features/tasbih/presentation/screens/tasbih_screen.dart';
import '../../features/wallpapers/presentation/screens/wallpaper_detail_screen.dart';
import '../../features/wallpapers/presentation/screens/wallpapers_screen.dart';
import '../../shared/widgets/app_scaffold.dart';
import '../../shared/widgets/placeholder_feature_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return AppScaffold(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/',
                builder: (context, state) => const HomeScreen(),
              ),
              GoRoute(
                path: '/home/prayer',
                builder: (context, state) => const PrayerTimesScreen(),
                routes: [
                  GoRoute(
                    path: 'location',
                    builder: (context, state) =>
                        const CityDistrictSelectionScreen(),
                  ),
                  GoRoute(
                    path: 'notifications',
                    builder: (context, state) =>
                        const PrayerNotificationsScreen(),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/daily',
                builder: (context, state) => const DailyContentScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/quran',
                builder: (context, state) => const QuranScreen(),
                routes: [
                  GoRoute(
                    path: 'search',
                    builder: (context, state) => const QuranSearchScreen(),
                  ),
                  GoRoute(
                    path: 'surah/:surahNumber',
                    builder: (context, state) => SurahDetailScreen(
                      surahNumber: int.parse(
                        state.pathParameters['surahNumber']!,
                      ),
                      initialAyahNumber: int.tryParse(
                        state.uri.queryParameters['ayah'] ?? '',
                      ),
                    ),
                  ),
                  GoRoute(
                    path: 'bookmarks',
                    builder: (context, state) => const QuranBookmarksScreen(),
                  ),
                  GoRoute(
                    path: 'last-read',
                    builder: (context, state) => const QuranLastReadScreen(),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/explore',
                builder: (context, state) => const ExploreScreen(),
              ),
              GoRoute(
                path: '/knowledge',
                builder: (context, state) => const IslamicKnowledgeScreen(),
                routes: [
                  GoRoute(
                    path: 'category/:categoryId',
                    builder: (context, state) => KnowledgeArticleListScreen(
                      categoryId: state.pathParameters['categoryId']!,
                    ),
                  ),
                  GoRoute(
                    path: 'article/:articleId',
                    builder: (context, state) => KnowledgeArticleDetailScreen(
                      articleId: state.pathParameters['articleId']!,
                    ),
                  ),
                  GoRoute(
                    path: 'esmaul-husna',
                    builder: (context, state) => const EsmaulHusnaScreen(),
                    routes: [
                      GoRoute(
                        path: ':nameId',
                        builder: (context, state) => EsmaulHusnaDetailScreen(
                          nameId: int.parse(state.pathParameters['nameId']!),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              GoRoute(
                path: '/mosques',
                builder: (context, state) => const NearbyMosquesScreen(),
              ),
              GoRoute(
                path: '/friday-reminder',
                builder: (context, state) => const FridayReminderScreen(),
              ),
              GoRoute(
                path: '/qibla',
                builder: (context, state) => const QiblaScreen(),
              ),
              GoRoute(
                path: '/tasbih',
                builder: (context, state) => const TasbihScreen(),
              ),
              GoRoute(
                path: '/duas',
                builder: (context, state) => const DuasScreen(),
                routes: [
                  GoRoute(
                    path: 'category/:categoryId',
                    builder: (context, state) => DuaListScreen(
                      categoryId: state.pathParameters['categoryId']!,
                    ),
                  ),
                  GoRoute(
                    path: 'favorites',
                    builder: (context, state) => const FavoriteDuasScreen(),
                  ),
                  GoRoute(
                    path: ':duaId',
                    builder: (context, state) =>
                        DuaDetailScreen(duaId: state.pathParameters['duaId']!),
                  ),
                ],
              ),
              GoRoute(
                path: '/wallpapers',
                builder: (context, state) => const WallpapersScreen(),
                routes: [
                  GoRoute(
                    path: ':wallpaperId',
                    builder: (context, state) => WallpaperDetailScreen(
                      wallpaperId: state.pathParameters['wallpaperId']!,
                    ),
                  ),
                ],
              ),
              GoRoute(
                path: '/prayer',
                builder: (context, state) => const PrayerTimesScreen(),
                routes: [
                  GoRoute(
                    path: 'location',
                    builder: (context, state) =>
                        const CityDistrictSelectionScreen(),
                  ),
                  GoRoute(
                    path: 'notifications',
                    builder: (context, state) =>
                        const PrayerNotificationsScreen(),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/settings',
                builder: (context, state) => const SettingsScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => PlaceholderFeatureScreen(
      title: 'Sayfa Bulunamadı',
      description: state.uri.toString(),
      icon: Icons.error_outline,
    ),
  );
});
