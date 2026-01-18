import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CartProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get uid => _auth.currentUser?.uid;

  /// 🔑 Create unique cart item id
  String _cartItemId({
    required String productId,
    required String size,
    required int color,
  }) {
    return '${productId}_${size}_$color';
  }

  /// ➕ Add to cart (with size, color, quantity)
  Future<void> addToCart(Map<String, dynamic> product) async {
    if (uid == null) return;

    final String productId = product['id'];
    final String size = product['size'];
    final int color = product['color'];
    final int quantity = product['quantity'] ?? 1;

    final cartItemId = _cartItemId(
      productId: productId,
      size: size,
      color: color,
    );

    final cartRef = _firestore
        .collection('users')
        .doc(uid)
        .collection('cart')
        .doc(cartItemId);

    final doc = await cartRef.get();

    if (doc.exists) {
      /// 🔁 Increase quantity
      await cartRef.update({'quantity': FieldValue.increment(quantity)});
    } else {
      /// 🆕 Add new cart item
      await cartRef.set({
        'productId': productId,
        'name': product['name'],
        'price': product['price'],
        'image': product['image'],
        'size': size,
        'color': color,
        'quantity': quantity,
        'addedAt': Timestamp.now(),
      });
    }

    notifyListeners();
  }

  /// ➕ Increment quantity
  Future<void> incrementQuantity(String cartItemId) async {
    if (uid == null) return;

    await _firestore
        .collection('users')
        .doc(uid)
        .collection('cart')
        .doc(cartItemId)
        .update({'quantity': FieldValue.increment(1)});

    notifyListeners();
  }

  /// ➖ Decrease quantity
  Future<void> decreaseQuantity(String cartItemId) async {
    if (uid == null) return;

    final cartRef = _firestore
        .collection('users')
        .doc(uid)
        .collection('cart')
        .doc(cartItemId);

    final doc = await cartRef.get();
    if (!doc.exists) return;

    final int qty = doc['quantity'];

    if (qty <= 1) {
      await cartRef.delete();
    } else {
      await cartRef.update({'quantity': FieldValue.increment(-1)});
    }

    notifyListeners();
  }

  /// ❌ Remove item completely
  Future<void> removeFromCart(String cartItemId) async {
    if (uid == null) return;

    await _firestore
        .collection('users')
        .doc(uid)
        .collection('cart')
        .doc(cartItemId)
        .delete();

    notifyListeners();
  }

  /// 📡 Cart stream
  Stream<List<Map<String, dynamic>>> cartStream() {
    if (uid == null) return const Stream.empty();

    return _firestore
        .collection('users')
        .doc(uid)
        .collection('cart')
        .orderBy('addedAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = doc.data();
            data['cartItemId'] = doc.id;
            return data;
          }).toList();
        });
  }
}
