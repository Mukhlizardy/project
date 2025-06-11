import '../models/product.dart';
import '../models/cart_item.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class CartApi {
  static List<CartItem> _cartItems = [];
  static const String _keyCartItems = 'cart_items';

  static List<CartItem> getCartItems() {
    return _cartItems;
  }

  // Initialize cart from shared preferences
  static Future<void> initializeCart() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? cartData = prefs.getString(_keyCartItems);

      if (cartData != null) {
        List<dynamic> jsonList = json.decode(cartData);
        _cartItems = jsonList.map((json) => CartItem.fromJson(json)).toList();
      }
    } catch (e) {
      print('Error loading cart from storage: $e');
      _cartItems = [];
    }
  }

  // Save cart to shared preferences
  static Future<void> _saveCartToStorage() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String cartData =
          json.encode(_cartItems.map((item) => item.toJson()).toList());
      await prefs.setString(_keyCartItems, cartData);
    } catch (e) {
      print('Error saving cart to storage: $e');
    }
  }

  static Future<void> addToCart(Product product) async {
    // Check if the product is already in the cart
    bool productExists =
        _cartItems.any((item) => item.product.id == product.id);

    if (productExists) {
      // If the product exists, update its quantity
      _cartItems.forEach((item) {
        if (item.product.id == product.id) {
          item.quantity++;
        }
      });
    } else {
      // If the product doesn't exist, add it to the cart
      _cartItems.add(CartItem(product: product, quantity: 1));
    }

    await _saveCartToStorage();
  }

  static Future<void> removeFromCart(int productId) async {
    _cartItems.removeWhere((item) => item.product.id == productId);
    await _saveCartToStorage();
  }

  static Future<void> updateQuantity(int productId, int newQuantity) async {
    if (newQuantity <= 0) {
      await removeFromCart(productId);
      return;
    }

    for (CartItem item in _cartItems) {
      if (item.product.id == productId) {
        item.quantity = newQuantity;
        break;
      }
    }

    await _saveCartToStorage();
  }

  static Future<void> clearCart() async {
    _cartItems.clear();
    await _saveCartToStorage();
  }

  static int getCartItemCount() {
    return _cartItems.fold(0, (total, item) => total + item.quantity);
  }

  static double getCartTotal() {
    return _cartItems.fold(
        0.0, (total, item) => total + (item.product.price * item.quantity));
  }
}
