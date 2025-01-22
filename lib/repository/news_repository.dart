import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:smallnews/models/models.dart';

class NewsRepository {
  static Future<NewsResponse> fetchNews(String query, int page) async {
    final String apiKey = dotenv.env['NEWS_API_KEY'] ?? '';
    const String baseUrl = 'https://newsapi.org/v2/everything';
    try {
      final DateTime now = DateTime.now();
      final DateTime thirtyDaysAgo = now.subtract(const Duration(days: 30));
      final String fromDate = DateFormat('yyyy-MM-dd').format(thirtyDaysAgo);

      final String url = '$baseUrl?q=$query'
          '&from=$fromDate'
          '&sortBy=publishedAt'
          '&page=$page'
          '&pageSize=20'
          '&apiKey=$apiKey';

      print('Request URL: $url');

      final response = await http.get(Uri.parse(url));

      print('Response Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return NewsResponse.fromJson(data);
      } else {
        throw Exception('Failed to load news: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
      throw Exception('Network error: $e');
    }
  }
}
