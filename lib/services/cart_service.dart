import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class CartlistService {
  final _firestore = FirebaseFirestore.instance;

  Future<void> addToCart(Map<String, dynamic> product) async {
    String productId = product["id"] ?? UniqueKey().toString();

    await _firestore.collection("cart").doc(productId).set({
      ...product,
      "id": productId,
    });
  }

  Future<void> removeFromCart(String productId) async {
    await _firestore.collection("cart").doc(productId).delete();
  }

  Stream<List<Map<String, dynamic>>> getCartlist() {
    return _firestore.collection("cart").snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data["id"] = doc.id;
        return data;
      }).toList();
    });
  }

  Future<void> removeByIndex(int index) async {
    final QuerySnapshot snapshot = await _firestore
        .collection("cart")
        .where("index", isEqualTo: index)
        .get();

    for (var doc in snapshot.docs) {
      await doc.reference.delete();
    }
  }
}
