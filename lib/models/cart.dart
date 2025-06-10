class Cart {
  final int id;
  final int userId;
  final String date;
  final List<CartProduct> products;

  Cart({
    required this.id,
    required this.userId,
    required this.date,
    required this.products,
  });

  factory Cart.fromJson(Map<String, dynamic> json) {
    return Cart(
      id: json['id'] ?? 0,
      userId: json['userId'] ?? 0,
      date: json['date'] ?? '',
      products: json['products'] != null
          ? List<CartProduct>.from(
              json['products'].map((x) => CartProduct.fromJson(x)))
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'date': date,
      'products': products.map((x) => x.toJson()).toList(),
    };
  }

  // Helper methods untuk mendapatkan total harga dan quantity
  double get totalPrice {
    return products.fold(
        0.0, (sum, product) => sum + (product.price * product.quantity));
  }

  int get totalQuantity {
    return products.fold(0, (sum, product) => sum + product.quantity);
  }
}

class CartProduct {
  final int productId;
  final int quantity;
  final String? title;
  final double price;
  final String? image;

  CartProduct({
    required this.productId,
    required this.quantity,
    this.title,
    this.price = 0.0,
    this.image,
  });

  factory CartProduct.fromJson(Map<String, dynamic> json) {
    return CartProduct(
      productId: json['productId'] ?? 0,
      quantity: json['quantity'] ?? 0,
      title: json['title'],
      price: (json['price'] ?? 0).toDouble(),
      image: json['image'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'quantity': quantity,
    };
  }
}
