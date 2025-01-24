import 'package:smallnews/data/data.dart';
import 'package:smallnews/controller/services/services.dart';

/// A service class for managing key-value storage operations related to recent searches.
class KeyValueStorageService {
  /// The key used to store recent searches in the key-value storage.
  static const _recentSearchesKey = 'recentSearches';

  /// Maximum number of searches to cache in memory
  static const _maxCacheSize = 5;

  /// In-memory cache for recent searches
  static final List<Article> _searchCache = [];

  /// An instance of the key-value storage base class.
  static final _keyValueStorage = KeyValueStorageBase();

  /// Retrieves the list of recent searches from the key-value storage.
  ///
  /// Returns a [Future] that completes with a list of [Article] objects.
  static Future<List<Article>> getRecentSearches() async {
    // Return cached results if available
    if (_searchCache.isNotEmpty) {
      return List.from(_searchCache);
    }

    // Fetch the recent searches from the key-value storage.
    final recentSearches = _keyValueStorage.getCommon<List>(_recentSearchesKey);

    final articles = recentSearches != null
        ? recentSearches.map((e) => Article.fromJson(e)).toList()
        : <Article>[];

    // Update cache with stored results
    _updateCache(articles);
    return List.from(_searchCache);
  }

  /// Updates the in-memory cache with new articles
  static void _updateCache(List<Article> articles) {
    _searchCache.clear();
    _searchCache.addAll(articles.take(_maxCacheSize));
  }

  /// Saves the list of recent searches to both cache and storage.
  ///
  /// [searches] is the list of [Article] objects to be saved.
  static void saveRecentSearches(List<Article> searches) {
    _updateCache(searches);
    _keyValueStorage.setCommon(_recentSearchesKey, searches);
  }

  /// Adds a new [Article] to the list of recent searches.
  ///
  /// [news] is the [Article] object to be added.
  /// Returns a [Future] that completes with a boolean indicating success.
  static Future<bool> addToRecentSearches(Article news) {
    // Update in-memory cache
    _searchCache.insert(0, news);
    if (_searchCache.length > _maxCacheSize) {
      _searchCache.removeLast();
    }

    // Update persistent storage
    final recentSearches =
        _keyValueStorage.getCommon<List>(_recentSearchesKey) ?? [];
    recentSearches.insert(0, news.toJson());
    if (recentSearches.length > _maxCacheSize) {
      recentSearches.removeLast();
    }

    return _keyValueStorage.setCommon(_recentSearchesKey, recentSearches);
  }

  /// Clears the list of recent searches from both cache and storage.
  ///
  /// Returns a [Future] that completes with a boolean indicating success.
  static Future<bool> clearRecentSearches() {
    _searchCache.clear();
    return _keyValueStorage.clearCommonKey(_recentSearchesKey);
  }
}
