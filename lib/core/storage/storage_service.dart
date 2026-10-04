import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String _keyToken = 'AUTH_TOKEN';
  static const String _keyIsLoggedIn = 'IS_LOGGED_IN';
  static const String _keyUserId = 'USER_ID';
  static const String _keyUserName = 'USER_NAME';
  static const String _keyUserEmail = 'USER_EMAIL';
  static const String _keyTheme = 'IS_DARK_MODE';
  static const String _keyUserPhotoPrefix = 'USER_PHOTO';

  static SharedPreferences? _prefs;

  static Future<SharedPreferences> get _instance async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  /// Inisialisasi awal saat aplikasi mulai
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Token
  static Future<void> saveToken(String token) async {
    final prefs = await _instance;
    await prefs.setString(_keyToken, token);
    await prefs.setBool(_keyIsLoggedIn, true);
  }

  static Future<String?> getToken() async {
    final prefs = await _instance;
    return prefs.getString(_keyToken);
  }

  // Session
  static Future<bool> isLoggedIn() async {
    final prefs = await _instance;
    final token = prefs.getString(_keyToken);
    final isLogged = prefs.getBool(_keyIsLoggedIn) ?? false;
    return isLogged && (token != null && token.isNotEmpty);
  }

  // User Data
  static Future<void> saveUserData({
    required int id,
    required String name,
    required String email,
  }) async {
    final prefs = await _instance;
    await prefs.setInt(_keyUserId, id);
    await prefs.setString(_keyUserName, name);
    await prefs.setString(_keyUserEmail, email);
  }

  static Future<void> updateUserName(String name) async {
    final prefs = await _instance;
    await prefs.setString(_keyUserName, name);
  }

  static Future<int?> getUserId() async {
    final prefs = await _instance;
    return prefs.getInt(_keyUserId);
  }

  static Future<String?> getUserName() async {
    final prefs = await _instance;
    return prefs.getString(_keyUserName);
  }

  static Future<String?> getUserEmail() async {
    final prefs = await _instance;
    return prefs.getString(_keyUserEmail);
  }

  // Profile Photo (Terkait dengan User ID agar saat ganti akun tidak tertukar)
  static Future<void> saveUserPhoto(int userId, String path) async {
    final prefs = await _instance;
    await prefs.setString('${_keyUserPhotoPrefix}_$userId', path);
  }

  static Future<String?> getUserPhoto(int userId) async {
    final prefs = await _instance;
    return prefs.getString('${_keyUserPhotoPrefix}_$userId');
  }

  static Future<void> removeUserPhoto(int userId) async {
    final prefs = await _instance;
    await prefs.remove('${_keyUserPhotoPrefix}_$userId');
  }

  // Theme
  static Future<void> setDarkMode(bool isDark) async {
    final prefs = await _instance;
    await prefs.setBool(_keyTheme, isDark);
  }

  static Future<bool> isDarkMode() async {
    final prefs = await _instance;
    return prefs.getBool(_keyTheme) ?? false;
  }

  // Logout / Clear
  static Future<void> clearSession() async {
    final prefs = await _instance;
    await prefs.remove(_keyToken);
    await prefs.remove(_keyIsLoggedIn);
    await prefs.remove(_keyUserId);
    await prefs.remove(_keyUserName);
    await prefs.remove(_keyUserEmail);
  }
}
