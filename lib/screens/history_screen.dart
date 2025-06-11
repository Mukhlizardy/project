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

  @override
  void initState() {
    super.initState();
    fetchCarts();
  }

  Future<void> fetchCarts() async {
    setState(() {
      isLoading = true;
    });

    try {
      List<int> cartIds = await LocalDatabase.getCartHistory();
      List<Cart> fetchedCarts = [];

      for (int cartId in cartIds) {
        try {
          Cart cart = await FakeStoreApi.getCart(cartId);
          fetchedCarts.add(cart);
        } catch (e) {
          print('Error fetching cart $cartId: $e');
          // Skip this cart if it can't be fetched
        }
      }

      setState(() {
        carts = fetchedCarts;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading history: $e')),
      );
    }
  }

  Future<void> _clearHistory() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Clear History'),
          content: Text('Are you sure you want to clear all purchase history?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                await LocalDatabase.clearCartHistory();
                Navigator.of(context).pop();
                setState(() {
                  carts.clear();
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('History cleared!')),
                );
              },
              child: Text('Clear', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  double _calculateTotal() {
    return carts.fold(
        0.0, (total, cart) => total + (cart.price * cart.quantity));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Purchase History'),
        backgroundColor: Colors.purple,
        actions: [
          if (carts.isNotEmpty)
            IconButton(
              icon: Icon(Icons.clear_all),
              onPressed: _clearHistory,
              tooltip: 'Clear History',
            ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : carts.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.history, size: 80, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'No purchase history',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Your purchase history will appear here',
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    Container(
                      padding: EdgeInsets.all(16.0),
                      color: Colors.purple.shade50,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total Purchases: ${carts.length}',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Total Spent: \$${_calculateTotal().toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.purple,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: carts.length,
                        itemBuilder: (context, index) {
                          final cart = carts[index];
                          return Card(
                            margin: EdgeInsets.all(8.0),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Colors.purple.shade100,
                                child: Text(
                                  '${cart.quantity}',
                                  style: TextStyle(
                                    color: Colors.purple,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              title: Text(
                                cart.productName,
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Product ID: ${cart.productId}'),
                                  Text(
                                      'Unit Price: \$${cart.price.toStringAsFixed(2)}'),
                                ],
                              ),
                              trailing: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    'Total',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  Text(
                                    '\$${(cart.price * cart.quantity).toStringAsFixed(2)}',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.purple,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
    );
  }
}
