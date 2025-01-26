import 'package:envied/envied.dart';

part 'env.g.dart';

/// Secure environment configuration using encrypted obfuscation
/// Stores sensitive API keys and configuration values
/// Generate with: flutter pub run build_runner build --delete-conflicting-outputs
@Envied(obfuscate: true) // Obfuscates values in compiled code
abstract class Env {
  // Maps to .env variable name
  @EnviedField(varName: 'NEWS_API_KEY')
  // Obfuscated storage
  static final String newsApiKey = _Env.newsApiKey;
}
