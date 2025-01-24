import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smallnews/data/strings/strings.dart';
import 'package:smallnews/provider/provider.dart';
import 'package:smallnews/theme/app_theme.dart';
import 'package:smallnews/ui/ui.dart';

void main() async {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
        create: (_) => NewsProvider(),
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
