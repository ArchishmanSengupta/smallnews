// import 'package:flutter/material.dart';
// import 'package:webview_flutter/webview_flutter.dart';

// class WebViewArticle extends StatefulWidget {
//   final String url;

//   const WebViewArticle({
//     super.key,
//     required this.url,
//   });

//   static void show(BuildContext context, String url) {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.only(
//           topLeft: Radius.circular(20),
//           topRight: Radius.circular(20),
//         ),
//       ),
//       backgroundColor: Colors.white,
//       builder: (context) => DraggableScrollableSheet(
//         initialChildSize: 0.9,
//         minChildSize: 0.5,
//         maxChildSize: 0.95,
//         builder: (_, controller) => WebViewArticle(
//           url: url,
//         ),
//       ),
//     );
//   }

//   @override
//   State<WebViewArticle> createState() => _WebViewArticleState();
// }

// class _WebViewArticleState extends State<WebViewArticle> {
//   late final WebViewController _webViewController;
//   bool _isLoading = true;
//   String? _errorMessage;

//   @override
//   void initState() {
//     super.initState();
//     _initializeWebViewController();
//   }

//   void _initializeWebViewController() {
//     _webViewController = WebViewController()
//       ..setJavaScriptMode(JavaScriptMode.unrestricted)
//       ..setBackgroundColor(Colors.white)
//       ..setNavigationDelegate(
//         NavigationDelegate(
//           onPageStarted: (String url) {
//             setState(() {
//               _isLoading = true;
//               _errorMessage = null;
//             });
//           },
//           onPageFinished: (String url) {
//             setState(() {
//               _isLoading = false;
//             });
//           },
//           onWebResourceError: (WebResourceError error) {
//             // _handleWebResourceError(error);
//           },
//           onNavigationRequest: (NavigationRequest request) {
//             // Optional: Add custom navigation handling
//             return NavigationDecision.navigate;
//           },
//         ),
//       )
//       ..loadRequest(
//         Uri.parse(widget.url),
//         method: LoadRequestMethod.get,
//       );
//   }

//   void _retryLoading() {
//     setState(() {
//       _errorMessage = null;
//       _isLoading = true;
//     });
//     _webViewController.loadRequest(Uri.parse(widget.url));
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       decoration: const BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.only(
//           topLeft: Radius.circular(20),
//           topRight: Radius.circular(20),
//         ),
//       ),
//       child: Column(
//         children: [
//           _buildDragHandle(),
//           Expanded(
//             child: _buildWebViewContent(),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildDragHandle() {
//     return Container(
//       height: 5,
//       width: 50,
//       margin: const EdgeInsets.symmetric(vertical: 10),
//       decoration: BoxDecoration(
//         color: Colors.grey[300],
//         borderRadius: BorderRadius.circular(10),
//       ),
//     );
//   }

//   Widget _buildWebViewContent() {
//     if (_errorMessage != null) {
//       return Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Text(
//               'Error loading webpage: $_errorMessage',
//               style: const TextStyle(color: Colors.red),
//               textAlign: TextAlign.center,
//             ),
//             const SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: _retryLoading,
//               child: const Text('Retry'),
//             ),
//           ],
//         ),
//       );
//     }

//     return Stack(
//       children: [
//         WebViewWidget(controller: _webViewController),
//         if (_isLoading)
//           const Center(
//             child: CircularProgressIndicator(),
//           ),
//       ],
//     );
//   }
// }

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
          WebViewWidget(controller: _webViewController),
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
