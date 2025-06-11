import 'package:shared_preferences/shared_preferences.dart';

class LocalDatabase {
  static const String _keyCartHistory = 'cart_history';

  static Future<void> addToCartHistory(int cartId) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      List<String>? cartHistory = prefs.getStringList(_keyCartHistory);
      if (cartHistory == null) {
        cartHistory = [cartId.toString()];
      } else {
        // Prevent duplicate entries
        if (!cartHistory.contains(cartId.toString())) {
          cartHistory.add(cartId.toString());
        }
      }
      await prefs.setStringList(_keyCartHistory, cartHistory);
    } catch (e) {
      print('Error adding to cart history: $e');
    }
  }

  static Future<List<int>> getCartHistory() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      List<String>? cartHistory = prefs.getStringList(_keyCartHistory);
      return cartHistory?.map((id) => int.parse(id)).toList() ?? [];
    } catch (e) {
      print('Error getting cart history: $e');
      return [];
    }
  }

  static Future<void> clearCartHistory() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.remove(_keyCartHistory);
    } catch (e) {
      print('Error clearing cart history: $e');
    }
  }

  static Future<void> removeFromCartHistory(int cartId) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      List<String>? cartHistory = prefs.getStringList(_keyCartHistory);
      if (cartHistory != null) {
        cartHistory.remove(cartId.toString());
        await prefs.setStringList(_keyCartHistory, cartHistory);
      }
    } catch (e) {
      print('Error removing from cart history: $e');
    }
  }
}
