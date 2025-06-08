import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/cart.dart';
import '../models/product.dart';

class FakeStoreApi {
  // === PRODUCTS ===
  static Future<List<Product>> getProducts() async {
    final response =
        await http.get(Uri.parse('https://fakestoreapi.com/products'));
    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      return List<Product>.from(jsonData.map((data) => Product.fromJson(data)));
    } else {
      throw Exception('Failed to fetch products');
    }
  }

  static Future<Product> getProduct(int productId) async {
    final response = await http
        .get(Uri.parse('https://fakestoreapi.com/products/$productId'));
    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      return Product.fromJson(jsonData);
    } else {
      throw Exception('Failed to fetch product');
    }
  }

  static Future<Product> createProduct(Product product) async {
    final response = await http.post(
      Uri.parse('https://fakestoreapi.com/products'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(product.toJson()),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      return Product.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to create product');
    }
  }

  static Future<Product> updateProduct(int productId, Product product) async {
    final response = await http.put(
      Uri.parse('https://fakestoreapi.com/products/$productId'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(product.toJson()),
    );
    if (response.statusCode == 200) {
      return Product.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to update product');
    }
  }

  static Future<void> deleteProduct(int productId) async {
    final response = await http
        .delete(Uri.parse('https://fakestoreapi.com/products/$productId'));
    if (response.statusCode != 200) {
      throw Exception('Failed to delete product');
    }
  }

  // === CARTS ===
  static Future<List<Cart>> getCarts() async {
    final response =
        await http.get(Uri.parse('https://fakestoreapi.com/carts'));
    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      return List<Cart>.from(jsonData.map((data) => Cart.fromJson(data)));
    } else {
      throw Exception('Failed to fetch carts');
    }
  }

  static Future<Cart> getCart(int cartId) async {
    final response =
        await http.get(Uri.parse('https://fakestoreapi.com/carts/$cartId'));
    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      return Cart.fromJson(jsonData);
    } else {
      throw Exception('Failed to fetch cart');
    }
  }

  static Future<Cart> createCart(Cart cart) async {
    final response = await http.post(
      Uri.parse('https://fakestoreapi.com/carts'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(cart.toJson()),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      return Cart.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to create cart');
    }
  }

  static Future<Cart> updateCart(int cartId, Cart cart) async {
    final response = await http.put(
      Uri.parse('https://fakestoreapi.com/carts/$cartId'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(cart.toJson()),
    );
    if (response.statusCode == 200) {
      return Cart.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to update cart');
    }
  }

  static Future<void> deleteCart(int cartId) async {
    final response =
        await http.delete(Uri.parse('https://fakestoreapi.com/carts/$cartId'));
    if (response.statusCode != 200) {
      throw Exception('Failed to delete cart');
    }
  }
}
