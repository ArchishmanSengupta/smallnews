# Smallnews: Live News Update


https://github.com/user-attachments/assets/c2694128-93d7-4cd2-ba6a-aae3def3fa01




## Overview
Smallnews is your go-to app for staying informed with live news updates throughout the day. With a sleek design and user-friendly interface, Smallnews ensures you never miss out on the latest headlines and in-depth stories.

## Features

### Get Top Headlines Throughout the Day
Stay updated with the latest news headlines delivered right to your screen.
![Top Headlines](https://github.com/user-attachments/assets/3f308afb-6aa5-4815-8a86-ea6c1acd289b)

### Read the Whole Story
Dive deeper into the news with comprehensive articles that provide all the details you need.
![Full Story](https://github.com/user-attachments/assets/bb222720-b803-400b-bec2-5225c899eb2a)

### Concise Error Messages
Clear and informative error messages help you understand any issues quickly.
![Error Messages](https://github.com/user-attachments/assets/dc30be79-148d-4ce0-916e-3d1bc66b0fc8)

### Proper Shimmered Loading ✨
Enjoy a smooth loading experience with our shimmered loading effect.
![Shimmered Loading](https://github.com/user-attachments/assets/687ad7de-1c03-4605-b145-270cfa3f967b)

### Scroll to refresh
Always stay updated

https://github.com/user-attachments/assets/e01e5daa-ecb6-4904-9f40-5b815fe4866c

### Scroll Offset


https://github.com/user-attachments/assets/b9931057-d84e-4d03-bf88-0b3a8f95d725





## Installation

### Pre-requisites:
1. Create an `.env` file.
2. Add the key `NEWS_API_KEY` and use the API key from [newsapi.org](https://newsapi.org/).
3. Note the rate limit: 1000 requests in the free version. Please check the daily API calls limit on their website.

### Flutter Packages:
1. Run `flutter pub get` to install all the packages.
2. Ensure you have the `envied` and `envied_generator` dependencies properly installed.
3. Install `build_runner` for Dart's dependencies.
4. Run `dart pub add dev:build_runner` if you haven't already.

If you are changing the `NEWS_API_KEY` in the `.env` file:
1. Run `flutter pub run build_runner build --delete-conflicting-outputs` to generate the `.g.dart` file.

## Security Enhancement
Using a `.env` file and generating an app bundle with it may raise security concerns. These files can be easily accessed by anyone who decompiles the app or gains access to the source code repository, leading to unauthorized use of services and potential data breaches.

### Solution:
We use the `envied` package:

1. Eliminates plain-text secret storage in source control through compile-time encryption
2. Obfuscation Mechanics: Converts strings to integer arrays using XOR cipher during build process
3. Compile-time encryption protects secrets in binaries
4. Runtime decryption prevents memory scanning attacks
5. Git-ignored generated files prevent accidental exposure
6. Best Practice: Combine with ProGuard/R8 for Android and iOS hardening

```dart
static const List<int> _enviedkeynewsApiKey = <int>[
    491027154,
    2924727066,
    3751629007,
    // ...
];
```

This ensures that your API key remains secure and protected from unauthorized access.

Performance Optimization
```dart
Copy
// Scroll controller management
scrollController.addListener(() {
  final maxScroll = scrollController.position.maxScrollExtent;
  final currentScroll = scrollController.position.pixels;
  const scrollThreshold = 100;
  
  if (maxScroll - currentScroll <= scrollThreshold && 
      !isLoading && 
      !hasReachedEnd) {
    loadMoreArticles();
  }
});
```
Optimization Strategies:

Scroll Throttling: 100px threshold balances responsiveness and over-fetching

Memory Preservation:

Maintains scroll positions across tab switches

Prevents widget rebuilds using PageStorageKey

Rendering Engine:

dart
Copy
// main.dart
void main() {
  SkiaGoldComparator.enable = true; // Visual regression testing
  runApp(MyApp());
}
Skia Benefits:

Consistent frame pacing across iOS/Android

Better compatibility with complex SVG animations

Mature plugin ecosystem (e.g., flutter_sequence_animation)

State Management
dart
Copy
// Atomic state updates
NewsListModel copyWith({
  List<ArticleModel>? articles,
  int? currentPage,
  bool? isLoading,
}) {
  return NewsListModel(
    articles: articles ?? this.articles,
    currentPage: currentPage ?? this.currentPage,
    isLoading: isLoading ?? this.isLoading,
    // Maintain existing controllers
    scrollController: this.scrollController,
  );
}
Architectural Patterns:

Immutable State: Enables predictable state transitions

Controller Pooling: Reuses scroll controllers to prevent jank

Pagination Logic:

dart
Copy
Future<void> loadMore() async {
  if (isLoading || !hasMore) return;
  
  setState(() => isLoading = true);
  final newArticles = await fetchPage(currentPage + 1);
  
  setState(() {
    articles = [...articles, ...newArticles];
    currentPage++;
    isLoading = false;
  });
}
Critical Considerations:

Race condition prevention with loading flags

Deduplication via page tracking

Smart merging using spread operator

Storage Strategy
dart
Copy
// Multi-engine abstraction
class KeyValueStorageBase {
  static Future<bool> setCommon<T>(String key, T value) async {
    if (_didGetStorageInitialize) {
      return _getStorage!.write(key, value);
    }
    return _sharedPrefs!.set(key, value);
  }
}
Storage Architecture:

Memory First: GetStorage provides 0ms read latency

Disk Fallback: SharedPreferences for cold starts

LRU Cache:

dart
Copy
void _updateCache(List<ArticleModel> articles) {
  if (_searchCache.length > 5) {
    _searchCache.removeRange(0, _searchCache.length - 5);
  }
  _searchCache.addAll(articles);
}
Cache Invalidation:

Time-based expiration (not shown)

Size-based eviction policy

Write-through consistency

Architectural Patterns
dart
Copy
// SOLID Service Layer
class NewsService {
  static Future<NewsResponseModel> fetchNews(String query, int page) {
    final uri = _buildUri(query, page);
    return _handleResponse(await http.get(uri));
  }
  
  static Uri _buildUri(String query, int page) {
    return Uri.https('newsapi.org', '/v2/everything', {
      'q': query,
      'page': page.toString(),
      'apiKey': Env.newsApiKey,
    });
  }
}
Service Design:

Single Responsibility: Pure API communication

Open/Closed: Extend via decorators (e.g., caching)

Dependency Inversion: Consumes env config

Error Handling
dart
Copy
// Unified error mapping
try {
  final response = await http.get(uri);
  if (response.statusCode == 429) {
    throw RateLimitException('API quota exceeded');
  }
  return parseResponse(response);
} on SocketException {
  throw NetworkException('No internet connection');
} catch (e) {
  throw AppException('Operation failed');
}

// Consumer side
errorState = e is RateLimitException 
  ? 'Slow down!' 
  : 'Something went wrong';
Error Handling Strategy:

Defensive Programming: Catch specific exceptions first

User-Friendly Messages: Avoid technical jargon

Recovery Paths: Retry buttons with exponential backoff
---

Stay informed with Smallnews – your trusted source for live news updates!
