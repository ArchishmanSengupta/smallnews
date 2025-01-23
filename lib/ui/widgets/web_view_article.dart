/// A widget that displays a web page using a WebView.
///
/// The [WebViewArticle] widget takes a URL as a required parameter and
/// displays the web page corresponding to that URL. It provides a loading
/// indicator while the page is loading and an error message with a retry
/// button if the page fails to load.
///
/// The [WebViewArticle] widget is a [StatefulWidget] that manages the state
/// of the web view, including loading state and error handling.
///
/// Example usage:
/// ```dart
/// WebViewArticle.show(context, 'https://example.com');
/// ```
///
/// The [WebViewArticle] widget can be shown using the static [show] method,
/// which takes a [BuildContext] and a URL as parameters and pushes the
/// [WebViewArticle] widget onto the navigation stack.
///
/// The [WebViewArticle] widget uses the [webview_flutter] package to display
/// the web page and provides unrestricted JavaScript mode and a white
/// background color for the web view.
///
/// The widget also handles navigation events such as page start, page finish,
/// and navigation requests, and updates the loading state accordingly.
///
/// If an error occurs while loading the web page, an error message is displayed
/// with a retry button that allows the user to retry loading the page.
library;

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewArticle extends StatefulWidget {
  final String url;

  const WebViewArticle({
    super.key,
    required this.url,
  });

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

class _WebViewArticleState extends State<WebViewArticle> {
  late final WebViewController _webViewController;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeWebViewController();
  }

  void _initializeWebViewController() {
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() {
              _isLoading = true;
              _errorMessage = null;
            });
          },
          onPageFinished: (String url) {
            setState(() {
              _isLoading = false;
            });
          },
          onNavigationRequest: (NavigationRequest request) {
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(
        Uri.parse(widget.url),
        method: LoadRequestMethod.get,
      );
  }

  void _retryLoading() {
    setState(() {
      _errorMessage = null;
      _isLoading = true;
    });
    _webViewController.loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          ClipRRect(
            child: WebViewWidget(controller: _webViewController),
          ),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
          if (_errorMessage != null)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Error loading webpage: $_errorMessage',
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _retryLoading,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
