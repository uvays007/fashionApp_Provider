import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CartProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  double total = 0;

  Future<void> addToCart(Map<String, dynamic> product) async {
    final cartRef = _firestore.collection('cart').doc(product['id']);

    final doc = await cartRef.get();

    if (doc.exists) {
      await cartRef.update({'quantity': FieldValue.increment(1)});
    } else {
      await cartRef.set({
        'productId': product['id'],
        'name': product['name'],
        'price': product['price'],
        'image': product['image'],
        'size': product['size'],
        'color': product['color'],
        'quantity': product['quantity'],
        'addedAt': Timestamp.now(),
      });
    }
  }

  Future<void> incrementQuantity(String cartItemId) async {
    final cartRef = _firestore.collection('cart').doc(cartItemId);
    final doc = await cartRef.get();
    if (!doc.exists) return;

    await cartRef.update({'quantity': FieldValue.increment(1)});
    calculateCartTotal();
  }

  Future<void> decreaseQuantity(String cartItemId) async {
    final cartRef = _firestore.collection('cart').doc(cartItemId);
    final doc = await cartRef.get();
    if (!doc.exists) return;

    final int qty = doc['quantity'] ?? 1;

    if (qty <= 1) {
      await cartRef.delete();
    } else {
      await cartRef.update({'quantity': FieldValue.increment(-1)});
    }
    calculateCartTotal();
  }

  Future<void> removeFromCart(String cartItemId) async {
    final cartRef = _firestore.collection('cart').doc(cartItemId);
    await cartRef.delete();
  }

  Stream<List<Map<String, dynamic>>> cartStream() {
    return _firestore
        .collection('cart')
        .orderBy('addedAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return {'id': doc.id, ...doc.data()};
          }).toList();
        });
  }

  Future<void> calculateCartTotal() async {
    double sum = 0;
    final snapshot = await FirebaseFirestore.instance.collection('cart').get();
    for (var doc in snapshot.docs) {
      final data = doc.data();
      final priceString = data['price'].toString().replaceAll(
        RegExp(r'[^0-9.]'),
        '',
      );
      final price = double.tryParse(priceString) ?? 0;
      final qty = data['quantity'] ?? 1;
      sum += price * qty;
    }
    total = sum;
    notifyListeners();
  }
}
