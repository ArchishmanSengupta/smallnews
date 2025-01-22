import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:smallnews/models/models.dart';

class BreakingNewsCard extends StatelessWidget {
  final Article article;

  const BreakingNewsCard({super.key, required this.article});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4.0,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12.0),
                  topRight: Radius.circular(12.0),
                ),
                child: Image.network(
                  article.urlToImage ?? 'assets/default_image.png',
                  height: 150.0,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                top: 8.0,
                left: 8.0,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      vertical: 4.0, horizontal: 8.0),
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Text(
                    article.source.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 8.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.whatshot,
                      color: Colors.orange,
                      size: 8.0,
                    ),
                    const SizedBox(width: 4.0),
                    const Text(
                      'Trending',
                      style: TextStyle(
                        fontSize: 8.0,
                        color: Colors.grey,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      DateFormat('d MMM y')
                          .format(DateTime.parse(article.publishedAt)),
                      style: const TextStyle(
                        fontSize: 8.0,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8.0),
                Text(
                  article.title,
                  style: const TextStyle(
                    fontSize: 10.0,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
