import 'package:corporatica_task_2/models/product_model.dart';
import 'package:corporatica_task_2/services/api_service.dart';

class ProductRepository {
  final ApiService apiService;

  ProductRepository({required this.apiService});

  Future<List<Product>> getAllProducts() async {
    try {
      final response = await apiService.fetchAllProducts();
      return (response.data as List).map((productData) {
        return Product.fromJson(productData);
      }).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<Product> getProductDetails(int id) async {
    try {
      final response = await apiService.fetchProductById(id);
      return Product.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }
}
