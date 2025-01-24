import 'package:smallnews/data/data.dart';
import 'package:smallnews/services/services.dart';

class KeyValueStorageService {
  static const _recentSearchesKey = 'recentSearches';

  static final _keyValueStorage = KeyValueStorageBase();

  static Future<List<Article>> getRecentSearches() async {
    final recentSearches = _keyValueStorage.getCommon<List>(_recentSearchesKey);

    return recentSearches != null
        ? recentSearches.map((e) => Article.fromJson(e)).toList()
        : [];
  }

  static void saveRecentSearches(List<Article> searches) {
    _keyValueStorage.setCommon(_recentSearchesKey, searches);
  }

  static Future<bool> addToRecentSearches(Article news) {
    final recentSearches =
        _keyValueStorage.getCommon<List>(_recentSearchesKey) ?? [];
    recentSearches.add(news.toJson());
    return _keyValueStorage.setCommon(_recentSearchesKey, recentSearches);
  }

  static Future<bool> clearRecentSearches() {
    return _keyValueStorage.clearCommonKey(_recentSearchesKey);
  }
}
