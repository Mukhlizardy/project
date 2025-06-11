import 'package:flutter/material.dart';
import '../api/cart_api.dart';
import '../models/cart_item.dart';
import '../api/local_database.dart';
import '../api/fakestore_api.dart';
import '../models/cart.dart';

class CartScreen extends StatefulWidget {
  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  List<CartItem> cartItems = [];

  @override
  void initState() {
    super.initState();
    fetchCartItems();
  }

  Future<void> fetchCartItems() async {
    // Ambil cart items dari CartApi (local cart)
    List<CartItem> localCartItems = CartApi.getCartItems();
    setState(() {
      cartItems = localCartItems;
    });
  }

  Future<void> _removeFromCart(int productId) async {
    await CartApi.removeFromCart(productId);
    fetchCartItems();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Product removed from cart!')),
    );
  }

  Future<void> _updateQuantity(int productId, int newQuantity) async {
    if (newQuantity <= 0) {
      await _removeFromCart(productId);
    } else {
      await CartApi.updateQuantity(productId, newQuantity);
      fetchCartItems();
    }
  }

  Future<void> _checkout() async {
    if (cartItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Cart is empty!')),
      );
      return;
    }

    // Simulasi checkout - simpan ke history dan clear cart
    try {
      // Untuk setiap item di cart, buat cart entry di FakeStore API
      for (CartItem item in cartItems) {
        Cart newCart = Cart(
          id: 0,
          productId: item.product.id,
          productName: item.product.title,
          price: item.product.price,
          quantity: item.quantity,
        );

        Cart createdCart = await FakeStoreApi.createCart(newCart);
        // Simpan cart ID ke history
        await LocalDatabase.addToCartHistory(createdCart.id);
      }

      // Clear cart setelah checkout
      await CartApi.clearCart();
      fetchCartItems();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Checkout successful!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Checkout failed: $e')),
      );
    }
  }

  double _calculateTotal() {
    return cartItems.fold(
        0.0, (total, item) => total + (item.product.price * item.quantity));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cart'),
        backgroundColor: Colors.green,
      ),
      body: cartItems.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_cart_outlined,
                      size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'Your cart is empty',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: cartItems.length,
                    itemBuilder: (context, index) {
                      final cartItem = cartItems[index];
                      return Card(
                        margin: EdgeInsets.all(8.0),
                        child: ListTile(
                          leading: Container(
                            width: 60,
                            height: 60,
                            child: Image.network(
                              cartItem.product.image,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  Icon(Icons.image_not_supported),
                            ),
                          ),
                          title: Text(
                            cartItem.product.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Text(
                            '\$${cartItem.product.price.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(Icons.remove),
                                onPressed: () {
                                  _updateQuantity(cartItem.product.id,
                                      cartItem.quantity - 1);
                                },
                              ),
                              Text(
                                '${cartItem.quantity}',
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              IconButton(
                                icon: Icon(Icons.add),
                                onPressed: () {
                                  _updateQuantity(cartItem.product.id,
                                      cartItem.quantity + 1);
                                },
                              ),
                              IconButton(
                                icon: Icon(Icons.delete, color: Colors.red),
                                onPressed: () {
                                  _removeFromCart(cartItem.product.id);
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    border:
                        Border(top: BorderSide(color: Colors.grey.shade300)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total: \$${_calculateTotal().toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      ElevatedButton(
                        onPressed: _checkout,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: EdgeInsets.symmetric(
                              horizontal: 32, vertical: 12),
                        ),
                        child: Text(
                          'Checkout',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
