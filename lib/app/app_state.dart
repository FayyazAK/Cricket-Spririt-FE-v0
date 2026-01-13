import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../services/api/api_service.dart';
import '../services/storage/storage_service.dart';

/// App state for managing authentication and user data
class AppState extends ChangeNotifier {
  bool hasSeenOnboarding = false;
  bool isLoggedIn = false;
  UserModel? currentUser;
  bool _isInitialized = false;

  bool get isInitialized => _isInitialized;

  /// Initialize app state from storage
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Load onboarding status
      hasSeenOnboarding = await storageService.hasSeenOnboarding();

      // Load login status and user data
      final isUserLoggedIn = await storageService.isLoggedIn();
      if (isUserLoggedIn) {
        // Load user data
        currentUser = await storageService.getUser();
        
        // Load tokens
        final accessToken = await storageService.getAccessToken();
        final refreshToken = await storageService.getRefreshToken();
        
        if (accessToken != null && refreshToken != null) {
          apiService.setTokens(accessToken, refreshToken);
          isLoggedIn = true;
        }
      }

      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      print('Error initializing app state: $e');
      _isInitialized = true;
      notifyListeners();
    }
  }

  Future<void> completeOnboarding() async {
    hasSeenOnboarding = true;
    await storageService.setOnboardingSeen(true);
    notifyListeners();
  }

  Future<void> login({UserModel? user}) async {
    isLoggedIn = true;
    hasSeenOnboarding = true;
    
    if (user != null) {
      currentUser = user;
      await storageService.saveUser(user);
    }
    
    await storageService.setOnboardingSeen(true);
    
    // Tokens are already saved by apiService, but let's ensure they're in storage
    final accessToken = apiService.accessToken;
    final refreshToken = apiService.refreshToken;
    if (accessToken != null && refreshToken != null) {
      await storageService.saveTokens(
        accessToken: accessToken,
        refreshToken: refreshToken,
      );
    }
    
    notifyListeners();
  }

  Future<void> updateUser(UserModel user) async {
    currentUser = user;
    await storageService.saveUser(user);
    notifyListeners();
  }

  Future<void> logout() async {
    isLoggedIn = false;
    currentUser = null;
    
    // Clear tokens from API service
    apiService.clearTokens();
    
    // Clear all stored data
    await storageService.clearAll();
    
    notifyListeners();
  }
}

final appState = AppState();

