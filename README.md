# Smallnews: Live News Update

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
1. Run `dart run build_runner build -d` to generate the `.g.dart` file.

## Security Enhancement
Using a `.env` file and generating an app bundle with it may raise security concerns. These files can be easily accessed by anyone who decompiles the app or gains access to the source code repository, leading to unauthorized use of services and potential data breaches.

### Solution:
We use the `envied` package to obfuscate the API key by encoding it to a list of integers.

```dart
static const List<int> _enviedkeynewsApiKey = <int>[
    491027154,
    2924727066,
    3751629007,
    // ...
];
```

This ensures that your API key remains secure and protected from unauthorized access.

---

Stay informed with Smallnews – your trusted source for live news updates!
