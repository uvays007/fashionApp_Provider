import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class WishlistProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get uid => _auth.currentUser?.uid;
  bool get isLoggedIn => uid != null;

  final Map<String, bool> _likedMap = {}; // productId -> liked status cache

  // MARK: - Public Methods

  /// Check if product is liked by current user
  bool isLiked(String productId) {
    return _likedMap[productId] ?? false;
  }

  /// Load like status from Firebase for a product
  Future<void> loadLikeStatus(String productId) async {
    if (!isLoggedIn) return;

    try {
      final doc = await _firestore
          .collection('users')
          .doc(uid)
          .collection('wishlist')
          .doc(productId)
          .get();

      _likedMap[productId] = doc.exists;
      notifyListeners();
    } catch (e) {
      debugPrint("❌ Error loading like status: $e");
    }
  }

  /// Add product to wishlist
  Future<bool> addToWishlist(Map<String, dynamic> product) async {
    final productId = product['id']?.toString();

    if (!isLoggedIn || productId == null) {
      debugPrint(
        "⚠️ Cannot add to wishlist: ${!isLoggedIn ? 'User not logged in' : 'Product ID is null'}",
      );
      return false;
    }

    try {
      // Store full product data in user's wishlist
      await _firestore
          .collection('users')
          .doc(uid)
          .collection('wishlist')
          .doc(productId)
          .set({
            ..._cleanProductData(product),
            'addedAt': FieldValue.serverTimestamp(),
            'userId': uid,
          }, SetOptions(merge: true));

      _likedMap[productId] = true;
      notifyListeners();

      debugPrint("✅ Added product '$productId' to wishlist");
      return true;
    } catch (e) {
      debugPrint("❌ Error adding to wishlist: $e");
      return false;
    }
  }

  /// Remove product from wishlist
  Future<bool> removeFromWishlist(String productId) async {
    if (!isLoggedIn) return false;

    try {
      await _firestore
          .collection('users')
          .doc(uid)
          .collection('wishlist')
          .doc(productId)
          .delete();

      _likedMap[productId] = false;
      notifyListeners();

      debugPrint("✅ Removed product '$productId' from wishlist");
      return true;
    } catch (e) {
      debugPrint("❌ Error removing from wishlist: $e");
      return false;
    }
  }

  /// Toggle like status
  Future<bool> toggleLike(Map<String, dynamic> product) async {
    final productId = product['id']?.toString();
    if (!isLoggedIn || productId == null) return false;

    try {
      if (isLiked(productId)) {
        return await removeFromWishlist(productId);
      } else {
        return await addToWishlist(product);
      }
    } catch (e) {
      debugPrint("❌ Error toggling like: $e");
      return false;
    }
  }

  /// Get wishlist stream for current user
  Stream<List<Map<String, dynamic>>> wishlistStream() {
    if (!isLoggedIn) {
      return Stream.value([]);
    }

    return _firestore
        .collection('users')
        .doc(uid)
        .collection('wishlist')
        .orderBy('addedAt', descending: true)
        .snapshots()
        .handleError((error) {
          debugPrint("❌ Wishlist stream error: $error");
          return const Stream.empty();
        })
        .map((snapshot) => snapshot.docs.map(_mapDocument).toList());
  }

  /// Get wishlist count stream
  Stream<int> wishlistCountStream() {
    if (!isLoggedIn) return Stream.value(0);

    return _firestore
        .collection('users')
        .doc(uid)
        .collection('wishlist')
        .snapshots()
        .map((snapshot) => snapshot.docs.length)
        .handleError((_) => 0);
  }

  /// Clear entire wishlist
  Future<bool> clearWishlist() async {
    if (!isLoggedIn) return false;

    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(uid)
          .collection('wishlist')
          .get();

      final batch = _firestore.batch();
      for (var doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();

      _likedMap.clear();
      notifyListeners();

      debugPrint("✅ Cleared wishlist");
      return true;
    } catch (e) {
      debugPrint("❌ Error clearing wishlist: $e");
      return false;
    }
  }

  /// Check if product exists in wishlist
  Future<bool> isInWishlist(String productId) async {
    if (!isLoggedIn) return false;

    try {
      final doc = await _firestore
          .collection('users')
          .doc(uid)
          .collection('wishlist')
          .doc(productId)
          .get();
      return doc.exists;
    } catch (e) {
      debugPrint("❌ Error checking wishlist: $e");
      return false;
    }
  }

  /// Bulk load like statuses for multiple products
  Future<void> loadMultipleLikeStatuses(List<String> productIds) async {
    if (!isLoggedIn) return;

    try {
      for (var productId in productIds) {
        await loadLikeStatus(productId);
      }
    } catch (e) {
      debugPrint("❌ Error loading multiple like statuses: $e");
    }
  }

  // MARK: - Private Helper Methods

  /// Clean product data before storing
  Map<String, dynamic> _cleanProductData(Map<String, dynamic> product) {
    final cleaned = Map<String, dynamic>.from(product);

    // Ensure essential fields exist
    cleaned['id'] = cleaned['id']?.toString() ?? '';
    cleaned['name'] = cleaned['name']?.toString() ?? 'Unknown Product';
    cleaned['price'] = cleaned['price']?.toString() ?? 'N/A';
    cleaned['image'] = cleaned['image']?.toString() ?? '';
    cleaned['brandname'] = cleaned['brandname']?.toString() ?? '';

    // Remove any non-serializable objects
    cleaned.removeWhere((key, value) {
      return value is Timestamp ||
          value is FieldValue ||
          value is GeoPoint ||
          value is DocumentReference;
    });

    return cleaned;
  }

  /// Map Firestore document to product map
  Map<String, dynamic> _mapDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};

    // Ensure all required fields exist
    return {
      'id': data['id']?.toString() ?? doc.id,
      'name': data['name']?.toString() ?? 'Unknown Product',
      'price': data['price']?.toString() ?? 'N/A',
      'image': data['image']?.toString() ?? '',
      'brandname': data['brandname']?.toString() ?? '',
      'addedAt': data['addedAt'],
      'userId': data['userId'],
      'wishlistDocId': doc.id, // Reference to wishlist document
      ...data, // Include any other fields
    };
  }

  /// Clear local cache (useful on logout)
  void clearCache() {
    _likedMap.clear();
    notifyListeners();
  }
}
