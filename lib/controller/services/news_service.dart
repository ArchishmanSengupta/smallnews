import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:smallnews/data/models/models.dart';
import 'package:smallnews/env/env.dart';

/// Manages news data retrieval from the News API
///
/// Provides methods to fetch news by:
/// - Search query
/// - Category
/// - Top headlines
///
/// Handles API request construction, error handling, and response parsing
class NewsService {
  /// Retrieves the API key from environment configuration
  static String get apiKey => Env.newsApiKey;

  /// Base authority for News API endpoints
  static const String authority = 'newsapi.org';

  /// Fetches news articles based on a search query
  ///
  /// [query] Search term for news articles
  /// [page] Pagination page number
  ///
  /// Returns [NewsResponseModel] containing fetched articles
  ///
  /// Throws [Exception] for API request failures or rate limiting
  static Future<NewsResponseModel> fetchNews(String query, int page) async {
    const String path = '/v2/everything';
    final DateTime now = DateTime.now();

    /// Limit search to last 30 days due to News API Free Plan restrictions
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
        return NewsResponseModel.fromJson(data);
      } else if (response.statusCode == 429) {
        throw Exception('Rate Limited 😢');
      } else {
        throw Exception('Rate Limited 😢');
      }
    } catch (e) {
      throw Exception('$e');
    }
  }

  /// Retrieves top headlines for a specific news category
  ///
  /// [category] News category to fetch
  /// [page] Pagination page number
  ///
  /// Returns [NewsResponseModel] with category-specific articles
  ///
  /// Throws [Exception] for API request failures or rate limiting
  static Future<NewsResponseModel> fetchNewsByCategory(
      String category, int page) async {
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
        return NewsResponseModel.fromJson(data);
      } else if (response.statusCode == 429) {
        throw Exception('Rate Limited 😢');
      } else {
        throw Exception('Rate Limited 😢');
      }
    } catch (e) {
      throw Exception('$e');
    }
  }

  /// Retrieves top headlines across all categories
  ///
  /// [page] Pagination page number
  ///
  /// Returns [NewsResponseModel] containing top headlines
  ///
  /// Throws [Exception] for API request failures or rate limiting
  static Future<NewsResponseModel> fetchTopHeadlines(int page) async {
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
        return NewsResponseModel.fromJson(data);
      } else if (response.statusCode == 429) {
        throw Exception('Rate Limited 😢');
      } else {
        throw Exception('Rate Limited 😢');
      }
    } catch (e) {
      throw Exception('$e');
    }
  }
}
