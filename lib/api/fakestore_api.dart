import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/cart.dart';
import '../models/product.dart';

class FakeStoreApi {
  static const String baseUrl = 'https://fakestoreapi.com';

  // === PRODUCTS ===
  static Future<List<Product>> getProducts() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/products'));
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return List<Product>.from(
            jsonData.map((data) => Product.fromJson(data)));
      } else {
        throw Exception('Failed to fetch products: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  static Future<Product> getProduct(int productId) async {
    try {
      final response =
          await http.get(Uri.parse('$baseUrl/products/$productId'));
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return Product.fromJson(jsonData);
      } else {
        throw Exception('Failed to fetch product: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  static Future<Product> createProduct(Product product) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/products'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(product.toJson()),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return Product.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to create product: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  static Future<Product> updateProduct(int productId, Product product) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/products/$productId'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(product.toJson()),
      );
      if (response.statusCode == 200) {
        return Product.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to update product: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  static Future<void> deleteProduct(int productId) async {
    try {
      final response =
          await http.delete(Uri.parse('$baseUrl/products/$productId'));
      if (response.statusCode != 200) {
        throw Exception('Failed to delete product: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // === CARTS ===
  static Future<List<Cart>> getCarts() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/carts'));
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        List<Cart> carts =
            List<Cart>.from(jsonData.map((data) => Cart.fromJson(data)));

        // Enrich cart products with product details
        for (Cart cart in carts) {
          for (CartProduct cartProduct in cart.products) {
            try {
              Product product = await getProduct(cartProduct.productId);
              // Update CartProduct with product details
              cartProduct = CartProduct(
                productId: cartProduct.productId,
                quantity: cartProduct.quantity,
                title: product.title,
                price: product.price,
                image: product.image,
              );
            } catch (e) {
              print(
                  'Failed to fetch product details for ID: ${cartProduct.productId}');
            }
          }
        }

        return carts;
      } else {
        throw Exception('Failed to fetch carts: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  static Future<Cart> getCart(int cartId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/carts/$cartId'));
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        Cart cart = Cart.fromJson(jsonData);

        // Enrich cart products with product details
        List<CartProduct> enrichedProducts = [];
        for (CartProduct cartProduct in cart.products) {
          try {
            Product product = await getProduct(cartProduct.productId);
            enrichedProducts.add(CartProduct(
              productId: cartProduct.productId,
              quantity: cartProduct.quantity,
              title: product.title,
              price: product.price,
              image: product.image,
            ));
          } catch (e) {
            enrichedProducts.add(cartProduct);
          }
        }

        return Cart(
          id: cart.id,
          userId: cart.userId,
          date: cart.date,
          products: enrichedProducts,
        );
      } else {
        throw Exception('Failed to fetch cart: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  static Future<Cart> createCart(Cart cart) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/carts'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(cart.toJson()),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return Cart.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to create cart: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  static Future<Cart> updateCart(int cartId, Cart cart) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/carts/$cartId'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(cart.toJson()),
      );
      if (response.statusCode == 200) {
        return Cart.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to update cart: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  static Future<void> deleteCart(int cartId) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl/carts/$cartId'));
      if (response.statusCode != 200) {
        throw Exception('Failed to delete cart: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
}
