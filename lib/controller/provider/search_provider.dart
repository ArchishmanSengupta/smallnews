import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smallnews/controller/services/services.dart';
import 'package:smallnews/data/data.dart';

/// Manages news search functionality, recent searches, and pagination
///
/// This provider handles:
/// - Searching news articles
/// - Storing and managing recent search history
/// - Implementing infinite scroll pagination
/// - Caching search results locally
class NewsSearchProvider extends ChangeNotifier {
  /// Singleton instance to ensure a single global state for news searches
  /// as we are only accessing the search page from one action
  static final NewsSearchProvider _instance = NewsSearchProvider._internal();

  /// Factory constructor for accessing the singleton instance
  factory NewsSearchProvider() {
    return _instance;
  }

  /// Private constructor initializes recent searches and scroll listener
  NewsSearchProvider._internal() {
    _loadRecentSearches();
    _setupScrollListener();
  }

  /// Text controller for managing search input
  final TextEditingController newsSearchController = TextEditingController();

  /// Scroll controller for implementing infinite scroll pagination
  final ScrollController scrollController = ScrollController();

  /// Indicates whether a search operation is currently in progress
  bool isLoading = false;

  /// Stores any error messages encountered during search operations
  String? error;

  /// List of articles retrieved from the current search
  List<ArticleModel> articles = [];

  /// Total number of results available for the current search
  int totalResults = 0;

  /// Determines if more results can be loaded
  /// Returns true if current articles count is less than total results
  bool get hasMore => articles.length < totalResults;

  /// Stores a list of recent search queries
  List<String> recentSearches = [];

  /// Current search query being processed
  String currentQuery = '';

  /// Current page number for pagination
  int currentPage = 1;

  /// Caches search results for recent queries
  final Map<String, List<ArticleModel>> recentSearchResults = {};

  /// Tracks expansion state for recent search results
  final Map<String, bool> isExpanded = {};

  /// Sets up scroll listener for implementing infinite scroll
  ///
  /// Triggers loading more results when user approaches the end of the current list
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

  /// Clears the current search state
  ///
  /// Resets search controller, articles, error, and current query
  void clearSearch() {
    newsSearchController.clear();
    articles = [];
    error = null;
    currentQuery = '';
    notifyListeners();
  }

  /// Checks if the search input is empty
  bool get isSearchEmpty => newsSearchController.text.trim().isEmpty;

  /// Retrieves the trimmed search key from the text controller
  String get getSearchKey => newsSearchController.text.trim();

  /// Performs a news search based on the current input
  ///
  /// [1] Validates and trims the search query
  /// [2] Resets search state
  /// [3] Fetches news articles
  /// [4] Saves recent search to local storage
  /// [5] Handles potential errors
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

  /// Toggles the expanded state for a specific search query
  ///
  /// Used to show/hide additional details for recent search results
  void toggleExpanded(String query) {
    isExpanded[query] = !(isExpanded[query] ?? false);
    notifyListeners();
  }

  /// Loads additional results for the current search query
  ///
  /// Implements pagination by fetching the next page of results
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

  /// Saves a recent search query and its results to local storage
  ///
  /// [1] Limits recent searches to a maximum of 5
  /// [2] Stores query in SharedPreferences
  /// [3] Caches search results in memory
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

  /// Loads recent searches from local storage
  ///
  /// [1] Retrieves saved searches from SharedPreferences
  /// [2] Fetches results for each recent search
  /// [3] Caches results and expansion states
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

  /// Clears all recent searches from local storage and memory
  ///
  /// Removes saved searches, cached results, and expansion states
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

  /// Disposes of resources when the provider is no longer needed
  ///
  /// Ensures proper cleanup of scroll controller
  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }
}
