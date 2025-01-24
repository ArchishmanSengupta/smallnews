import 'package:flutter/material.dart';
import 'package:smallnews/data/models/models.dart';

class NewsListState {
  NewsResponse? newsResponse;
  ScrollController? scrollController;
  final int currentPage;
  final bool isLoading;
  final String? error;
  final bool hasReachedEnd;

  NewsListState({
    this.newsResponse,
    List<Article>? articles,
    this.currentPage = 1,
    this.isLoading = false,
    this.error,
    this.scrollController,
    this.hasReachedEnd = false,
  });

  List<Article> get articles => newsResponse?.articles ?? [];

  NewsListState copyWith({
    NewsResponse? newsResponse,
    List<Article>? articles,
    int? currentPage,
    bool? isLoading,
    String? error,
    bool? hasReachedEnd,
  }) {
    return NewsListState(
      newsResponse: newsResponse ?? this.newsResponse,
      currentPage: currentPage ?? this.currentPage,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      hasReachedEnd: hasReachedEnd ?? this.hasReachedEnd,
    );
  }
}