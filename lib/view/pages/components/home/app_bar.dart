import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:smallnews/data/images/app_images.dart';
import 'package:smallnews/data/strings/app_strings.dart';
import 'package:smallnews/view/pages/search_page.dart';
import 'package:smallnews/view/routes/app_routes.dart';
import 'package:smallnews/view/theme/app_theme.dart';

class AppBarWidget {
  static PreferredSizeWidget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppTheme.backgroundColor,
      actions: [
        GestureDetector(
          onTap: () {
            Navigator.push(context, AppRoutes.createRoute(const SearchPage()));
          },
          child: const Padding(
            padding: EdgeInsets.only(right: 20.0, top: 20.0),
            child: Icon(CupertinoIcons.search),
          ),
        )
      ],
      centerTitle: true,
      title: Padding(
        padding: const EdgeInsets.only(top: 20.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Image.asset(
                AppImages.logo,
                height: 30,
                width: 30,
              ),
            ),
            const Text(
              AppStrings.appName,
              style: TextStyle(
                  fontSize: 16, fontFamily: 'Graphik', letterSpacing: 1),
            ),
          ],
        ),
      ),
    );
  }
}
