import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/cart_item.dart';
import '../models/product.dart';

class LocalDatabase {
  static const String _keyCartItems = 'cart_items';
  static const String _keyOrderHistory = 'order_history';
  static const String _keyFavoriteProducts = 'favorite_products';
  static const String _keyUserProfile = 'user_profile';

  // === CART OPERATIONS ===
  static Future<void> saveCartItems(List<CartItem> cartItems) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> cartItemsJson =
        cartItems.map((item) => json.encode(item.toJson())).toList();
    await prefs.setStringList(_keyCartItems, cartItemsJson);
  }

  static Future<List<CartItem>> getCartItems() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? cartItemsJson = prefs.getStringList(_keyCartItems);
    if (cartItemsJson == null) return [];

    return cartItemsJson.map((jsonString) {
      Map<String, dynamic> jsonMap = json.decode(jsonString);
      return CartItem(
        product: Product.fromJson(jsonMap['product']),
        quantity: jsonMap['quantity'],
      );
    }).toList();
  }

  static Future<void> clearCart() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyCartItems);
  }

  // === ORDER HISTORY OPERATIONS ===
  static Future<void> addOrderToHistory(List<CartItem> cartItems) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? historyJson = prefs.getStringList(_keyOrderHistory);

    Map<String, dynamic> order = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'date': DateTime.now().toIso8601String(),
      'items': cartItems.map((item) => item.toJson()).toList(),
      'total': cartItems.fold(0.0, (total, item) {}),
    };

    if (historyJson == null) {
      historyJson = [json.encode(order)];
    } else {
      historyJson.add(json.encode(order));
    }

    await prefs.setStringList(_keyOrderHistory, historyJson);
  }

  static Future<List<Map<String, dynamic>>> getOrderHistory() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? historyJson = prefs.getStringList(_keyOrderHistory);
    if (historyJson == null) return [];

    return historyJson.map((jsonString) {
      return json.decode(jsonString) as Map<String, dynamic>;
    }).toList();
  }

  static Future<void> deleteOrderFromHistory(String orderId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? historyJson = prefs.getStringList(_keyOrderHistory);
    if (historyJson == null) return;

    historyJson.removeWhere((jsonString) {
      Map<String, dynamic> order = json.decode(jsonString);
      return order['id'] == orderId;
    });

    await prefs.setStringList(_keyOrderHistory, historyJson);
  }

  static Future<void> clearOrderHistory() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyOrderHistory);
  }

  // === FAVORITE PRODUCTS OPERATIONS ===
  static Future<void> addToFavorites(Product product) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? favoritesJson = prefs.getStringList(_keyFavoriteProducts);

    if (favoritesJson == null) {
      favoritesJson = [json.encode(product.toJson())];
    } else {
      // Check if product already exists
      bool exists = favoritesJson.any((jsonString) {
        Map<String, dynamic> favoriteProduct = json.decode(jsonString);
        return favoriteProduct['id'] == product.id;
      });

      if (!exists) {
        favoritesJson.add(json.encode(product.toJson()));
      }
    }

    await prefs.setStringList(_keyFavoriteProducts, favoritesJson);
  }

  static Future<void> removeFromFavorites(int productId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? favoritesJson = prefs.getStringList(_keyFavoriteProducts);
    if (favoritesJson == null) return;

    favoritesJson.removeWhere((jsonString) {
      Map<String, dynamic> favoriteProduct = json.decode(jsonString);
      return favoriteProduct['id'] == productId;
    });

    await prefs.setStringList(_keyFavoriteProducts, favoritesJson);
  }

  static Future<List<Product>> getFavoriteProducts() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? favoritesJson = prefs.getStringList(_keyFavoriteProducts);
    if (favoritesJson == null) return [];

    return favoritesJson.map((jsonString) {
      Map<String, dynamic> productJson = json.decode(jsonString);
      return Product.fromJson(productJson);
    }).toList();
  }

  static Future<bool> isProductFavorite(int productId) async {
    List<Product> favorites = await getFavoriteProducts();
    return favorites.any((product) => product.id == productId);
  }

  // === USER PROFILE OPERATIONS ===
  static Future<void> saveUserProfile(Map<String, dynamic> profile) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUserProfile, json.encode(profile));
  }

  static Future<Map<String, dynamic>?> getUserProfile() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? profileJson = prefs.getString(_keyUserProfile);
    if (profileJson == null) return null;

    return json.decode(profileJson) as Map<String, dynamic>;
  }

  static Future<void> clearUserProfile() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyUserProfile);
  }

  // === UTILITY METHODS ===
  static Future<void> clearAllData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  static Future<Map<String, dynamic>> getStorageInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Set<String> keys = prefs.getKeys();

    Map<String, dynamic> info = {};
    for (String key in keys) {
      info[key] = prefs.get(key);
    }

    return info;
  }
}
