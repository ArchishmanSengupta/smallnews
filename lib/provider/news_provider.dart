import 'package:flutter/material.dart';
import 'package:smallnews/data/data.dart';
import 'package:smallnews/services/services.dart';
import 'package:smallnews/util/util.dart';

class NewsProvider extends ChangeNotifier {
  static final NewsProvider _instance = NewsProvider._internal();

  factory NewsProvider() {
    return _instance;
  }

  final Map<String, NewsListState> _categoryStates = {};

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
    _categoryStates[category] = NewsListState(isLoading: true);
    notifyListeners();

    try {
      final resp = await NewsRepository.fetchNewsByCategory(category, 1);
      final scollController = ScrollController();
      scollController.addListener(() {
        if (scollController.position.pixels >=
            scollController.position.maxScrollExtent) {
          loadMoreArticles(category);
        }
      });
      _categoryStates[category] = NewsListState(
        newsResponse: resp,
        hasReachedEnd: resp.articles.length < kArticlesPerPage,
        scrollController: scollController,
      );

    } catch (e) {
      _categoryStates[category] = NewsListState(error: e.toString());
    }
    notifyListeners();
  }

  Future<void> loadMoreArticles(String category) async {
    final currentState = _categoryStates[category];
    if (currentState == null || currentState.isLoading || currentState.hasReachedEnd) return;

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

  NewsListState? getState(String category) => _categoryStates[category];

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
