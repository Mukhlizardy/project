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

  @override
  void initState() {
    super.initState();
    fetchCarts();
  }

  Future<void> fetchCarts() async {
    List<int> cartIds = await LocalDatabase.getCartHistory();
    List<Cart> fetchedCarts = [];
    for (int cartId in cartIds) {
      Cart cart = await FakeStoreApi.getCart(cartId);
      fetchedCarts.add(cart);
    }
    setState(() {
      carts = fetchedCarts;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('History'),
      ),
      body: ListView.builder(
        itemCount: carts.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(carts[index].productName),
            subtitle: Text('\$${carts[index].price.toStringAsFixed(2)}'),
          );
        },
      ),
    );
  }
}
