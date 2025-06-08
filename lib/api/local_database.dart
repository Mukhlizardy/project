import 'package:shared_preferences/shared_preferences.dart';

class LocalDatabase {
  static const String _keyCartHistory = 'cart_history';

  static Future<void> addToCartHistory(int cartId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? cartHistory = prefs.getStringList(_keyCartHistory);
    if (cartHistory == null) {
      cartHistory = [cartId.toString()];
    } else {
      cartHistory.add(cartId.toString());
    }
    await prefs.setStringList(_keyCartHistory, cartHistory);
  }

  static Future<List<int>> getCartHistory() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? cartHistory = prefs.getStringList(_keyCartHistory);
    return cartHistory?.map((id) => int.parse(id)).toList() ?? [];
  }
}
