import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import '../storage/storage_service.dart';

class ApiService {
  // For Android Emulator, use 10.0.2.2 instead of localhost
  // For iOS Simulator, use localhost
  // For Real Device, use your computer's IP address (e.g., http://192.168.1.5:4000)
  static const String baseUrl = 'http://10.0.2.2:4000/api/v1';
  
  String? _accessToken;
  String? _refreshToken;

  // Singleton pattern
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  void setTokens(String accessToken, String refreshToken) {
    _accessToken = accessToken;
    _refreshToken = refreshToken;
  }

  String? get accessToken => _accessToken;
  String? get refreshToken => _refreshToken;

  void clearTokens() {
    _accessToken = null;
    _refreshToken = null;
  }

  Map<String, String> _getHeaders({bool includeAuth = true}) {
    final headers = {
      'Content-Type': 'application/json',
    };
    if (includeAuth && _accessToken != null) {
      headers['Authorization'] = 'Bearer $_accessToken';
    }
    return headers;
  }

  // ==================== AUTH APIs ====================

  /// Register a new user (creates pending registration, sends OTP)
  /// POST /auth/register
  Future<Map<String, dynamic>> register({
    required String email,
    required String name,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: _getHeaders(includeAuth: false),
      body: jsonEncode({
        'email': email,
        'name': name,
        'password': password,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      final error = jsonDecode(response.body);
      throw Exception(_formatErrorMessage(error));
    }
  }

  /// Verify email with OTP (creates actual user account)
  /// POST /auth/verify-email
  Future<Map<String, dynamic>> verifyEmail({
    required String email,
    required String otp,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/verify-email'),
      headers: _getHeaders(includeAuth: false),
      body: jsonEncode({
        'email': email,
        'otp': otp,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      final error = jsonDecode(response.body);
      throw Exception(_formatErrorMessage(error));
    }
  }

  /// Resend verification OTP
  /// POST /auth/resend-verification-otp
  Future<Map<String, dynamic>> resendVerificationOtp({
    required String email,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/resend-verification-otp'),
      headers: _getHeaders(includeAuth: false),
      body: jsonEncode({
        'email': email,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      final error = jsonDecode(response.body);
      throw Exception(_formatErrorMessage(error));
    }
  }

  /// Login user (returns user data and tokens)
  /// POST /auth/login
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: _getHeaders(includeAuth: false),
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      // Store tokens in memory and storage
      if (data['data'] != null) {
        final accessToken = data['data']['accessToken'];
        final refreshToken = data['data']['refreshToken'];
        if (accessToken != null && refreshToken != null) {
          setTokens(accessToken, refreshToken);
          // Also save to persistent storage
          await storageService.saveTokens(
            accessToken: accessToken,
            refreshToken: refreshToken,
          );
        }
      }
      return data;
    } else {
      final error = jsonDecode(response.body);
      throw Exception(_formatErrorMessage(error));
    }
  }

  /// Refresh access token
  /// POST /auth/refresh
  Future<Map<String, dynamic>> refreshAccessToken() async {
    if (_refreshToken == null) {
      throw Exception('No refresh token available');
    }

    final response = await http.post(
      Uri.parse('$baseUrl/auth/refresh'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_refreshToken',
      },
      body: jsonEncode({
        'refreshToken': _refreshToken,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      // Update tokens in memory and storage
      if (data['data'] != null) {
        final accessToken = data['data']['accessToken'];
        final refreshToken = data['data']['refreshToken'];
        if (accessToken != null && refreshToken != null) {
          setTokens(accessToken, refreshToken);
          // Also save to persistent storage
          await storageService.saveTokens(
            accessToken: accessToken,
            refreshToken: refreshToken,
          );
        }
      }
      return data;
    } else {
      final error = jsonDecode(response.body);
      throw Exception(_formatErrorMessage(error));
    }
  }

  /// Forgot password - request password reset OTP
  /// POST /auth/forgot-password
  Future<Map<String, dynamic>> forgotPassword({
    required String email,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/forgot-password'),
      headers: _getHeaders(includeAuth: false),
      body: jsonEncode({
        'email': email,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      final error = jsonDecode(response.body);
      throw Exception(_formatErrorMessage(error));
    }
  }

  /// Reset password with OTP
  /// POST /auth/reset-password
  Future<Map<String, dynamic>> resetPassword({
    required String token,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/reset-password'),
      headers: _getHeaders(includeAuth: false),
      body: jsonEncode({
        'token': token,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      final error = jsonDecode(response.body);
      throw Exception(_formatErrorMessage(error));
    }
  }

  /// Get current authenticated user
  /// GET /auth/me
  Future<Map<String, dynamic>> getCurrentUser() async {
    final response = await http.get(
      Uri.parse('$baseUrl/auth/me'),
      headers: _getHeaders(),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else if (response.statusCode == 401) {
      // Try to refresh token
      try {
        await refreshAccessToken();
        // Retry the request
        return getCurrentUser();
      } catch (e) {
        throw Exception('Session expired. Please login again.');
      }
    } else {
      final error = jsonDecode(response.body);
      throw Exception(_formatErrorMessage(error));
    }
  }

  // ==================== PLAYER APIs ====================

  /// Get all bowling types
  /// GET /bowling-types
  Future<Map<String, dynamic>> getBowlingTypes() async {
    final response = await http.get(
      Uri.parse('$baseUrl/bowling-types'),
      headers: _getHeaders(includeAuth: false),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      final error = jsonDecode(response.body);
      throw Exception(_formatErrorMessage(error));
    }
  }

  /// Upload profile picture
  /// POST /players/upload-profile-picture
  Future<Map<String, dynamic>> uploadProfilePicture(String filePath) async {
    // After cropping, the output file path may not have an extension on some devices.
    // Use a small header sniff to detect correct type.
    final headerBytes = await File(filePath).openRead(0, 32).first;
    final mimeType = lookupMimeType(filePath, headerBytes: headerBytes);
    if (mimeType == null) {
      throw Exception('Could not determine image type. Please choose a JPG/PNG/WebP image.');
    }

    const allowed = <String>{
      'image/jpeg',
      'image/jpg',
      'image/png',
      'image/webp',
    };
    if (!allowed.contains(mimeType.toLowerCase())) {
      throw Exception('Unsupported image type: $mimeType. Please choose a JPG/PNG/WebP image.');
    }

    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/players/upload-profile-picture'),
    );

    // Add authorization header
    if (_accessToken != null) {
      request.headers['Authorization'] = 'Bearer $_accessToken';
    }

    // Add file with correct content-type (backend validates mimetype)
    final parts = mimeType.split('/');
    final file = await http.MultipartFile.fromPath(
      'file',
      filePath,
      contentType: MediaType(parts[0], parts[1]),
    );
    request.files.add(file);

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else if (response.statusCode == 401) {
      // Try to refresh token and retry
      try {
        await refreshAccessToken();
        return uploadProfilePicture(filePath);
      } catch (e) {
        throw Exception('Session expired. Please login again.');
      }
    } else {
      final error = jsonDecode(response.body);
      throw Exception(_formatErrorMessage(error));
    }
  }

  /// Register player profile
  /// POST /players/register
  Future<Map<String, dynamic>> registerPlayer({
    required String firstName,
    required String lastName,
    required String gender,
    required String dateOfBirth,
    String? profilePicture,
    required String playerType,
    required bool isWicketKeeper,
    required String batHand,
    String? bowlHand,
    required List<String> bowlingTypeIds,
    required Map<String, dynamic> address,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/players/register'),
      headers: _getHeaders(),
      body: jsonEncode({
        'firstName': firstName,
        'lastName': lastName,
        'gender': gender,
        'dateOfBirth': dateOfBirth,
        if (profilePicture != null) 'profilePicture': profilePicture,
        'playerType': playerType,
        'isWicketKeeper': isWicketKeeper,
        'batHand': batHand,
        if (bowlHand != null) 'bowlHand': bowlHand,
        'bowlingTypeIds': bowlingTypeIds,
        'address': address,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else if (response.statusCode == 401) {
      // Try to refresh token and retry
      try {
        await refreshAccessToken();
        return registerPlayer(
          firstName: firstName,
          lastName: lastName,
          gender: gender,
          dateOfBirth: dateOfBirth,
          profilePicture: profilePicture,
          playerType: playerType,
          isWicketKeeper: isWicketKeeper,
          batHand: batHand,
          bowlHand: bowlHand,
          bowlingTypeIds: bowlingTypeIds,
          address: address,
        );
      } catch (e) {
        throw Exception('Session expired. Please login again.');
      }
    } else {
      final error = jsonDecode(response.body);
      throw Exception(_formatErrorMessage(error));
    }
  }

  /// Get all players
  /// GET /players
  Future<Map<String, dynamic>> getAllPlayers({
    String? gender,
    String? playerType,
    bool? isWicketKeeper,
    String? batHand,
    String? bowlHand,
    String? city,
    String? state,
    String? country,
    String? search,
    int? page,
    int? limit,
    String? sortBy,
    String? sortOrder,
  }) async {
    final queryParams = <String, String>{};
    if (gender != null) queryParams['gender'] = gender;
    if (playerType != null) queryParams['playerType'] = playerType;
    if (isWicketKeeper != null) {
      queryParams['isWicketKeeper'] = isWicketKeeper.toString();
    }
    if (batHand != null) queryParams['batHand'] = batHand;
    if (bowlHand != null) queryParams['bowlHand'] = bowlHand;
    if (city != null) queryParams['city'] = city;
    if (state != null) queryParams['state'] = state;
    if (country != null) queryParams['country'] = country;
    if (search != null && search.trim().isNotEmpty) {
      queryParams['search'] = search.trim();
    }
    if (page != null) queryParams['page'] = page.toString();
    if (limit != null) queryParams['limit'] = limit.toString();
    if (sortBy != null && sortBy.trim().isNotEmpty) {
      queryParams['sortBy'] = sortBy.trim();
    }
    if (sortOrder != null && sortOrder.trim().isNotEmpty) {
      queryParams['sortOrder'] = sortOrder.trim();
    }

    final uri = Uri.parse('$baseUrl/players').replace(queryParameters: queryParams);
    final response = await http.get(uri, headers: _getHeaders());

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else if (response.statusCode == 401) {
      try {
        await refreshAccessToken();
        return getAllPlayers(
          gender: gender,
          playerType: playerType,
          isWicketKeeper: isWicketKeeper,
          batHand: batHand,
          bowlHand: bowlHand,
          city: city,
          state: state,
          country: country,
          search: search,
          page: page,
          limit: limit,
          sortBy: sortBy,
          sortOrder: sortOrder,
        );
      } catch (e) {
        throw Exception('Session expired. Please login again.');
      }
    } else {
      final error = jsonDecode(response.body);
      throw Exception(_formatErrorMessage(error));
    }
  }

  /// Get player by ID
  /// GET /players/:id
  Future<Map<String, dynamic>> getPlayerById(String id) async {
    final response = await http.get(
      Uri.parse('$baseUrl/players/$id'),
      headers: _getHeaders(),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else if (response.statusCode == 401) {
      try {
        await refreshAccessToken();
        return getPlayerById(id);
      } catch (e) {
        throw Exception('Session expired. Please login again.');
      }
    } else {
      final error = jsonDecode(response.body);
      throw Exception(_formatErrorMessage(error));
    }
  }

  /// Update player profile
  /// PUT /players/:id
  Future<Map<String, dynamic>> updatePlayer({
    required String id,
    required Map<String, dynamic> updates,
  }) async {
    final response = await http.put(
      Uri.parse('$baseUrl/players/$id'),
      headers: _getHeaders(),
      body: jsonEncode(updates),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else if (response.statusCode == 401) {
      try {
        await refreshAccessToken();
        return updatePlayer(id: id, updates: updates);
      } catch (e) {
        throw Exception('Session expired. Please login again.');
      }
    } else {
      final error = jsonDecode(response.body);
      throw Exception(_formatErrorMessage(error));
    }
  }

  // ==================== CLUB APIs ====================

  /// Upload club profile picture
  /// POST /clubs/upload-profile-picture
  Future<Map<String, dynamic>> uploadClubProfilePicture(String filePath) async {
    final headerBytes = await File(filePath).openRead(0, 32).first;
    final mimeType = lookupMimeType(filePath, headerBytes: headerBytes);
    if (mimeType == null) {
      throw Exception('Could not determine image type. Please choose a JPG/PNG/WebP image.');
    }

    const allowed = <String>{
      'image/jpeg',
      'image/jpg',
      'image/png',
      'image/webp',
    };
    if (!allowed.contains(mimeType.toLowerCase())) {
      throw Exception('Unsupported image type: $mimeType. Please choose a JPG/PNG/WebP image.');
    }

    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/clubs/upload-profile-picture'),
    );

    if (_accessToken != null) {
      request.headers['Authorization'] = 'Bearer $_accessToken';
    }

    final parts = mimeType.split('/');
    final file = await http.MultipartFile.fromPath(
      'file',
      filePath,
      contentType: MediaType(parts[0], parts[1]),
    );
    request.files.add(file);

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else if (response.statusCode == 401) {
      try {
        await refreshAccessToken();
        return uploadClubProfilePicture(filePath);
      } catch (e) {
        throw Exception('Session expired. Please login again.');
      }
    } else {
      final error = jsonDecode(response.body);
      throw Exception(_formatErrorMessage(error));
    }
  }

  /// Get all clubs
  /// GET /clubs (Public endpoint - no auth required)
  Future<Map<String, dynamic>> getAllClubs() async {
    final response = await http.get(
      Uri.parse('$baseUrl/clubs'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      final error = jsonDecode(response.body);
      throw Exception(_formatErrorMessage(error));
    }
  }

  /// Create a new club
  /// POST /clubs
  Future<Map<String, dynamic>> createClub({
    required String name,
    String? profilePicture,
    String? bio,
    String? establishedDate,
    required Map<String, dynamic> address,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/clubs'),
      headers: _getHeaders(),
      body: jsonEncode({
        'name': name,
        if (profilePicture != null) 'profilePicture': profilePicture,
        if (bio != null) 'bio': bio,
        if (establishedDate != null) 'establishedDate': establishedDate,
        'address': address,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else if (response.statusCode == 401) {
      try {
        await refreshAccessToken();
        return createClub(
          name: name,
          profilePicture: profilePicture,
          bio: bio,
          establishedDate: establishedDate,
          address: address,
        );
      } catch (e) {
        throw Exception('Session expired. Please login again.');
      }
    } else {
      final error = jsonDecode(response.body);
      throw Exception(_formatErrorMessage(error));
    }
  }

  /// Get club by ID
  /// GET /clubs/:id
  Future<Map<String, dynamic>> getClubById(String id) async {
    final response = await http.get(
      Uri.parse('$baseUrl/clubs/$id'),
      headers: _getHeaders(),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else if (response.statusCode == 401) {
      try {
        await refreshAccessToken();
        return getClubById(id);
      } catch (e) {
        throw Exception('Session expired. Please login again.');
      }
    } else {
      final error = jsonDecode(response.body);
      throw Exception(_formatErrorMessage(error));
    }
  }

  /// Update club
  /// PUT /clubs/:id
  Future<Map<String, dynamic>> updateClub({
    required String id,
    required String name,
    String? profilePicture,
    String? bio,
    String? establishedDate,
    required Map<String, dynamic> address,
  }) async {
    final response = await http.put(
      Uri.parse('$baseUrl/clubs/$id'),
      headers: _getHeaders(),
      body: jsonEncode({
        'name': name,
        if (profilePicture != null) 'profilePicture': profilePicture,
        if (bio != null) 'bio': bio,
        if (establishedDate != null) 'establishedDate': establishedDate,
        'address': address,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else if (response.statusCode == 401) {
      try {
        await refreshAccessToken();
        return updateClub(
          id: id,
          name: name,
          profilePicture: profilePicture,
          bio: bio,
          establishedDate: establishedDate,
          address: address,
        );
      } catch (e) {
        throw Exception('Session expired. Please login again.');
      }
    } else {
      final error = jsonDecode(response.body);
      throw Exception(_formatErrorMessage(error));
    }
  }

  // ==================== HELPER METHODS ====================

  /// Format error message from API response
  String _formatErrorMessage(Map<String, dynamic> error) {
    final message = error['message'];
    
    // If message is a list (validation errors), join them
    if (message is List) {
      return message.join(', ');
    }
    
    // If message is a string, return it
    if (message is String) {
      return message;
    }
    
    // Fallback
    return 'An error occurred';
  }
}

final apiService = ApiService();
