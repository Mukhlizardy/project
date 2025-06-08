import 'package:shared_preferences/shared_preferences.dart';

class LocalAuth {
  static const String _keyLoggedIn = 'logged_in';

  static Future<void> setLoggedIn(bool isLoggedIn) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyLoggedIn, isLoggedIn);
  }

  static Future<bool> isLoggedIn() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyLoggedIn) ?? false;
  }
}
