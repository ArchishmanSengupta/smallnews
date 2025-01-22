import 'package:flutter/material.dart';
import 'package:smallnews/models/models.dart';
import 'package:smallnews/repository/respository.dart';
import 'package:smallnews/ui/widgets/news_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _searchController = TextEditingController();
  Future<NewsResponse>? _futureNewsResponse;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    final query = _searchController.text;
    if (query.isNotEmpty) {
      setState(() {
        _futureNewsResponse = NewsRepository.fetchNews(query, 1);
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Image.asset('assets/images/smallnews_logo.png'),
        title: const Text(
          'smallnews',
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Search news...',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder<NewsResponse>(
              future: _futureNewsResponse,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData ||
                    snapshot.data?.articles.isEmpty == true) {
                  return const Center(child: Text('No articles found.'));
                } else {
                  final articles = snapshot.data?.articles;
                  return ListView.builder(
                    itemCount: articles?.length ?? 0,
                    itemBuilder: (context, index) {
                      final article = articles?[index];
                      return NewsCard(article: article!);
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
