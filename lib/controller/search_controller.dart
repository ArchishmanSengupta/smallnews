// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:smallnews/controller/services/news_repository.dart';
// import 'package:smallnews/data/models/article.dart';

// class NewsSearchController {
//   final TextEditingController searchController = TextEditingController();

//   bool _isLoading = false;
//   bool _isLoadingMore = false;
//   String _currentQuery = '';
//   int _currentPage = 1;
//   List<Article> _articles = [];
//   String? _error;
//   bool _hasMore = true;
//   List<String> _recentSearches = [];

//   // Getters
//   bool get isLoading => _isLoading;
//   bool get isLoadingMore => _isLoadingMore;
//   String get currentQuery => _currentQuery;
//   List<Article> get articles => _articles;
//   String? get error => _error;
//   List<String> get recentSearches => _recentSearches;
//   bool get hasMore => _hasMore;

//   SearchController() {
//     _loadRecentSearches();
//   }

//   Future<void> performSearch() async {
//     final query = searchController.text.trim();
//     if (query.isEmpty) return;

//     _isLoading = true;
//     _error = null;
//     _currentPage = 1;
//     _articles = [];
//     _currentQuery = query;
//     _hasMore = true;

//     try {
//       final results = await NewsRepository.fetchNews(query, _currentPage);

//       if (results.articles.isEmpty) {
//         _error = 'No articles found for this search term.';
//         _hasMore = false;
//       } else {
//         _articles = results.articles;
//         _hasMore = results.articles.length >= 20;
//       }
//       _isLoading = false;

//       _saveRecentSearch(query);
//     } catch (e) {
//       _error = e.toString().replaceAll('Exception:', '').trim();
//       _isLoading = false;
//       _hasMore = false;
//     }
//   }

//   Future<void> loadMoreResults() async {
//     if (_isLoadingMore || _isLoading || !_hasMore || _currentQuery.isEmpty) {
//       return;
//     }

//     _isLoadingMore = true;

//     try {
//       final nextPage = _currentPage + 1;
//       final results = await NewsRepository.fetchNews(_currentQuery, nextPage);

//       if (results.articles.isNotEmpty) {
//         _articles.addAll(results.articles);
//         _currentPage = nextPage;
//         _hasMore = results.articles.length >= 20;
//       } else {
//         _hasMore = false;
//       }
//       _isLoadingMore = false;
//     } catch (e) {
//       _isLoadingMore = false;
//       _hasMore = false;
//     }
//   }

//   Future<void> _saveRecentSearch(String query) async {
//     final prefs = await SharedPreferences.getInstance();
//     _recentSearches.remove(query);
//     _recentSearches.insert(0, query);
//     if (_recentSearches.length > 5) {
//       _recentSearches = _recentSearches.sublist(0, 5);
//     }
//     await prefs.setStringList('recent_searches', _recentSearches);
//   }

//   Future<void> _loadRecentSearches() async {
//     final prefs = await SharedPreferences.getInstance();
//     _recentSearches = prefs.getStringList('recent_searches') ?? [];
//   }

//   Future<void> clearRecentSearches() async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.remove('recent_searches');
//     _recentSearches = [];
//   }

//   void clearSearch() {
//     searchController.clear();
//     _articles = [];
//     _error = null;
//     _currentQuery = '';
//     _hasMore = true;
//   }

//   void dispose() {
//     searchController.dispose();
//   }
// }
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smallnews/controller/services/news_repository.dart';
import 'package:smallnews/data/models/article.dart';

class NewsSearchController with ChangeNotifier {
  final TextEditingController searchController = TextEditingController();

  bool _isLoading = false;
  bool _isLoadingMore = false;
  String _currentQuery = '';
  int _currentPage = 1;
  List<Article> _articles = [];
  String? _error;
  bool _hasMore = true;
  List<String> _recentSearches = [];

  // Getters
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  String get currentQuery => _currentQuery;
  List<Article> get articles => _articles;
  String? get error => _error;
  List<String> get recentSearches => _recentSearches;
  bool get hasMore => _hasMore;

  NewsSearchController() {
    _loadRecentSearches();
  }

  Future<void> performSearch() async {
    final query = searchController.text.trim();
    if (query.isEmpty) return;

    _isLoading = true;
    _error = null;
    _currentPage = 1;
    _articles = [];
    _currentQuery = query;
    _hasMore = true;
    notifyListeners();

    try {
      final results = await NewsRepository.fetchNews(query, _currentPage);

      if (results.articles.isEmpty) {
        _error = 'No articles found for this search term.';
        _hasMore = false;
      } else {
        _articles = results.articles;
        _hasMore = results.articles.length >= 20;
      }
      _isLoading = false;
      notifyListeners();

      _saveRecentSearch(query);
    } catch (e) {
      _error = e.toString().replaceAll('Exception:', '').trim();
      _isLoading = false;
      _hasMore = false;
      notifyListeners();
    }
  }

  Future<void> loadMoreResults() async {
    if (_isLoadingMore || _isLoading || !_hasMore || _currentQuery.isEmpty) {
      return;
    }

    _isLoadingMore = true;
    notifyListeners();

    try {
      final nextPage = _currentPage + 1;
      final results = await NewsRepository.fetchNews(_currentQuery, nextPage);

      if (results.articles.isNotEmpty) {
        _articles.addAll(results.articles);
        _currentPage = nextPage;
        _hasMore = results.articles.length >= 20;
      } else {
        _hasMore = false;
      }
      _isLoadingMore = false;
      notifyListeners();
    } catch (e) {
      _isLoadingMore = false;
      _hasMore = false;
      notifyListeners();
    }
  }

  Future<void> _saveRecentSearch(String query) async {
    final prefs = await SharedPreferences.getInstance();
    _recentSearches.remove(query);
    _recentSearches.insert(0, query);
    if (_recentSearches.length > 5) {
      _recentSearches = _recentSearches.sublist(0, 5);
    }
    await prefs.setStringList('recent_searches', _recentSearches);
    notifyListeners();
  }

  Future<void> _loadRecentSearches() async {
    final prefs = await SharedPreferences.getInstance();
    _recentSearches = prefs.getStringList('recent_searches') ?? [];
    notifyListeners();
  }

  Future<void> clearRecentSearches() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('recent_searches');
    _recentSearches = [];
    notifyListeners();
  }

  void clearSearch() {
    searchController.clear();
    _articles = [];
    _error = null;
    _currentQuery = '';
    _hasMore = true;
    notifyListeners();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }
}
