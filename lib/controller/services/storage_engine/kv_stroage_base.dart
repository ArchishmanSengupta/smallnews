import 'dart:async';

import 'package:get_storage/get_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Base class containing a unified API for key-value pairs' storage.
/// This class provides low level methods for storing:
/// - Sensitive keys using [FlutterSecureStorage]
/// - Insensitive keys using [SharedPreferences]
class KeyValueStorageBase {
  /// Instance of shared preferences
  static SharedPreferences? _sharedPrefs;
  static GetStorage? _getStorage;

  /// Singleton instance of KeyValueStorage Helper
  static KeyValueStorageBase? _instance;

  static bool _didGetStorageInitialize = false;

  /// Get instance of this class
  factory KeyValueStorageBase() => _instance ?? const KeyValueStorageBase._();

  /// Private constructor
  const KeyValueStorageBase._();

  /// Initializer for shared prefs and flutter secure storage
  /// Should be called in main before runApp and
  /// after WidgetsBinding.FlutterInitialized(), to allow for synchronous tasks
  /// when possible.
  static Future<void> init() async {
    _sharedPrefs ??= await SharedPreferences.getInstance();
    _didGetStorageInitialize = await GetStorage.init();
    _getStorage ??= GetStorage();
  }

  /// Reads the value for the key from common preferences storage
  T? getCommon<T>(String key) {
    T? res;
    if (_didGetStorageInitialize) {
      res = _getStorage!.read<T>(key);
    }
    if (res != null) return res;
    try {
      if (T == String) {
        return _sharedPrefs!.getString(key) as T?;
      } else if (T == int) {
        return _sharedPrefs!.getInt(key) as T?;
      } else if (T == bool) {
        return _sharedPrefs!.getBool(key) as T?;
      } else if (T == double) {
        return _sharedPrefs!.getDouble(key) as T?;
      }
      return _sharedPrefs!.get(key) as T?;
    } on Exception {
      return null;
    }
  }

  /// Sets the value for the key to common preferences storage
  Future<bool> setCommon<T>(String key, T value) async {
    if (_didGetStorageInitialize) {
      try {
        await _getStorage!.write(key, value);
        return true;
      } catch (err) {
        return false;
      }
    } else {
      if (T == String) {
        return _sharedPrefs!.setString(key, value as String);
      } else if (T == int) {
        return _sharedPrefs!.setInt(key, value as int);
      } else if (T == bool) {
        return _sharedPrefs!.setBool(key, value as bool);
      } else if (T == double) {
        return _sharedPrefs!.setDouble(key, value as double);
      } else {
        return _sharedPrefs!.setString(key, value as String);
      }
    }
  }

  /// Clears a value associated with a common key from storage.
  ///
  /// Uses either GetStorage or SharedPreferences depending on initialization state.
  ///
  /// Parameters:
  ///   - [key]: The key to remove from storage
  ///
  /// Returns:
  ///   A [Future<bool>] that completes with:
  ///   - true if removal was successful
  ///   - false if an error occurred during removal with GetStorage
  ///   - result of SharedPreferences.remove() if using SharedPreferences
  Future<bool> clearCommonKey(String key) async {
    if (_didGetStorageInitialize) {
      try {
        await _getStorage!.remove(key);
        return true;
      } catch (err) {
        return false;
      }
    } else {
      return _sharedPrefs!.remove(key);
    }
  }

  /// Erases common preferences keys
  Future<bool> clearCommon() async {
    if (_didGetStorageInitialize) {
      try {
        await _getStorage!.erase();
        return true;
      } catch (err) {
        return false;
      }
    } else {
      return _sharedPrefs!.clear();
    }
  }
}
