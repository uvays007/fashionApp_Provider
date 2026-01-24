import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class OrdersProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<Map<String, dynamic>> _orders = [];
  bool _loading = false;

  List<Map<String, dynamic>> get orders => _orders;
  bool get loading => _loading;

  Future<void> fetchOrders() async {
    _loading = true;
    notifyListeners();

    final snapshot = await _firestore
        .collection('orders')
        .orderBy('addedAt', descending: true)
        .get();

    _orders = snapshot.docs.map((doc) {
      return {'id': doc.id, ...doc.data()};
    }).toList();

    _loading = false;
    notifyListeners();
  }

  Future<void> orderAdd(cartItems, finalTotal, address, selectedPayment) async {
    await _firestore.collection("orders").add({
      "items": cartItems,
      "total": finalTotal,
      "address": address,
      "payment_method": selectedPayment,
      "isPlaced": true,
      "status": "In Transit",

      "addedAt": FieldValue.serverTimestamp(),
    });
  }
}
