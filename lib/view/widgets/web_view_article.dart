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

  /// Retries loading the web page.
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
          /// The web view widget.
          ClipRRect(
            child: WebViewWidget(controller: _webViewController),
          ),

          /// A loading indicator displayed while the web view is loading.
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),

          /// An error message and retry button displayed if the web view fails to load.
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
