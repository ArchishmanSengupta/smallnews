import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smallnews/controller/services/services.dart';
import 'package:smallnews/data/data.dart';

class NewsSearchProvider extends ChangeNotifier {
  static final NewsSearchProvider _instance = NewsSearchProvider._internal();

  factory NewsSearchProvider() {
    return _instance;
  }

  NewsSearchProvider._internal() {
    _loadRecentSearches();
    _setupScrollListener();
  }

  final TextEditingController newsSearchController = TextEditingController();
  final ScrollController scrollController = ScrollController();

  bool isLoading = false;
  String? error;
  List<ArticleModel> articles = [];
  int totalResults = 0;
  bool get hasMore => articles.length < totalResults;
  List<String> recentSearches = [];

  String currentQuery = '';
  int currentPage = 1;
  final Map<String, List<ArticleModel>> recentSearchResults = {};
  final Map<String, bool> isExpanded = {};

  void _setupScrollListener() {
    scrollController.addListener(() {
      if (isLoading || !hasMore) return;

      final maxScroll = scrollController.position.maxScrollExtent;
      final currentScroll = scrollController.position.pixels;
      const scrollThreshold = 100;

      if (maxScroll - currentScroll <= scrollThreshold) {
        _loadMoreResults();
      }
    });
  }

  void clearSearch() {
    newsSearchController.clear();
    articles = [];
    error = null;
    currentQuery = '';
    notifyListeners();
  }

  bool get isSearchEmpty => newsSearchController.text.trim().isEmpty;
  String get getSearchKey => newsSearchController.text.trim();

  Future<void> performSearch() async {
    final query = newsSearchController.text.trim();
    if (query.isEmpty) return;

    isLoading = true;
    error = null;
    currentPage = 1;
    articles = [];
    currentQuery = query;
    notifyListeners();

    try {
      final results = await NewsService.fetchNews(query, currentPage);
      totalResults = results.totalResults;
      articles = results.articles;
      await _saveRecentSearch(query, results.articles);
    } catch (e) {
      error = e.toString().replaceAll('Exception:', '').trim();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void toggleExpanded(String query) {
    isExpanded[query] = !(isExpanded[query] ?? false);

    notifyListeners();
  }

  Future<void> _loadMoreResults() async {
    if (isLoading || !hasMore || currentQuery.isEmpty) return;

    isLoading = true;
    notifyListeners();

    try {
      final nextPage = currentPage + 1;
      final results = await NewsService.fetchNews(currentQuery, nextPage);
      articles = [...articles, ...results.articles];
      currentPage = nextPage;
      totalResults = results.totalResults;
    } catch (e) {
      error = e.toString().replaceAll('Exception:', '').trim();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _saveRecentSearch(
      String query, List<ArticleModel> articles) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      List<String> updatedSearches = List.from(recentSearches);
      updatedSearches.remove(query);
      updatedSearches.insert(0, query);

      if (updatedSearches.length > 5) {
        updatedSearches = updatedSearches.sublist(0, 5);
      }

      await prefs.setStringList('recent_searches', updatedSearches);
      recentSearches = updatedSearches;
      recentSearchResults[query] = articles;
      isExpanded[query] = false;
    } catch (e) {
      error = 'Failed to save recent search: ${e.toString()}';
    } finally {
      notifyListeners();
    }
  }

  Future<void> _loadRecentSearches() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedSearches = prefs.getStringList('recent_searches') ?? [];
      recentSearches = savedSearches;

      await Future.wait(
        savedSearches.map((query) async {
          try {
            final results = await NewsService.fetchNews(query, 1);
            recentSearchResults[query] = results.articles;
            isExpanded[query] = false;
          } catch (e) {
            recentSearchResults[query] = [];
            isExpanded[query] = false;
            error =
                'Failed to load search results for "$query": ${e.toString()}';
          }
        }),
      );
    } catch (e) {
      error = 'Failed to load recent searches: ${e.toString()}';
      recentSearches = [];
    } finally {
      notifyListeners();
    }
  }

  Future<void> clearRecentSearches() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('recent_searches');
      recentSearches = [];
      recentSearchResults.clear();
      isExpanded.clear();
    } catch (e) {
      error = 'Failed to clear recent searches: ${e.toString()}';
    } finally {
      notifyListeners();
    }
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }
}
