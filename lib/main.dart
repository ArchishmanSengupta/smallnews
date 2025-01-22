import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'smallnews',
      theme: ThemeData(
        fontFamily: 'Graphik',
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

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
      body: Center(
        child: Image.asset('assets/images/smallnews_logo.png'),
      ),
    );
  }
}
