class AppConstants {
  static const String appName = 'MangaFlow';
  static const String appVersion = '1.0.0';

  // Configurazione API Manga (Kitsu REST API Edge - Aperta, veloce e affidabile)
  static const String apiBaseUrl = 'https://kitsu.io/api/edge';
  static const Duration apiTimeout = Duration(seconds: 12);
  static const int maxSearchLimit = 20;

  // Rate Limiting
  static const int rateLimitRequests = 4;
  static const Duration rateLimitWindow = Duration(seconds: 1);
  static const Duration minRequestInterval = Duration(milliseconds: 250);
  static const int maxRetries = 3;
  static const Duration baseRetryDelay = Duration(milliseconds: 600);

  // Cache
  static const Duration cacheTtl = Duration(hours: 24);
  static const String cacheFileName = 'manga_cache.json';

  // Persistenza Libreria
  static const String libraryFileName = 'library.json';
  static const int currentSchemaVersion = 1;
  static const Duration autosaveDebounce = Duration(milliseconds: 300);

  // Preferenze e Tutorial
  static const String prefThemeMode = 'theme_mode';
  static const String prefReduceAnimations = 'reduce_animations';
  static const String prefTutorialCompleted = 'tutorial_completed';
}
