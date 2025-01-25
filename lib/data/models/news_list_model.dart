import 'package:flutter/material.dart';
import 'package:smallnews/data/data.dart';
import 'package:smallnews/view/view.dart';

class NewsListModel {
  final List<ArticleModel> articles;
  final int currentPage;
  final int totalResults;
  final bool isLoading;
  final String? error;
  final ScrollController scrollController;

  bool get hasReachedEnd => articles.length % kArticlesPerPage != 0;

  const NewsListModel({
    required this.articles,
    required this.currentPage,
    required this.totalResults,
    required this.isLoading,
    this.error,
    required this.scrollController,
  });

  NewsListModel copyWith({
    List<ArticleModel>? articles,
    int? currentPage,
    int? totalResults,
    bool? isLoading,
    String? error,
    ScrollController? scrollController,
  }) {
    return NewsListModel(
      articles: articles ?? this.articles,
      currentPage: currentPage ?? this.currentPage,
      totalResults: totalResults ?? this.totalResults,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      scrollController: scrollController ?? this.scrollController,
    );
  }
}
