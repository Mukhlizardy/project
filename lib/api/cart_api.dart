import '../models/product.dart';
import '../models/cart_item.dart';

class CartApi {
  static List<CartItem> _cartItems = [];

  static List<CartItem> getCartItems() {
    return _cartItems;
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
  }

  // Add other methods for updating and deleting items from the cart
}
