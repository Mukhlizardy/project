import 'package:flutter/material.dart';
import '../api/fakestore_api.dart';
import '../models/cart.dart';

class CartScreen extends StatefulWidget {
  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  List<Cart> cartItems = [];

  @override
  void initState() {
    super.initState();
    fetchCartItems();
  }

  Future<void> fetchCartItems() async {
    List<Cart> fetchedCartItems = await FakeStoreApi.getCarts();
    setState(() {
      cartItems = fetchedCartItems;
    });
  }

  Future<void> _addCartItem() async {
    final newCart = Cart(
      id: 0, // ID biasanya diatur oleh backend
      productId: 999,
      productName: 'New Product',
      price: 99.99,
      quantity: 1,
    );

    await FakeStoreApi.createCart(newCart);
    fetchCartItems();
  }

  Future<void> _deleteCartItem(int id) async {
    await FakeStoreApi.deleteCart(id);
    fetchCartItems();
  }

  Future<void> _editCartItem(Cart cart) async {
    final updatedCart = Cart(
      id: cart.id,
      productId: cart.productId,
      productName: cart.productName + ' (Updated)',
      price: cart.price + 10,
      quantity: cart.quantity + 1,
    );

    await FakeStoreApi.updateCart(updatedCart.id, updatedCart);
    fetchCartItems();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cart'),
      ),
      body: ListView.builder(
        itemCount: cartItems.length,
        itemBuilder: (context, index) {
          final cart = cartItems[index];
          return ListTile(
            title: Text(cart.productName),
            subtitle: Text(
                'Qty: ${cart.quantity} | \$${cart.price.toStringAsFixed(2)}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: () {
                    _editCartItem(cart);
                  },
                ),
                IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () {
                    _deleteCartItem(cart.id);
                  },
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addCartItem,
        child: Icon(Icons.add),
      ),
    );
  }
}
