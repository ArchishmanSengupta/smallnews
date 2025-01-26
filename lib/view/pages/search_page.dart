import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smallnews/controller/controller.dart';
import 'package:smallnews/view/pages/pages.dart';

/// Search functionality hub with animated transitions and state management
///
/// Key Features:
/// - Integrated search controller lifecycle management
/// - Coordinated animation system
/// - Theme customization for search context
/// - Safe area handling for notched devices
///
/// State Management:
/// - Manages NewsSearchProvider lifecycle
/// - Coordinates animation controller disposal
/// - Handles widget tree rebuilds through provider
class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage>
    with SingleTickerProviderStateMixin {
  late final NewsSearchProvider _controller;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    // Controller initialization with provider access
    _controller = context.read<NewsSearchProvider>();

    // Animation setup for entrance effects
    // Optimal transition timing
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        scaffoldBackgroundColor: Colors.grey[50],
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.grey[50],
          elevation: 0,
        ),
      ),
      child: Scaffold(
        body: SafeArea(
          // Device notch/padding awareness
          child: Column(
            children: [
              // Animated header section
              SearchAppBar(
                animationController: _animationController,
                controller: _controller,
              ),
              // Scrollable content area
              Expanded(
                child: SearchContent(controller: _controller),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Critical resource cleanup
  @override
  void dispose() {
    // Stop animation resources
    _animationController.dispose();
    super.dispose();
  }
}
