import 'package:flutter/material.dart';

/// A utility class for defining custom page routes with slide transitions.
class AppRoutes {
  /// Creates a slide transition route for a given page.
  ///
  /// [page] is the widget to be displayed in the route.
  /// Returns a [PageRouteBuilder] with a slide transition.
  static PageRouteBuilder _createSlideRoute(Widget page) {
    return PageRouteBuilder(
      /// Builds the page to be displayed.
      pageBuilder: (context, animation, secondaryAnimation) => page,

      /// Builds the transition animation.
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        /// The starting offset of the slide transition.
        const begin = Offset(1.0, 0.0);

        /// The ending offset of the slide transition.
        const end = Offset.zero;

        /// Creates a tween animation from the beginning to the ending offset.
        final tween = Tween(begin: begin, end: end);

        /// Drives the tween animation with the route's animation.
        final offsetAnimation = animation.drive(tween);

        /// Returns a [SlideTransition] widget that applies the offset animation to the child.
        return SlideTransition(
          position: offsetAnimation,
          child: child,
        );
      },

      /// The duration of the slide transition.
      transitionDuration: const Duration(milliseconds: 300),
    );
  }

  /// Creates a custom page route with a slide transition.
  ///
  /// [page] is the widget to be displayed in the route.
  /// Returns a [PageRouteBuilder] with a slide transition.
  static PageRouteBuilder createRoute(Widget page) {
    return _createSlideRoute(page);
  }
}
