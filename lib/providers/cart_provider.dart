import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CartProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  double total = 0;

  /// 🔑 Create unique cart item ID
  String _cartItemId({
    required String productId,
    required String size,
    required int color,
  }) {
    return '${productId}_${size}_$color';
  }

  /// ➕ Add a product to cart
  Future<void> addToCart(Map<String, dynamic> product) async {
    final cartItemId = _cartItemId(
      productId: product['id'],
      size: product['size'],
      color: product['color'],
    );

    final cartRef = _firestore.collection('cart').doc(cartItemId);

    final doc = await cartRef.get();

    if (doc.exists) {
      // Increase quantity if item exists
      await cartRef.update({'quantity': FieldValue.increment(1)});
    } else {
      // Add new item
      await cartRef.set({
        'productId': product['id'],
        'name': product['name'],
        'price': product['price'],
        'image': product['image'],
        'size': product['size'],
        'color': product['color'],
        'quantity': 1,
        'addedAt': Timestamp.now(),
      });
    }
  }

  /// ➕ Increment quantity
  Future<void> incrementQuantity(String cartItemId) async {
    final cartRef = _firestore.collection('cart').doc(cartItemId);
    final doc = await cartRef.get();
    if (!doc.exists) return;

    await cartRef.update({'quantity': FieldValue.increment(1)});
    calculateCartTotal();
  }

  /// ➖ Decrement quantity
  Future<void> decreaseQuantity(String cartItemId) async {
    final cartRef = _firestore.collection('cart').doc(cartItemId);
    final doc = await cartRef.get();
    if (!doc.exists) return;

    final int qty = doc['quantity'] ?? 1;

    if (qty <= 1) {
      // Remove item if quantity is 1
      await cartRef.delete();
    } else {
      await cartRef.update({'quantity': FieldValue.increment(-1)});
    }
    calculateCartTotal();
  }

  /// ❌ Remove item completely
  Future<void> removeFromCart(String cartItemId) async {
    final cartRef = _firestore.collection('cart').doc(cartItemId);
    await cartRef.delete();
  }

  /// 📡 Stream of cart items (SOURCE OF TRUTH)
  Stream<List<Map<String, dynamic>>> cartStream() {
    return _firestore
        .collection('cart')
        .orderBy('addedAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return {
              'id': doc.id, // 🔥 Important for UI actions
              ...doc.data(),
            };
          }).toList();
        });
  }

  Future<void> calculateCartTotal() async {
    double sum = 0;
    final snapshot = await FirebaseFirestore.instance.collection('cart').get();
    for (var doc in snapshot.docs) {
      final data = doc.data(); // 🔥 Remove RS, spaces, symbols
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
