import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:mini_shop/core/storage.dart';
import 'package:mini_shop/models/product_model.dart';
import 'package:mini_shop/services/api_service.dart';

/// Loads the catalog from the API, falling back to the last good copy on the
/// device and then to a copy bundled with the app, so the shop always opens.
class ProductRepository {
  ProductRepository({
    required this.apiService,
    this.store,
    Future<String> Function()? loadBundled,
  }) : _loadBundled = loadBundled ?? (() => rootBundle.loadString('assets/products.json'));

  final ApiService apiService;
  final KeyValueStore? store;
  final Future<String> Function() _loadBundled;

  static const _cacheKey = 'catalog';

  static List<Product> parse(List data) =>
      data.map((p) => Product.fromJson(Map<String, dynamic>.from(p as Map))).toList();

  Future<List<Product>> getAllProducts() async {
    try {
      final response = await apiService.fetchAllProducts();
      final data = response.data as List;
      await store?.write(_cacheKey, jsonEncode(data));
      return parse(data);
    } catch (_) {
      final cached = store?.read(_cacheKey);
      if (cached is String) return parse(jsonDecode(cached) as List);
      try {
        return parse(jsonDecode(await _loadBundled()) as List);
      } catch (_) {
        rethrow;
      }
    }
  }

  Future<Product> getProductDetails(int id) async {
    final response = await apiService.fetchProductById(id);
    return Product.fromJson(Map<String, dynamic>.from(response.data as Map));
  }
}
