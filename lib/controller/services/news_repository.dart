library;

import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:smallnews/data/models/models.dart';
import 'package:smallnews/env/env.dart';

/// A repository class that handles fetching news data from the News API.
class NewsRepository {
  static String get apiKey => Env.newsApiKey;

  static const String authority = 'newsapi.org';

  static Future<NewsResponse> fetchNews(String query, int page) async {
    const String path = '/v2/everything';
    final DateTime now = DateTime.now();

    /// For the Free Plan for newsapi.org, the maximum allowed date range is 30 days.
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

    print('----------------------------------------\n\n\n\n\n');
    print(url);
    print('----------------------------------------\n\n\n\n\n');

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

  static Future<NewsResponse> fetchNewsByCategory(
      String category, int page) async {
    const String path = '/v2/top-headlines';

    final String url = Uri.https(authority, path, {
      'country': 'us',
      'category': category,
      'page': page.toString(),
      'pageSize': '20',
      'apiKey': apiKey,
    }).toString();

    print('----------------------------------------\n\n\n\n\n');
    print(url);
    print('----------------------------------------\n\n\n\n\n');

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

  static Future<NewsResponse> fetchTopHeadlines(int page) async {
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
