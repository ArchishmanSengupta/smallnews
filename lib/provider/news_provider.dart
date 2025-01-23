import 'package:flutter/material.dart';
import 'package:smallnews/data/data.dart';
import 'package:smallnews/repository/respository.dart';

class NewsProvider extends ChangeNotifier {
  List<Article> _articles = [];
  bool _isLoading = false;
  String _error = '';
  String _currentQuery = '';
  int _currentPage = 1;
  bool _hasReachedEnd = false;
  int _totalResults = 0;

  List<Article> get articles => _articles;
  bool get isLoading => _isLoading;
  String get error => _error;
  bool get hasReachedEnd => _hasReachedEnd;

  Future<void> searchNews(String query) async {
    if (query.isEmpty) return;

    _isLoading = true;
    _error = '';
    _currentQuery = query;
    _currentPage = 1;
    _articles = [];
    notifyListeners();

    try {
      final response = await NewsRepository.fetchNews(query, _currentPage);
      _articles = response.articles;
      _totalResults = response.totalResults;
      _hasReachedEnd = _articles.length >= _totalResults;
      _error = '';
    } catch (e) {
      _error = e.toString();
      _articles = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadMore() async {
    if (_isLoading || _hasReachedEnd) return;

    _isLoading = true;
    notifyListeners();

    try {
      final nextPage = _currentPage + 1;
      final response = await NewsRepository.fetchNews(_currentQuery, nextPage);

      _articles = [..._articles, ...response.articles];
      _currentPage = nextPage;
      _hasReachedEnd = _articles.length >= _totalResults;
      _error = '';
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
