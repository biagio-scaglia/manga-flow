import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/constants/app_constants.dart';
import 'core/network/rate_limiter.dart';
import 'core/theme/app_theme.dart';
import 'data/api/jikan_api_client.dart';
import 'data/cache/http_cache_manager.dart';
import 'data/repositories/library_repository_impl.dart';
import 'data/repositories/manga_repository_impl.dart';
import 'data/storage/json_storage.dart';
import 'domain/repositories/library_repository.dart';
import 'domain/repositories/manga_repository.dart';
import 'presentation/controllers/library_controller.dart';
import 'presentation/controllers/search_controller.dart';
import 'presentation/controllers/settings_controller.dart';
import 'presentation/screens/main_shell.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inizializzazione Core Data & Storage
  final prefs = await SharedPreferences.getInstance();
  final jsonStorage = JsonStorage();
  final cacheManager = HttpCacheManager();
  await cacheManager.init();

  final rateLimiter = RateLimiter(
    maxRequests: AppConstants.rateLimitRequests,
    window: AppConstants.rateLimitWindow,
    minInterval: AppConstants.minRequestInterval,
  );

  final apiClient = JikanApiClient(
    rateLimiter: rateLimiter,
    cacheManager: cacheManager,
  );

  // Repositories
  final LibraryRepository libraryRepository = LibraryRepositoryImpl(
    storage: jsonStorage,
  );
  final MangaRepository mangaRepository = MangaRepositoryImpl(
    apiClient: apiClient,
    cacheManager: cacheManager,
  );

  runApp(
    MultiProvider(
      providers: [
        // Repository Providers
        Provider<LibraryRepository>.value(value: libraryRepository),
        Provider<MangaRepository>.value(value: mangaRepository),

        // Presentation Controllers
        ChangeNotifierProvider<SettingsController>(
          create: (_) => SettingsController(
            libraryRepository: libraryRepository,
            mangaRepository: mangaRepository,
            preferences: prefs,
          ),
        ),
        ChangeNotifierProvider<LibraryController>(
          create: (_) => LibraryController(repository: libraryRepository),
        ),
        ChangeNotifierProvider<MangaSearchController>(
          create: (_) => MangaSearchController(repository: mangaRepository),
        ),
      ],
      child: const MangaLibraryApp(),
    ),
  );
}

class MangaLibraryApp extends StatelessWidget {
  const MangaLibraryApp({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsCtrl = context.watch<SettingsController>();

    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: settingsCtrl.themeMode,
      home: const MainShell(),
    );
  }
}
