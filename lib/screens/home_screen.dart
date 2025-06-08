import 'package:flutter/material.dart';
import '../api/local_auth.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: Text('Grocery App', style: TextStyle(color: Colors.white)),
        elevation: 2,
      ),
      body: Container(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Welcome card
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.shopping_basket, color: Colors.green, size: 32),
                  SizedBox(width: 16),
                  Text(
                    'Welcome to your grocery app!',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 30),

            // Menu options
            _buildMenuItem(
              context,
              'Browse Products',
              Icons.store,
              Colors.blue.shade700,
              () => Navigator.pushNamed(context, '/products'),
            ),

            SizedBox(height: 15),

            _buildMenuItem(
              context,
              'View Cart',
              Icons.shopping_cart,
              Colors.orange.shade700,
              () => Navigator.pushNamed(context, '/cart'),
            ),

            SizedBox(height: 15),

            _buildMenuItem(
              context,
              'View History',
              Icons.history,
              Colors.purple.shade700,
              () => Navigator.pushNamed(context, '/history'),
            ),

            SizedBox(height: 15),

            _buildMenuItem(
              context,
              'Logout',
              Icons.exit_to_app,
              Colors.red.shade700,
              () {
                LocalAuth.setLoggedIn(false);
                Navigator.pushNamedAndRemoveUntil(
                    context, '/login', (route) => false);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(BuildContext context, String title, IconData icon,
      Color color, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: color,
        padding: EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(color: color.withOpacity(0.3)),
        ),
        elevation: 1,
      ),
      child: Row(
        children: [
          SizedBox(width: 15),
          Icon(icon, size: 24),
          SizedBox(width: 15),
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
