import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/user_model.dart';

class StorageService {
  static const String _keyAccessToken = 'access_token';
  static const String _keyRefreshToken = 'refresh_token';
  static const String _keyUser = 'user_data';
  static const String _keyHasSeenOnboarding = 'has_seen_onboarding';

  // Singleton pattern
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  SharedPreferences? _prefs;

  // Initialize storage
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Ensure storage is initialized
  Future<SharedPreferences> get _storage async {
    if (_prefs == null) {
      await init();
    }
    return _prefs!;
  }

  // ==================== TOKEN MANAGEMENT ====================

  /// Save access token
  Future<void> saveAccessToken(String token) async {
    final prefs = await _storage;
    await prefs.setString(_keyAccessToken, token);
  }

  /// Get access token
  Future<String?> getAccessToken() async {
    final prefs = await _storage;
    return prefs.getString(_keyAccessToken);
  }

  /// Save refresh token
  Future<void> saveRefreshToken(String token) async {
    final prefs = await _storage;
    await prefs.setString(_keyRefreshToken, token);
  }

  /// Get refresh token
  Future<String?> getRefreshToken() async {
    final prefs = await _storage;
    return prefs.getString(_keyRefreshToken);
  }

  /// Save both tokens
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await saveAccessToken(accessToken);
    await saveRefreshToken(refreshToken);
  }

  /// Clear tokens
  Future<void> clearTokens() async {
    final prefs = await _storage;
    await prefs.remove(_keyAccessToken);
    await prefs.remove(_keyRefreshToken);
  }

  // ==================== USER DATA ====================

  /// Save user data
  Future<void> saveUser(UserModel user) async {
    final prefs = await _storage;
    final userJson = jsonEncode(user.toJson());
    await prefs.setString(_keyUser, userJson);
  }

  /// Get user data
  Future<UserModel?> getUser() async {
    final prefs = await _storage;
    final userJson = prefs.getString(_keyUser);
    if (userJson == null) return null;
    
    try {
      final userMap = jsonDecode(userJson) as Map<String, dynamic>;
      return UserModel.fromJson(userMap);
    } catch (e) {
      print('Error parsing user data: $e');
      return null;
    }
  }

  /// Clear user data
  Future<void> clearUser() async {
    final prefs = await _storage;
    await prefs.remove(_keyUser);
  }

  // ==================== ONBOARDING ====================

  /// Mark onboarding as seen
  Future<void> setOnboardingSeen(bool seen) async {
    final prefs = await _storage;
    await prefs.setBool(_keyHasSeenOnboarding, seen);
  }

  /// Check if onboarding has been seen
  Future<bool> hasSeenOnboarding() async {
    final prefs = await _storage;
    return prefs.getBool(_keyHasSeenOnboarding) ?? false;
  }

  // ==================== LOGIN STATUS ====================

  /// Check if user is logged in (has valid tokens and user data)
  Future<bool> isLoggedIn() async {
    final accessToken = await getAccessToken();
    final user = await getUser();
    return accessToken != null && user != null;
  }

  // ==================== CLEAR ALL DATA ====================

  /// Clear all stored data (logout)
  Future<void> clearAll() async {
    await clearTokens();
    await clearUser();
    // Keep onboarding status
  }
}

final storageService = StorageService();
