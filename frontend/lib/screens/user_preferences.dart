import 'package:shared_preferences/shared_preferences.dart';

class UserPreferences {
  static const _currencyKey = 'currency';
  static const _notificationsKey = 'notifications_enabled';
  static const _rememberMeKey = 'remember_me';

  // Set currency
  static Future<void> setCurrency(String currency) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_currencyKey, currency);
  }

  // Get currency
  static Future<String> getCurrency() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_currencyKey) ?? 'USD';
  }

  // Set notification preference
  static Future<void> setNotificationsEnabled(bool isEnabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_notificationsKey, isEnabled);
  }

  // Get notification preference
  static Future<bool> getNotificationsEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_notificationsKey) ?? true;
  }

  // Set remember me preference
  static Future<void> setRememberMe(bool remember) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_rememberMeKey, remember);
  }

  // Get remember me preference
  static Future<bool> getRememberMe() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_rememberMeKey) ?? false;
  }
}
