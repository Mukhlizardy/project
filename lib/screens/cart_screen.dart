import 'package:flutter/material.dart';
import '../api/fakestore_api.dart';
import '../models/cart.dart';

class CartScreen extends StatefulWidget {
  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  List<Cart> cartItems = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    fetchCartItems();
  }

  Future<void> fetchCartItems() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      List<Cart> fetchedCartItems = await FakeStoreApi.getCarts();
      setState(() {
        cartItems = fetchedCartItems;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  Future<void> _addCartItem() async {
    try {
      // Create a new cart with sample data
      final newCart = Cart(
        id: 0, // ID akan diatur oleh backend
        userId: 1,
        date: DateTime.now().toIso8601String().split('T')[0],
        products: [
          CartProduct(
            productId: 1, // Sample product ID
            quantity: 1,
            title: 'Sample Product',
            price: 109.95,
          ),
        ],
      );

      await FakeStoreApi.createCart(newCart);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Cart item added successfully!')),
      );

      fetchCartItems();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add cart item: $e')),
      );
    }
  }

  Future<void> _deleteCartItem(int id) async {
    try {
      await FakeStoreApi.deleteCart(id);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Cart deleted successfully!')),
      );

      fetchCartItems();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete cart: $e')),
      );
    }
  }

  Future<void> _editCartItem(Cart cart) async {
    try {
      // Update cart dengan menambah quantity pada produk pertama
      List<CartProduct> updatedProducts = cart.products.map((product) {
        return CartProduct(
          productId: product.productId,
          quantity: product.quantity + 1,
          title: product.title,
          price: product.price,
          image: product.image,
        );
      }).toList();

      final updatedCart = Cart(
        id: cart.id,
        userId: cart.userId,
        date: cart.date,
        products: updatedProducts,
      );

      await FakeStoreApi.updateCart(cart.id, updatedCart);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Cart updated successfully!')),
      );

      fetchCartItems();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update cart: $e')),
      );
    }
  }

  Widget _buildCartItem(Cart cart) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ExpansionTile(
        title: Text(
          'Cart #${cart.id}',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          'User: ${cart.userId} | Date: ${cart.date}\nTotal: \$${cart.totalPrice.toStringAsFixed(2)} (${cart.totalQuantity} items)',
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.edit, color: Colors.blue),
              onPressed: () => _editCartItem(cart),
              tooltip: 'Edit Cart',
            ),
            IconButton(
              icon: Icon(Icons.delete, color: Colors.red),
              onPressed: () => _showDeleteConfirmation(cart),
              tooltip: 'Delete Cart',
            ),
          ],
        ),
        children: cart.products.map((product) {
          return ListTile(
            leading: product.image != null
                ? Image.network(
                    product.image!,
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 50,
                        height: 50,
                        color: Colors.grey[300],
                        child: Icon(Icons.image_not_supported),
                      );
                    },
                  )
                : Container(
                    width: 50,
                    height: 50,
                    color: Colors.grey[300],
                    child: Icon(Icons.shopping_bag),
                  ),
            title: Text(product.title ?? 'Product #${product.productId}'),
            subtitle: Text(
              'Quantity: ${product.quantity} | Price: \$${product.price.toStringAsFixed(2)}',
            ),
            trailing: Text(
              '\$${(product.price * product.quantity).toStringAsFixed(2)}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.green[700],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  void _showDeleteConfirmation(Cart cart) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Cart'),
          content: Text('Are you sure you want to delete Cart #${cart.id}?'),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text('Delete', style: TextStyle(color: Colors.red)),
              onPressed: () {
                Navigator.of(context).pop();
                _deleteCartItem(cart.id);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Shopping Carts'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: fetchCartItems,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: fetchCartItems,
        child: _buildBody(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addCartItem,
        child: Icon(Icons.add_shopping_cart),
        backgroundColor: Colors.blue,
        tooltip: 'Add New Cart',
      ),
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading carts...'),
          ],
        ),
      );
    }

    if (errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            SizedBox(height: 16),
            Text(
              'Error loading carts',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              errorMessage!,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: fetchCartItems,
              child: Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (cartItems.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.shopping_cart_outlined,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'No carts found',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Add a new cart to get started',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: cartItems.length,
      itemBuilder: (context, index) {
        return _buildCartItem(cartItems[index]);
      },
    );
  }
}
