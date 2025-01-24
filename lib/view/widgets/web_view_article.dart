library;

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewArticle extends StatefulWidget {
  /// The URL of the article to be displayed.
  final String url;

  /// Creates a [WebViewArticle] widget.
  ///
  /// The [url] parameter is required and specifies the URL of the article to be displayed.
  const WebViewArticle({
    super.key,
    required this.url,
  });

  /// Shows the [WebViewArticle] widget in a new route.
  ///
  /// This static method pushes a new route onto the navigator that displays the [WebViewArticle] widget.
  ///
  /// [context] is the build context.
  /// [url] is the URL of the article to be displayed.
  static void show(BuildContext context, String url) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => WebViewArticle(url: url),
      ),
    );
  }

  @override
  State<WebViewArticle> createState() => _WebViewArticleState();
}

/// The state for the [WebViewArticle] widget.
class _WebViewArticleState extends State<WebViewArticle> {
  /// The controller for the web view.
  late final WebViewController _webViewController;

  /// Indicates whether the web view is currently loading.
  bool _isLoading = true;

  /// An optional error message to be displayed if the web view fails to load.
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeWebViewController();
  }

  /// Initializes the web view controller.
  void _initializeWebViewController() {
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..setNavigationDelegate(
        NavigationDelegate(
          /// Called when the page starts loading.
          onPageStarted: (String url) {
            setState(() {
              _isLoading = true;
              _errorMessage = null;
            });
          },

          /// Called when the page finishes loading.
          onPageFinished: (String url) {
            setState(() {
              _isLoading = false;
            });
          },

          /// Called when a navigation request is made.
          onNavigationRequest: (NavigationRequest request) {
            return NavigationDecision.navigate;
          },

          /// Called when an error occurs during navigation.
          onWebResourceError: (WebResourceError error) {
            setState(() {
              _isLoading = false;
              _errorMessage = error.description;
            });
          },
        ),
      )
      ..loadRequest(
        Uri.parse(widget.url),
        method: LoadRequestMethod.get,
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ClipRRect(
        child: WebViewWidget(controller: _webViewController),
      ),
    );
  }
}
