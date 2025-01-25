import 'package:flutter/material.dart';
import 'package:smallnews/controller/services/services.dart';
import 'package:smallnews/data/data.dart';
import 'package:smallnews/view/util/util.dart';

class NewsProvider extends ChangeNotifier {
  static final NewsProvider _instance = NewsProvider._internal();

  factory NewsProvider() {
    return _instance;
  }

  final Map<String, NewsListModel> _categoryStates = {};

  NewsProvider._internal() {
    init();
  }

  Future<void> init() async {
    if (_categoryStates.isNotEmpty) return;

    for (String category in categories) {
      await initCategory(category);
    }
  }

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
      final resp = await NewsService.fetchNewsByCategory(category, 1);
      final scrollController = ScrollController();

      scrollController.addListener(() {
        final state = _categoryStates[category];
        if (state == null) return;

        final maxScroll = scrollController.position.maxScrollExtent;
        final currentScroll = scrollController.position.pixels;
        const scrollThreshold = 100; // pixels before bottom to trigger load

        if (maxScroll - currentScroll <= scrollThreshold &&
            !state.isLoading &&
            !state.hasReachedEnd) {
          loadMoreArticles(category);
        }
      });

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

  Future<void> loadMoreArticles(String category) async {
    final currentState = _categoryStates[category];
    if (currentState == null ||
        currentState.isLoading ||
        currentState.hasReachedEnd) {
      return;
    }

    _categoryStates[category] = currentState.copyWith(isLoading: true);
    notifyListeners();

    try {
      final resp = await NewsService.fetchNewsByCategory(
        category,
        currentState.currentPage + 1,
      );

      final newArticles = [...currentState.articles, ...resp.articles];

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

  NewsListModel? getState(String category) => _categoryStates[category];

  void refresh(String category) {
    _categoryStates.remove(category);
    notifyListeners();
    initCategory(category);
  }

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
