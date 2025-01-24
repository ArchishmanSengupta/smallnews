import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smallnews/controller/services/services.dart';
import 'package:smallnews/data/data.dart';

class NewsSearchController {
  final TextEditingController newsSearchController = TextEditingController();
  final ScrollController scrollController = ScrollController();

  final ValueNotifier<bool> isLoading = ValueNotifier(false);
  final ValueNotifier<String?> error = ValueNotifier(null);
  final ValueNotifier<List<Article>> articles = ValueNotifier([]);
  final ValueNotifier<int> totalResults = ValueNotifier(0);
  final ValueNotifier<bool> hasMore = ValueNotifier(true);
  final ValueNotifier<List<String>> recentSearchesNotifier = ValueNotifier([]);

  String currentQuery = '';
  int currentPage = 1;
  final Map<String, List<Article>> recentSearchResults = {};
  final Map<String, bool> isExpanded = {};

  NewsSearchController() {
    _loadRecentSearches();
    _setupScrollListener();
  }

  void _setupScrollListener() {
    scrollController.addListener(() {
      if (isLoading.value || !hasMore.value) return;

      final maxScroll = scrollController.position.maxScrollExtent;
      final currentScroll = scrollController.position.pixels;
      const scrollThreshold = 100;

      if (maxScroll - currentScroll <= scrollThreshold) {
        _loadMoreResults();
      }
    });
  }

  Future<void> performSearch() async {
    final query = newsSearchController.text.trim();
    if (query.isEmpty) return;

    isLoading.value = true;
    error.value = null;
    currentPage = 1;
    articles.value = [];
    currentQuery = query;
    hasMore.value = true;

    try {
      final results = await NewsRepository.fetchNews(query, currentPage);
      totalResults.value = results.totalResults;
      articles.value = results.articles;
      hasMore.value = articles.value.length < totalResults.value;
      _saveRecentSearch(query, results.articles);
    } catch (e) {
      error.value = e.toString().replaceAll('Exception:', '').trim();
      hasMore.value = false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _loadMoreResults() async {
    if (isLoading.value || !hasMore.value || currentQuery.isEmpty) return;

    isLoading.value = true;

    try {
      final nextPage = currentPage + 1;
      final results = await NewsRepository.fetchNews(currentQuery, nextPage);
      articles.value = [...articles.value, ...results.articles];
      currentPage = nextPage;
      totalResults.value = results.totalResults;
      hasMore.value = articles.value.length < totalResults.value;
    } catch (e) {
      error.value = e.toString().replaceAll('Exception:', '').trim();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _saveRecentSearch(String query, List<Article> articles) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> updatedSearches = List.from(recentSearchesNotifier.value);
    updatedSearches.remove(query);
    updatedSearches.insert(0, query);
    if (updatedSearches.length > 5) {
      updatedSearches = updatedSearches.sublist(0, 5);
    }
    recentSearchesNotifier.value = updatedSearches;
    await prefs.setStringList('recent_searches', updatedSearches);
    recentSearchResults[query] = articles;
    isExpanded[query] = false;
  }

  Future<void> _loadRecentSearches() async {
    final prefs = await SharedPreferences.getInstance();
    final savedSearches = prefs.getStringList('recent_searches') ?? [];
    recentSearchesNotifier.value = savedSearches;

    for (var query in savedSearches) {
      try {
        final results = await NewsRepository.fetchNews(query, 1);
        recentSearchResults[query] = results.articles;
        isExpanded[query] = false;
      } catch (e) {
        //
      }
    }
  }

  Future<void> clearRecentSearches() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('recent_searches');
    recentSearchesNotifier.value = [];
    recentSearchResults.clear();
    isExpanded.clear();
  }

  void dispose() {
    newsSearchController.dispose();
    scrollController.dispose();
    isLoading.dispose();
    error.dispose();
    articles.dispose();
    totalResults.dispose();
    hasMore.dispose();
    recentSearchesNotifier.dispose();
  }
}
