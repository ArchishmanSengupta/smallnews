import 'package:smallnews/data/models/models.dart';

class NewsResponseModel {
  final String status;
  final int totalResults;
  final List<ArticleModel> articles;

  static const NewsResponseModel empty = NewsResponseModel(
    status: 'ok',
    totalResults: 0,
    articles: [],
  );

  const NewsResponseModel({
    required this.status,
    required this.totalResults,
    required this.articles,
  });

  factory NewsResponseModel.fromJson(Map<String, dynamic> json) {
    return NewsResponseModel(
      status: json['status'],
      totalResults: json['totalResults'],
      articles: (json['articles'] as List)
          .map((article) => ArticleModel.fromJson(article))
          .toList(),
    );
  }

  NewsResponseModel copyWith({
    String? status,
    int? totalResults,
    List<ArticleModel>? articles,
  }) {
    return NewsResponseModel(
      status: status ?? this.status,
      totalResults: totalResults ?? this.totalResults,
      articles: articles ?? this.articles,
    );
  }
}
