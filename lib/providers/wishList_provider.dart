import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class WishlistProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final Map<String, bool> _likedMap = {};

  bool isLiked(String productId) {
    return _likedMap[productId] ?? false;
  }

  Future<void> loadLikeStatus(String productId) async {
    try {
      final doc = await _firestore.collection('wishlist').doc(productId).get();

      _likedMap[productId] = doc.exists;
      notifyListeners();
    } catch (e) {
      debugPrint(" Error loading like status: $e");
    }
  }

  Future<bool> addToWishlist(Map<String, dynamic> product) async {
    final productId = product['id'];

    try {
      await _firestore.collection('wishlist').doc(productId).set({
        ..._cleanProductData(product),
        'addedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      _likedMap[productId] = true;
      notifyListeners();

      debugPrint(" Added product '$productId' to wishlist");
      return true;
    } catch (e) {
      debugPrint("Error adding to wishlist: $e");
      return false;
    }
  }

  Future<bool> removeFromWishlist(String productId) async {
    try {
      await _firestore.collection('wishlist').doc(productId).delete();

      _likedMap[productId] = false;
      notifyListeners();

      debugPrint(" Removed product '$productId' from wishlist");
      return true;
    } catch (e) {
      debugPrint(" Error removing from wishlist: $e");
      return false;
    }
  }

  Future<bool> toggleLike(Map<String, dynamic> product) async {
    final productId = product['id'];

    try {
      if (isLiked(productId)) {
        return await removeFromWishlist(productId);
      } else {
        return await addToWishlist(product);
      }
    } catch (e) {
      debugPrint(" Error toggling like: $e");
      return false;
    }
  }

  Stream<List<Map<String, dynamic>>> wishlistStream() {
    return _firestore
        .collection('wishlist')
        .orderBy('addedAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return {'id': doc.id, ...doc.data()};
          }).toList();
        });
  }

  Future<void> loadMultipleLikeStatuses(List<String> productIds) async {
    try {
      for (var productId in productIds) {
        await loadLikeStatus(productId);
      }
    } catch (e) {
      debugPrint(" Error loading multiple like statuses: $e");
    }
  }

  Map<String, dynamic> _cleanProductData(Map<String, dynamic> product) {
    final cleaned = Map<String, dynamic>.from(product);

    cleaned['id'] = cleaned['id']?.toString() ?? '';
    cleaned['name'] = cleaned['name']?.toString() ?? 'Unknown Product';
    cleaned['price'] = cleaned['price']?.toString() ?? 'N/A';
    cleaned['image'] = cleaned['image']?.toString() ?? '';
    cleaned['brandname'] = cleaned['brandname']?.toString() ?? '';

    cleaned.removeWhere((key, value) {
      return value is Timestamp ||
          value is FieldValue ||
          value is GeoPoint ||
          value is DocumentReference;
    });

    return cleaned;
  }

  void clearCache() {
    _likedMap.clear();
    notifyListeners();
  }
}
