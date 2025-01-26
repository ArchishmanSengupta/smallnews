import 'package:flutter/material.dart';
import 'package:smallnews/controller/controller.dart';
import 'package:smallnews/data/data.dart';
import 'package:smallnews/view/util/util.dart';

/// Central state management provider for news content
/// Implements ChangeNotifier for state observation and follows singleton pattern
/// Handles:
/// - Category-based news state management
/// - Pagination and scroll handling
/// - Error states and loading states
/// - Data refresh functionality
class NewsProvider extends ChangeNotifier {
  // Singleton instance setup for app-wide state consistency
  static final NewsProvider _instance = NewsProvider._internal();

  /// Public factory constructor that returns the singleton instance
  /// Ensures single source of truth for news state across the application
  factory NewsProvider() {
    return _instance;
  }

  /// Stores state for each news category using Map for O(1) access complexity
  /// Key: Category name (String)
  /// Value: NewsListModel containing articles, pagination state, and UI controls
  final Map<String, NewsListModel> _categoryStates = {};

  /// Private internal constructor for singleton implementation
  NewsProvider._internal() {
    init();
  }

  /// Initialization method that populates all categories
  /// Should be called only once during provider initialization
  Future<void> init() async {
    if (_categoryStates.isNotEmpty) return;

    // Initialize all categories in parallel for better performance
    // Consider using Future.wait() if order doesn't matter and APIs support parallel calls
    for (String category in categories) {
      await initCategory(category);
    }
  }

  /// Initializes state for a single category and fetches first page
  /// [category]: News category to initialize (e.g., 'business', 'technology')
  Future<void> initCategory(String category) async {
    _categoryStates[category] = NewsListModel(
      articles: [],
      currentPage: 0,
      totalResults: 0,
      isLoading: true,
      scrollController: ScrollController(),
    );
    notifyListeners();

    try {
      // Fetch first page of articles
      final resp = await NewsService.fetchNewsByCategory(category, 1);
      final scrollController = ScrollController();

      // Set up scroll listener for pagination
      scrollController.addListener(() {
        final state = _categoryStates[category];
        if (state == null) return;

        // Calculate scroll position for infinite scroll
        final maxScroll = scrollController.position.maxScrollExtent;
        final currentScroll = scrollController.position.pixels;

        // pixels from bottom to trigger load
        const scrollThreshold = 100;

        if (maxScroll - currentScroll <= scrollThreshold &&
            !state.isLoading &&
            !state.hasReachedEnd) {
          loadMoreArticles(category);
        }
      });

      // Update state with fetched data and configured scroll controller
      _categoryStates[category] = NewsListModel(
        articles: resp.articles,
        currentPage: 1,
        totalResults: resp.totalResults,
        isLoading: false,
        scrollController: scrollController,
      );
    } catch (e) {
      _categoryStates[category] = NewsListModel(
        articles: [],
        currentPage: 0,
        totalResults: 0,
        isLoading: false,
        error: e.toString(),
        scrollController: ScrollController(),
      );
    } finally {
      notifyListeners();
    }
  }

  /// Handles pagination for news categories
  /// [category]: Category to load more articles for
  Future<void> loadMoreArticles(String category) async {
    final currentState = _categoryStates[category];
    // Validate state before loading more
    if (currentState == null ||
        currentState.isLoading ||
        currentState.hasReachedEnd) {
      return;
    }

    // Set loading state and update UI
    _categoryStates[category] = currentState.copyWith(isLoading: true);
    notifyListeners();

    try {
      // Fetch next page from service
      final resp = await NewsService.fetchNewsByCategory(
        category,
        currentState.currentPage + 1,
      );

      // Merge existing and new articles
      final newArticles = [...currentState.articles, ...resp.articles];

      // Update state with new data
      _categoryStates[category] = currentState.copyWith(
        articles: newArticles,
        currentPage: currentState.currentPage + 1,
        totalResults: resp.totalResults,
        isLoading: false,
      );
    } catch (e) {
      _categoryStates[category] = currentState.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    } finally {
      notifyListeners();
    }
  }

  /// Returns current state for a category
  /// [category]: Category to retrieve state for
  NewsListModel? getState(String category) => _categoryStates[category];

  /// Refreshes data for a specific category
  /// [category]: Category to refresh
  void refresh(String category) {
    // Clear existing state and reinitialize
    _categoryStates.remove(category);
    notifyListeners();
    initCategory(category);
  }

  /// Refreshes all categories and their data
  void refreshAll() {
    // Clear entire state and reinitialize
    _categoryStates.clear();
    notifyListeners();
    init();
  }

  @override
  void dispose() {
    // Cleanup resources when provider is disposed
    // IMPORTANT: Scroll controllers should be disposed here
    for (final state in _categoryStates.values) {
      state.scrollController.dispose();
    }
    _categoryStates.clear();
    super.dispose();
  }
}
