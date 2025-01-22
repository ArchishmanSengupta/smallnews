import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:smallnews/models/models.dart';

class NewsRepository {
  Future<NewsResponse> fetchNews(String query, int page) async {
    final String apiKey = dotenv.env['NEWS_API_KEY'] ?? '';
    const String baseUrl = 'https://newsapi.org/v2/everything';
    try {
      final DateTime now = DateTime.now();
      final DateTime thirtyDaysAgo = now.subtract(const Duration(days: 30));
      final String fromDate = DateFormat('yyyy-MM-dd').format(thirtyDaysAgo);

      final response = await http.get(
        Uri.parse('$baseUrl?q=$query'
            '&from=$fromDate'
            '&sortBy=publishedAt'
            '&page=$page'
            '&pageSize=20'
            '&apiKey=$apiKey'),
      );
      NewsResponse newsResponse;
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        newsResponse = NewsResponse.fromJson(data);
      } else {
        throw Exception('Failed to load news');
      }

      return newsResponse;
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
}
