import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Image.asset('assets/images/smallnews_logo.png'),
        title: const Text(
          'smallnews',
          style: TextStyle(fontFamily: 'Graphik', fontSize: 24),
        ),
      ),
      body: const Column(
        children: [
          // NewsCard(article: article)
        ],
      ),
    );
  }
}
