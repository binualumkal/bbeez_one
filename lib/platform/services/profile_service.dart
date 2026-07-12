import 'package:shared_preferences/shared_preferences.dart';

class ProfileService {
  static const _keyName = 'profile_name';
  static const _keyEmail = 'profile_email';
  static const _keyPhone = 'profile_phone';
  static const _keyImage = 'profile_image';

  static Future<void> saveProfile({
    required String name,
    required String email,
    required String phone,
    required String image,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(
      _keyName,
      name,
    );

    await prefs.setString(
      _keyEmail,
      email,
    );

    await prefs.setString(
      _keyPhone,
      phone,
    );

    await prefs.setString(
      _keyImage,
      image,
    );
  }

  static Future<Map<String, String>> getProfile() async {
    final prefs = await SharedPreferences.getInstance();

    return {
      'name': prefs.getString(_keyName) ?? 'Your Name',
      'email': prefs.getString(_keyEmail) ?? '',
      'phone': prefs.getString(_keyPhone) ?? '',
      'image': prefs.getString(_keyImage) ?? '',
    };
  }
}
