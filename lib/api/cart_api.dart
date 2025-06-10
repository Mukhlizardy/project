import '../models/product.dart';
import '../models/cart_item.dart';
import 'local_database.dart';
import 'dart:convert';

class CartApi {
  static List<CartItem> _cartItems = [];

  // Initialize cart from local storage
  static Future<void> initializeCart() async {
    _cartItems = await LocalDatabase.getCartItems();
  }

  static List<CartItem> getCartItems() {
    return _cartItems;
  }

  static Future<void> addToCart(Product product) async {
    // Check if the product is already in the cart
    int existingIndex =
        _cartItems.indexWhere((item) => item.product.id == product.id);

    if (existingIndex != -1) {
      // If the product exists, update its quantity
      _cartItems[existingIndex].quantity++;
    } else {
      // If the product doesn't exist, add it to the cart
      _cartItems.add(CartItem(product: product, quantity: 1));
    }

    // Save to local storage
    await LocalDatabase.saveCartItems(_cartItems);
  }

  static Future<void> removeFromCart(int productId) async {
    _cartItems.removeWhere((item) => item.product.id == productId);
    await LocalDatabase.saveCartItems(_cartItems);
  }

  static Future<void> updateQuantity(int productId, int quantity) async {
    int index = _cartItems.indexWhere((item) => item.product.id == productId);
    if (index != -1) {
      if (quantity <= 0) {
        _cartItems.removeAt(index);
      } else {
        _cartItems[index].quantity = quantity;
      }
      await LocalDatabase.saveCartItems(_cartItems);
    }
  }

  static Future<void> clearCart() async {
    _cartItems.clear();
    await LocalDatabase.clearCart();
  }

  static double getTotalPrice() {
    return _cartItems.fold(
        0.0, (total, item) => total + (item.product.price * item.quantity));
  }

  static int getTotalItems() {
    return _cartItems.fold(0, (total, item) => total + item.quantity);
  }

  // Save current cart as order to history
  static Future<void> saveCartAsOrder() async {
    if (_cartItems.isNotEmpty) {
      await LocalDatabase.addOrderToHistory(_cartItems);
      await clearCart();
    }
  }
}
