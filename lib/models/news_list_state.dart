import 'package:smallnews/models/models.dart';

class NewsListState {
  Future<NewsResponse> futureNewsResponse;
  List<Article> articles;
  int currentPage;
  bool isLoadingMore;

  NewsListState({
    required this.futureNewsResponse,
    required this.articles,
    required this.currentPage,
    this.isLoadingMore = false,
  });
}
