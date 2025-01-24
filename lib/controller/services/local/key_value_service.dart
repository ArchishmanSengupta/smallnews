import 'package:smallnews/data/data.dart';
import 'package:smallnews/controller/services/services.dart';

/// A service class for managing key-value storage operations related to recent searches.
class KeyValueStorageService {
  /// The key used to store recent searches in the key-value storage.
  static const _recentSearchesKey = 'recentSearches';

  /// An instance of the key-value storage base class.
  static final _keyValueStorage = KeyValueStorageBase();

  /// Retrieves the list of recent searches from the key-value storage.
  ///
  /// Returns a [Future] that completes with a list of [Article] objects.
  static Future<List<Article>> getRecentSearches() async {
    // Fetch the recent searches from the key-value storage.
    final recentSearches = _keyValueStorage.getCommon<List>(_recentSearchesKey);

    // If recent searches are found, map them to Article objects.
    // Otherwise, return an empty list.
    return recentSearches != null
        ? recentSearches.map((e) => Article.fromJson(e)).toList()
        : [];
  }

  /// Saves the list of recent searches to the key-value storage.
  ///
  /// [searches] is the list of [Article] objects to be saved.
  static void saveRecentSearches(List<Article> searches) {
    // Convert the list of Article objects to JSON and save it.
    _keyValueStorage.setCommon(_recentSearchesKey, searches);
  }

  /// Adds a new [Article] to the list of recent searches.
  ///
  /// [news] is the [Article] object to be added.
  /// Returns a [Future] that completes with a boolean indicating success.
  static Future<bool> addToRecentSearches(Article news) {
    // Fetch the current list of recent searches or initialize an empty list.
    final recentSearches =
        _keyValueStorage.getCommon<List>(_recentSearchesKey) ?? [];

    // Add the new Article to the list.
    recentSearches.add(news.toJson());

    // Save the updated list back to the key-value storage.
    return _keyValueStorage.setCommon(_recentSearchesKey, recentSearches);
  }

  /// Clears the list of recent searches from the key-value storage.
  ///
  /// Returns a [Future] that completes with a boolean indicating success.
  static Future<bool> clearRecentSearches() {
    // Clear the recent searches key from the key-value storage.
    return _keyValueStorage.clearCommonKey(_recentSearchesKey);
  }
}
