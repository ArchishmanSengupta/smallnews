// import 'package:flutter/material.dart';
// import 'package:smallnews/data/models/models.dart';

// /// A class that represents the state of a news list.
// ///
// /// This class holds information about the news articles, current page, loading state,
// /// error messages, and whether the end of the list has been reached.
// class NewsListState {
//   /// The response containing the news articles.
//   final NewsResponse? newsResponse;

//   /// The scroll controller for the list of news articles.
//   final ScrollController? scrollController;

//   /// The current page of the news articles.
//   final int currentPage;

//   /// Indicates whether the news articles are currently loading.
//   final bool isLoading;

//   /// An optional error message.
//   final String? error;

//   /// Indicates whether the end of the news list has been reached.
//   final bool hasReachedEnd;

//   /// Indicates the total number of results.
//   final int totalResults;

//   /// Creates a [NewsListState] instance.
//   ///
//   /// [newsResponse] is the response containing the news articles.
//   /// [articles] is an optional list of news articles.
//   /// [currentPage] is the current page of the news articles, defaulting to 1.
//   /// [isLoading] indicates whether the news articles are currently loading, defaulting to false.
//   /// [error] is an optional error message.
//   /// [scrollController] is the scroll controller for the list of news articles.
//   /// [hasReachedEnd] indicates whether the end of the news list has been reached, defaulting to false.
//   NewsListState({
//     this.newsResponse,
//     List<Article>? articles,
//     this.currentPage = 1,
//     this.isLoading = false,
//     this.error,
//     this.scrollController,
//     this.hasReachedEnd = false,
//     this.totalResults = 0,
//   });

//   /// Gets the list of news articles.
//   ///
//   /// Returns the list of articles from the [newsResponse], or an empty list if the response is null.
//   List<Article> get articles => newsResponse?.articles ?? [];

//   /// Creates a copy of the [NewsListState] with the specified fields updated.
//   ///
//   /// [newsResponse] is the updated response containing the news articles.
//   /// [articles] is the updated list of news articles.
//   /// [currentPage] is the updated current page of the news articles.
//   /// [isLoading] is the updated loading state.
//   /// [error] is the updated error message.
//   /// [hasReachedEnd] is the updated state indicating whether the end of the news list has been reached.
//   /// Returns a new [NewsListState] instance with the updated fields.
//   NewsListState copyWith({
//     NewsResponse? newsResponse,
//     List<Article>? articles,
//     int? currentPage,
//     bool? isLoading,
//     String? error,
//     bool? hasReachedEnd,
//     int? totalResults,
//   }) {
//     return NewsListState(
//       newsResponse: newsResponse ?? this.newsResponse,
//       currentPage: currentPage ?? this.currentPage,
//       isLoading: isLoading ?? this.isLoading,
//       error: error,
//       hasReachedEnd: hasReachedEnd ?? this.hasReachedEnd,
//       totalResults: totalResults ?? this.totalResults,
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:smallnews/data/data.dart';

class NewsListState {
  final List<Article> articles;
  final int currentPage;
  final int totalResults;
  final bool isLoading;
  final String? error;
  final ScrollController scrollController;

  bool get hasReachedEnd => articles.length >= totalResults;

  NewsListState({
    required this.articles,
    required this.currentPage,
    required this.totalResults,
    required this.isLoading,
    this.error,
    required this.scrollController,
  });

  NewsListState copyWith({
    List<Article>? articles,
    int? currentPage,
    int? totalResults,
    bool? isLoading,
    String? error,
    ScrollController? scrollController,
  }) {
    return NewsListState(
      articles: articles ?? this.articles,
      currentPage: currentPage ?? this.currentPage,
      totalResults: totalResults ?? this.totalResults,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      scrollController: scrollController ?? this.scrollController,
    );
  }
}
