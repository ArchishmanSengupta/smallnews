import 'package:smallnews/data/models/models.dart';

class NewsResponse {
  final String status;
  final int totalResults;
  final List<Article> articles;

  static const NewsResponse empty = NewsResponse(
    status: 'ok',
    totalResults: 0,
    articles: [],
  );

  const NewsResponse({
    required this.status,
    required this.totalResults,
    required this.articles,
  });

  factory NewsResponse.fromJson(Map<String, dynamic> json) {
    return NewsResponse(
      status: json['status'],
      totalResults: json['totalResults'],
      articles: (json['articles'] as List)
          .map((article) => Article.fromJson(article))
          .toList(),
    );
  }
}
