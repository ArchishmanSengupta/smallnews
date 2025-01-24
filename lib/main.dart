/// A Flutter news application that displays news articles.
///
/// This application uses the Provider package for state management and
/// implements a custom theme with the Graphik font family.
///
/// The main entry point of the application initializes the [NewsProvider]
/// and sets up the MaterialApp with custom theming.
///
/// The [MyApp] widget serves as the root of the application and configures:
/// * The application title
/// * Disable debug banner
/// * Custom theme settings including background color and font family
/// * Homepage as the initial route
library;

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
