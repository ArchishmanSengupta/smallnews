import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:smallnews/provider/provider.dart';
import 'package:smallnews/ui/ui.dart';

void main() async {
  await dotenv.load(fileName: ".env");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
        create: (_) => NewsProvider(),
        child: MaterialApp(
          title: 'smallnews',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            fontFamily: 'Graphik',
          ),
          home: const HomePage(),
        ));
  }
}
