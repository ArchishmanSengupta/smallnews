import 'package:smallnews/data/models/models.dart';

class Article {
  final Source source;
  final String? author;
  final String title;
  final String description;
  final String url;
  final String? urlToImage;
  final String publishedAt;
  final String content;

  Article({
    required this.source,
    this.author,
    required this.title,
    required this.description,
    required this.url,
    this.urlToImage,
    required this.publishedAt,
    required this.content,
  });

  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
      source: Source.fromJson(json['source']),
      author: json['author'],
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      url: json['url'] ?? '',
      urlToImage: json['urlToImage'],
      publishedAt: json['publishedAt'] ?? '',
      content: json['content'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'author': author,
      'title': title,
      'description': description,
      'url': url,
      'urlToImage': urlToImage,
      'publishedAt': DateTime.parse(publishedAt).toUtc().toIso8601String(),
      'content': content,
    };
  }

  Article copyWith({
    Source? source,
    String? author,
    String? title,
    String? description,
    String? url,
    String? urlToImage,
    String? publishedAt,
    String? content,
  }) {
    return Article(
      source: source ?? this.source,
      author: author ?? this.author,
      title: title ?? this.title,
      description: description ?? this.description,
      url: url ?? this.url,
      urlToImage: urlToImage ?? this.urlToImage,
      publishedAt: publishedAt ?? this.publishedAt,
      content: content ?? this.content,
    );
  }
}
