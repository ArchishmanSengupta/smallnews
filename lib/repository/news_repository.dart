library;

import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:smallnews/models/models.dart';

/// A repository class that handles fetching news data from the News API.
class NewsRepository {
  /// Fetches news articles based on a search query and page number.
  ///
  /// The [query] parameter specifies the search term to look for in the news articles.
  /// The [page] parameter specifies the page number of the results to fetch.
  ///
  /// Returns a [NewsResponse] containing the news articles.
  ///
  /// Throws an [Exception] if the network request fails or if the response status code is not 200.
  static Future<NewsResponse> fetchNews(String query, int page) async {
    final String apiKey = dotenv.env['NEWS_API_KEY'] ?? '';
    const String authority = 'newsapi.org';
    const String path = '/v2/everything';
    final DateTime now = DateTime.now();
    final DateTime thirtyDaysAgo = now.subtract(const Duration(days: 30));
    final String fromDate = DateFormat('yyyy-MM-dd').format(thirtyDaysAgo);

    final String url = Uri.https(authority, path, {
      'q': query,
      'from': fromDate,
      'sortBy': 'publishedAt',
      'page': page.toString(),
      'pageSize': '20',
      'apiKey': apiKey,
    }).toString();

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return NewsResponse.fromJson(data);
      } else if (response.statusCode == 429) {
        throw Exception('Too many requests 😢');
      } else {
        throw Exception('Failed to load news: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('$e');
    }
  }

  /// Fetches news articles based on a category and page number.
  ///
  /// The [category] parameter specifies the category of news to fetch (e.g., business, entertainment, health).
  /// The [page] parameter specifies the page number of the results to fetch.
  ///
  /// Returns a [NewsResponse] containing the news articles.
  ///
  /// Throws an [Exception] if the network request fails or if the response status code is not 200.
  static Future<NewsResponse> fetchNewsByCategory(
      String category, int page) async {
    final String apiKey = dotenv.env['NEWS_API_KEY'] ?? '';
    const String authority = 'newsapi.org';
    const String path = '/v2/top-headlines';

    final String url = Uri.https(authority, path, {
      'country': 'us',
      'category': category,
      'page': page.toString(),
      'pageSize': '20',
      'apiKey': apiKey,
    }).toString();

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return NewsResponse.fromJson(data);
      } else if (response.statusCode == 429) {
        throw Exception('Too many requests 😢');
      } else {
        throw Exception('Failed to load news: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('$e');
    }
  }

  /// Fetches top headlines for a specific country.
  ///
  /// The [page] parameter specifies the page number of the results to fetch.
  ///
  /// Returns a [NewsResponse] containing the news articles.
  ///
  /// Throws an [Exception] if the network request fails or if the response status code is not 200.
  static Future<NewsResponse> fetchTopHeadlines(int page) async {
    final String apiKey = dotenv.env['NEWS_API_KEY'] ?? '';
    const String authority = 'newsapi.org';
    const String path = '/v2/top-headlines';

    final String url = Uri.https(authority, path, {
      'country': 'us',
      'page': page.toString(),
      'pageSize': '20',
      'apiKey': apiKey,
    }).toString();

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return NewsResponse.fromJson(data);
      } else if (response.statusCode == 429) {
        throw Exception('Too many requests 😢');
      } else {
        throw Exception('Failed to load news: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('$e');
    }
  }
}
