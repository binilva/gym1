import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'cart_provider.dart';

class CartPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var cart = Provider.of<CartProvider>(context);

    return Scaffold(
      appBar: AppBar(title: Text("Shopping Cart")),
      body: cart.cartItems.isEmpty
          ? Center(child: Text("Your cart is empty"))
          : Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: cart.cartItems.length,
              itemBuilder: (context, index) {
                var product = cart.cartItems[index];
                return Card(
                  margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: ListTile(
                    leading: Image.network(product['image'], width: 50),
                    title: Text(product['title']),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("\$${product['price']} x ${product['quantity']}"),
                        SizedBox(height: 5),
                        Row(
                          children: [
                            IconButton(
                              icon: Icon(Icons.remove_circle_outline),
                              onPressed: () {
                                cart.updateQuantity(product, product['quantity'] - 1);
                              },
                            ),
                            Text(product['quantity'].toString(),
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            IconButton(
                              icon: Icon(Icons.add_circle_outline),
                              onPressed: () {
                                cart.updateQuantity(product, product['quantity'] + 1);
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        cart.removeFromCart(product);
                      },
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text(
                  "Total: \$${cart.totalPrice.toStringAsFixed(2)}",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: cart.cartItems.isNotEmpty
                      ? () {
                    cart.clearCart();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Purchase Successful!")),
                    );
                  }
                      : null,
                  child: Text("Checkout"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
