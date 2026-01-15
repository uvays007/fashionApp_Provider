import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomeProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// 🔥 All products
  List<Map<String, dynamic>> _products = [];

  /// 🔍 Filtered products (search)
  List<Map<String, dynamic>> _filteredProducts = [];

  /// ⏳ Loading state
  bool _loading = false;

  /// ❌ Error message
  String? _error;

  // ================= GETTERS =================

  List<Map<String, dynamic>> get products => _products;
  List<Map<String, dynamic>> get filteredProducts => _filteredProducts;
  bool get isLoading => _loading;
  String? get error => _error;

  // ================= METHODS =================

  /// 🔄 Load products from Firestore
  Future<void> loadProducts() async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final snapshot = await _firestore.collection('products').get();

      _products = snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();

      _filteredProducts = List.from(_products);
    } catch (e) {
      _error = 'Failed to load products';
    }

    _loading = false;
    notifyListeners();
  }

  /// 🔍 Search products
  void searchProducts(String query) {
    if (query.isEmpty) {
      _filteredProducts = List.from(_products);
    } else {
      _filteredProducts = _products.where((product) {
        final brand = (product['brandname'] ?? '').toString().toLowerCase();
        final name = (product['name'] ?? '').toString().toLowerCase();

        return brand.contains(query.toLowerCase()) ||
            name.contains(query.toLowerCase());
      }).toList();
    }
    notifyListeners();
  }

  /// 🔁 Refresh products
  Future<void> refresh() async {
    await loadProducts();
  }

  /// ♻ Clear state
  void clear() {
    _products.clear();
    _filteredProducts.clear();
    notifyListeners();
  }
}
