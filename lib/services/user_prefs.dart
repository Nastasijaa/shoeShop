import 'package:shared_preferences/shared_preferences.dart';

class UserPrefs {
  static const _nameKey = 'user_name';
  static const _emailKey = 'user_email';
  static const _imagePathKey = 'user_image_path';
  static const _isGuestKey = 'user_is_guest';

  static Future<void> saveUser({
    required String name,
    required String email,
    String? imagePath,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_nameKey, name);
    await prefs.setString(_emailKey, email);
    await prefs.setBool(_isGuestKey, false);
    if (imagePath != null) {
      await prefs.setString(_imagePathKey, imagePath);
    }
  }

  static Future<Map<String, String>> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'name': prefs.getString(_nameKey) ?? '',
      'email': prefs.getString(_emailKey) ?? '',
      'imagePath': prefs.getString(_imagePathKey) ?? '',
    };
  }

  static Future<void> clearUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_nameKey);
    await prefs.remove(_emailKey);
    await prefs.remove(_imagePathKey);
    await prefs.remove(_isGuestKey);
  }

  static Future<void> setGuest() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isGuestKey, true);
    await prefs.remove(_nameKey);
    await prefs.remove(_emailKey);
    await prefs.remove(_imagePathKey);
  }

  static Future<bool> isGuest() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isGuestKey) ?? false;
  }
}
