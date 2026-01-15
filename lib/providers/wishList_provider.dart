import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class WishlistProvider extends ChangeNotifier {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  String? get uid => _auth.currentUser?.uid;

  final Map<String, bool> _likedMap = {}; // productId -> liked

  /// check local cache
  bool isLiked(String productId) {
    return _likedMap[productId] ?? false;
  }

  /// load like status from Firebase
  Future<void> loadLikeStatus(String productId) async {
    final uid = _auth.currentUser!.uid;

    final doc = await _firestore
        .collection('products')
        .doc(productId)
        .collection('likes')
        .doc(uid)
        .get();

    _likedMap[productId] = doc.exists;
    notifyListeners();
  }

  /// ❤️ ADD to wishlist
  Future<void> addToWishlist(Map<String, dynamic> product) async {
    final productId = product["id"];

    await _firestore.collection('likes').doc(productId).set({
      'productId': productId,
      'likedAt': Timestamp.now(),
    });

    _likedMap[productId] = true;
    notifyListeners();
  }

  /// 💔 REMOVE from wishlist
  Future<void> removeFromWishlist(String productId) async {
    final likeRef = _firestore.collection('likes').doc(productId);

    await likeRef.delete();

    _likedMap[productId] = false;
    notifyListeners();
  }

  /// 🔁 OPTIONAL: Toggle (if you still want)
  Future<void> toggleLike(Map<String, dynamic> product) async {
    final productId = product['id'];
    if (productId == null) return;

    if (isLiked(productId)) {
      await removeFromWishlist(productId);
    } else {
      await addToWishlist(product);
    }
  }

  Stream<List<Map<String, dynamic>>> wishlistStream() {
    return _firestore.collection('likes').snapshots().asyncMap((
      snapshot,
    ) async {
      final List<Map<String, dynamic>> items = [];

      for (var doc in snapshot.docs) {
        final productId = doc.id;

        // Fetch the actual product data
        final productSnap = await _firestore
            .collection('products')
            .doc(productId)
            .get();

        final data = productSnap.data();
        if (data != null) {
          data['id'] = productId; // attach id
          items.add(data);
        }
      }

      return items;
    });
  }
}
