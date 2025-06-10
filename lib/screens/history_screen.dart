import 'package:flutter/material.dart';
import '../api/fakestore_api.dart';
import '../models/cart.dart';
import '../api/local_database.dart';

class HistoryScreen extends StatefulWidget {
  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<Cart> carts = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    fetchCarts();
  }

  Future<void> fetchCarts() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      List<int> cartIds = await LocalDatabase.getCartHistory();
      List<Cart> fetchedCarts = [];

      for (int cartId in cartIds) {
        try {
          Cart cart = await FakeStoreApi.getCart(cartId);
          fetchedCarts.add(cart);
        } catch (e) {
          print('Failed to fetch cart $cartId: $e');
          // Continue with other carts instead of failing completely
        }
      }

      setState(() {
        carts = fetchedCarts;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  Future<void> _clearHistory() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Clear History'),
          content: Text('Are you sure you want to clear all cart history?'),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text('Clear', style: TextStyle(color: Colors.red)),
              onPressed: () async {
                Navigator.of(context).pop();
                try {
                  await LocalDatabase.clearCartHistory();
                  setState(() {
                    carts.clear();
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('History cleared successfully!')),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to clear history: $e')),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildCartHistoryItem(Cart cart) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ExpansionTile(
        title: Text(
          'Cart #${cart.id}',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('User: ${cart.userId} | Date: ${cart.date}'),
            SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.shopping_cart, size: 16, color: Colors.grey[600]),
                SizedBox(width: 4),
                Text(
                  '${cart.totalQuantity} items',
                  style: TextStyle(color: Colors.grey[600]),
                ),
                SizedBox(width: 16),
                Icon(Icons.attach_money, size: 16, color: Colors.green[600]),
                Text(
                  '${cart.totalPrice.toStringAsFixed(2)}',
                  style: TextStyle(
                    color: Colors.green[700],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
        leading: CircleAvatar(
          backgroundColor: Colors.blue[100],
          child: Icon(
            Icons.history,
            color: Colors.blue[700],
          ),
        ),
        children: cart.products.map((product) {
          return Container(
            margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: ListTile(
              leading: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.grey[200],
                ),
                child: product.image != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          product.image!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(
                              Icons.image_not_supported,
                              color: Colors.grey[600],
                            );
                          },
                        ),
                      )
                    : Icon(
                        Icons.shopping_bag,
                        color: Colors.grey[600],
                      ),
              ),
              title: Text(
                product.title ?? 'Product #${product.productId}',
                style: TextStyle(fontSize: 14),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Text(
                'Qty: ${product.quantity} × \$${product.price.toStringAsFixed(2)}',
                style: TextStyle(fontSize: 12),
              ),
              trailing: Text(
                '\$${(product.price * product.quantity).toStringAsFixed(2)}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.green[700],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cart History'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: fetchCarts,
            tooltip: 'Refresh',
          ),
          if (carts.isNotEmpty)
            IconButton(
              icon: Icon(Icons.clear_all),
              onPressed: _clearHistory,
              tooltip: 'Clear History',
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: fetchCarts,
        child: _buildBody(),
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
            Text('Loading cart history...'),
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
              'Error loading history',
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
              onPressed: fetchCarts,
              child: Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (carts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.history,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'No cart history',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Your cart history will appear here',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.symmetric(vertical: 8),
      itemCount: carts.length,
      itemBuilder: (context, index) {
        return _buildCartHistoryItem(carts[index]);
      },
    );
  }
}
