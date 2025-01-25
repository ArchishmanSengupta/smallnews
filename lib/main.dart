import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smallnews/controller/controller.dart';
import 'package:smallnews/data/data.dart';
import 'package:smallnews/view/view.dart';

void main() async {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => NewsProvider()),
          ChangeNotifierProvider(create: (_) => NewsSearchProvider()),
        ],
        child: MaterialApp(
          title: AppStrings.appName,
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
              fontFamily: 'Graphik',
              scaffoldBackgroundColor: AppTheme.backgroundColor),
          home: const HomePage(),
        ));
  }
}
