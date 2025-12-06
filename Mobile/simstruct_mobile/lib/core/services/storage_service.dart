import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Storage Service - Handles local data persistence
class StorageService {
  static const String _themeKey = 'app_theme';
  static const String _onboardingKey = 'onboarding_complete';
  static const String _localeKey = 'app_locale';
  static const String _recentSearchesKey = 'recent_searches';
  static const String _favoritesKey = 'favorites';
  static const String _settingsKey = 'user_settings';

  SharedPreferences? _prefs;
  bool _isDarkMode = false;
  bool _isInitialized = false;

  // Getters
  bool get isDarkMode => _isDarkMode;
  bool get isInitialized => _isInitialized;

  /// Initialize storage service
  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    _isDarkMode = _prefs?.getBool(_themeKey) ?? false;
    _isInitialized = true;
  }

  /// Alias for initialize
  Future<void> init() => initialize();

  // ==================== THEME ====================

  /// Get theme mode
  Future<bool> getIsDarkMode() async {
    return _prefs?.getBool(_themeKey) ?? false;
  }

  /// Set theme mode
  Future<void> setDarkMode(bool value) async {
    _isDarkMode = value;
    await _prefs?.setBool(_themeKey, value);
  }

  /// Toggle theme mode
  Future<void> toggleTheme() async {
    await setDarkMode(!_isDarkMode);
  }

  // ==================== ONBOARDING ====================

  /// Check if onboarding is complete
  Future<bool> isOnboardingComplete() async {
    return _prefs?.getBool(_onboardingKey) ?? false;
  }

  /// Set onboarding complete
  Future<void> setOnboardingComplete(bool value) async {
    await _prefs?.setBool(_onboardingKey, value);
  }

  // ==================== LOCALE ====================

  /// Get stored locale
  Future<String?> getLocale() async {
    return _prefs?.getString(_localeKey);
  }

  /// Set locale
  Future<void> setLocale(String locale) async {
    await _prefs?.setString(_localeKey, locale);
  }

  // ==================== RECENT SEARCHES ====================

  /// Get recent searches
  Future<List<String>> getRecentSearches() async {
    final data = _prefs?.getString(_recentSearchesKey);
    if (data == null) return [];
    try {
      return List<String>.from(jsonDecode(data));
    } catch (e) {
      return [];
    }
  }

  /// Add recent search
  Future<void> addRecentSearch(String query) async {
    final searches = await getRecentSearches();
    searches.remove(query);
    searches.insert(0, query);
    if (searches.length > 10) {
      searches.removeLast();
    }
    await _prefs?.setString(_recentSearchesKey, jsonEncode(searches));
  }

  /// Clear recent searches
  Future<void> clearRecentSearches() async {
    await _prefs?.remove(_recentSearchesKey);
  }

  // ==================== FAVORITES ====================

  /// Get favorite simulation IDs
  Future<List<String>> getFavorites() async {
    final data = _prefs?.getString(_favoritesKey);
    if (data == null) return [];
    try {
      return List<String>.from(jsonDecode(data));
    } catch (e) {
      return [];
    }
  }

  /// Toggle favorite
  Future<void> toggleFavorite(String simulationId) async {
    final favorites = await getFavorites();
    if (favorites.contains(simulationId)) {
      favorites.remove(simulationId);
    } else {
      favorites.add(simulationId);
    }
    await _prefs?.setString(_favoritesKey, jsonEncode(favorites));
  }

  /// Check if is favorite
  Future<bool> isFavorite(String simulationId) async {
    final favorites = await getFavorites();
    return favorites.contains(simulationId);
  }

  // ==================== USER SETTINGS ====================

  /// Get user settings
  Future<Map<String, dynamic>> getUserSettings() async {
    final data = _prefs?.getString(_settingsKey);
    if (data == null) return _defaultSettings;
    try {
      return Map<String, dynamic>.from(jsonDecode(data));
    } catch (e) {
      return _defaultSettings;
    }
  }

  /// Update user settings
  Future<void> updateUserSettings(Map<String, dynamic> settings) async {
    final current = await getUserSettings();
    current.addAll(settings);
    await _prefs?.setString(_settingsKey, jsonEncode(current));
  }

  /// Reset user settings
  Future<void> resetUserSettings() async {
    await _prefs?.setString(_settingsKey, jsonEncode(_defaultSettings));
  }

  /// Default settings
  static const Map<String, dynamic> _defaultSettings = {
    'notifications': true,
    'emailNotifications': true,
    'pushNotifications': true,
    'soundEnabled': true,
    'vibrationEnabled': true,
    'autoSave': true,
    'showHints': true,
    'compactView': false,
    'defaultStructureType': 'beam',
    'defaultMaterial': 'steel',
    'units': 'metric',
  };

  // ==================== GENERIC STORAGE ====================

  /// Get string value
  Future<String?> getString(String key) async {
    return _prefs?.getString(key);
  }

  /// Set string value
  Future<void> setString(String key, String value) async {
    await _prefs?.setString(key, value);
  }

  /// Get int value
  Future<int?> getInt(String key) async {
    return _prefs?.getInt(key);
  }

  /// Set int value
  Future<void> setInt(String key, int value) async {
    await _prefs?.setInt(key, value);
  }

  /// Get bool value
  Future<bool?> getBool(String key) async {
    return _prefs?.getBool(key);
  }

  /// Set bool value
  Future<void> setBool(String key, bool value) async {
    await _prefs?.setBool(key, value);
  }

  /// Get double value
  Future<double?> getDouble(String key) async {
    return _prefs?.getDouble(key);
  }

  /// Set double value
  Future<void> setDouble(String key, double value) async {
    await _prefs?.setDouble(key, value);
  }

  /// Get JSON object
  Future<Map<String, dynamic>?> getJson(String key) async {
    final data = _prefs?.getString(key);
    if (data == null) return null;
    try {
      return Map<String, dynamic>.from(jsonDecode(data));
    } catch (e) {
      return null;
    }
  }

  /// Set JSON object
  Future<void> setJson(String key, Map<String, dynamic> value) async {
    await _prefs?.setString(key, jsonEncode(value));
  }

  /// Remove key
  Future<void> remove(String key) async {
    await _prefs?.remove(key);
  }

  /// Clear all storage
  Future<void> clearAll() async {
    await _prefs?.clear();
    _isDarkMode = false;
  }

  /// Check if key exists
  bool containsKey(String key) {
    return _prefs?.containsKey(key) ?? false;
  }
}
