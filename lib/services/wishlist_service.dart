import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class WishlistService {
  final _firestore = FirebaseFirestore.instance;

  Future<void> addToWishlist(Map<String, dynamic> product, int index) async {
    String productId = product["id"] ?? UniqueKey().toString();

    await _firestore.collection("wishlist").doc(productId).set({
      ...product,
      "id": productId,
      "index": index,
    });
  }

  Future<void> removeFromWishlist(String productId) async {
    await _firestore.collection("wishlist").doc(productId).delete();
  }

  Stream<List<Map<String, dynamic>>> getWishlist() {
    return _firestore.collection("wishlist").snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data["id"] = doc.id;
        return data;
      }).toList();
    });
  }

  Future<void> removeByIndex(int index) async {
    final QuerySnapshot snapshot = await _firestore
        .collection("wishlist")
        .where("index", isEqualTo: index)
        .get();

    for (var doc in snapshot.docs) {
      await doc.reference.delete();
    }
  }
}
