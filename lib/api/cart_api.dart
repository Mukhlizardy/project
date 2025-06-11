import '../models/product.dart';
import '../models/cart_item.dart';

class CartApi {
  static List<CartItem> _cartItems = [];

  static List<CartItem> getCartItems() {
    return List.from(
        _cartItems); // Return a copy to prevent external modification
  }

  static Future<void> addToCart(Product product) async {
    // Simulate API delay
    await Future.delayed(Duration(milliseconds: 100));

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
  }

  static Future<void> updateCartItem(int productId, int newQuantity) async {
    // Simulate API delay
    await Future.delayed(Duration(milliseconds: 100));

    int index = _cartItems.indexWhere((item) => item.product.id == productId);
    if (index != -1) {
      if (newQuantity <= 0) {
        _cartItems.removeAt(index);
      } else {
        _cartItems[index].quantity = newQuantity;
      }
    }
  }

  static Future<void> removeFromCart(int productId) async {
    // Simulate API delay
    await Future.delayed(Duration(milliseconds: 100));

    _cartItems.removeWhere((item) => item.product.id == productId);
  }

  static Future<void> clearCart() async {
    // Simulate API delay
    await Future.delayed(Duration(milliseconds: 100));

    _cartItems.clear();
  }

  static double getTotalPrice() {
    return _cartItems.fold(
        0.0, (sum, item) => sum + (item.product.price * item.quantity));
  }

  static int getTotalItems() {
    return _cartItems.fold(0, (sum, item) => sum + item.quantity);
  }

  static bool isProductInCart(int productId) {
    return _cartItems.any((item) => item.product.id == productId);
  }

  static int getProductQuantity(int productId) {
    CartItem? item = _cartItems.firstWhere(
      (item) => item.product.id == productId,
      orElse: () => CartItem(
          product:
              Product(id: -1, title: '', description: '', price: 0, image: ''),
          quantity: 0),
    );
    return item.product.id == -1 ? 0 : item.quantity;
  }
}
