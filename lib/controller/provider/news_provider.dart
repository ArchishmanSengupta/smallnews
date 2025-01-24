import 'package:flutter/material.dart';
import 'package:smallnews/data/data.dart';
import 'package:smallnews/controller/services/services.dart';
import 'package:smallnews/view/util/util.dart';

/// A provider class that manages the state of news articles for different categories.
///
/// This class uses the [ChangeNotifier] to notify listeners about changes in the state.
class NewsProvider extends ChangeNotifier {
  /// The singleton instance of [NewsProvider].
  static final NewsProvider _instance = NewsProvider._internal();

  /// Returns the singleton instance of [NewsProvider].
  factory NewsProvider() {
    return _instance;
  }

  /// A map that holds the state of news articles for each category.
  final Map<String, NewsListState> _categoryStates = {};

  /// Private constructor to enforce the singleton pattern.
  NewsProvider._internal() {
    init();
  }

  /// Initializes the provider by fetching news articles for all categories.
  Future<void> init() async {
    if (_categoryStates.isNotEmpty) return;

    for (String category in categories) {
      await initCategory(category);
    }
  }

  /// Initializes the state for a specific category by fetching news articles.
  ///
  /// [category] is the category for which news articles are to be fetched.
  Future<void> initCategory(String category) async {
    _categoryStates[category] = NewsListState(isLoading: true);
    notifyListeners();

    try {
      final resp = await NewsRepository.fetchNewsByCategory(category, 1);
      final scrollController = ScrollController();
      scrollController.addListener(() {
        if (scrollController.position.pixels >=
            scrollController.position.maxScrollExtent) {
          loadMoreArticles(category);
        }
      });
      _categoryStates[category] = NewsListState(
        newsResponse: resp,
        hasReachedEnd: resp.articles.length < kArticlesPerPage,
        scrollController: scrollController,
      );
    } catch (e) {
      _categoryStates[category] = NewsListState(error: e.toString());
    }
    notifyListeners();
  }

  /// Loads more articles for a specific category.
  ///
  /// [category] is the category for which more articles are to be loaded.
  Future<void> loadMoreArticles(String category) async {
    final currentState = _categoryStates[category];
    if (currentState == null ||
        currentState.isLoading ||
        currentState.hasReachedEnd) return;

    _categoryStates[category] = currentState.copyWith(isLoading: true);
    notifyListeners();

    try {
      final resp = await NewsRepository.fetchNewsByCategory(
        category,
        currentState.currentPage + 1,
      );

      _categoryStates[category] = currentState.copyWith(
        newsResponse: resp,
        currentPage: currentState.currentPage + 1,
        isLoading: false,
        hasReachedEnd: resp.articles.length < kArticlesPerPage,
      );
    } catch (e) {
      _categoryStates[category] = currentState.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
    notifyListeners();
  }

  /// Gets the state for a specific category.
  ///
  /// [category] is the category for which the state is to be retrieved.
  /// Returns the [NewsListState] for the specified category, or null if not found.
  NewsListState? getState(String category) => _categoryStates[category];

  /// Refreshes the state for a specific category by re-initializing it.
  ///
  /// [category] is the category for which the state is to be refreshed.
  void refresh(String category) {
    _categoryStates.remove(category);
    notifyListeners();
    initCategory(category);
  }

  /// Refreshes the state for all categories by re-initializing them.
  void refreshAll() {
    _categoryStates.clear();
    notifyListeners();
    init();
  }

  @override
  void dispose() {
    _categoryStates.clear();
    super.dispose();
  }
}
