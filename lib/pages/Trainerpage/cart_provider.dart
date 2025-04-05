import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class CartProvider with ChangeNotifier {
  List<Map<String, dynamic>> _cartItems = [];

  List<Map<String, dynamic>> get cartItems => _cartItems;

  double get totalPrice {
    return _cartItems.fold(0, (sum, item) => sum + (item['price'] * item['quantity']));
  }

  CartProvider() {
    loadCart();
  }

  Future<void> saveCart() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('cart', json.encode(_cartItems));
  }

  Future<void> loadCart() async {
    final prefs = await SharedPreferences.getInstance();
    String? cartData = prefs.getString('cart');
    if (cartData != null) {
      _cartItems = List<Map<String, dynamic>>.from(json.decode(cartData));
      notifyListeners();
    }
  }

  void addToCart(Map<String, dynamic> product) {
    int index = _cartItems.indexWhere((item) => item['id'] == product['id']);
    if (index != -1) {
      _cartItems[index]['quantity'] += product['quantity'];
    } else {
      product['quantity'] = product['quantity'] ?? 1;
      _cartItems.add(product);
    }
    saveCart();
    notifyListeners();
  }

  void removeFromCart(Map<String, dynamic> product) {
    _cartItems.removeWhere((item) => item['id'] == product['id']);
    saveCart();
    notifyListeners();
  }

  void updateQuantity(Map<String, dynamic> product, int quantity) {
    int index = _cartItems.indexWhere((item) => item['id'] == product['id']);
    if (index != -1) {
      _cartItems[index]['quantity'] = quantity;
      if (_cartItems[index]['quantity'] <= 0) {
        _cartItems.removeAt(index);
      }
    }
    saveCart();
    notifyListeners();
  }

  void clearCart() {
    _cartItems.clear();
    saveCart();
    notifyListeners();
  }
}
