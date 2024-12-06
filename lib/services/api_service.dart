import 'package:corporatica_task_2/constants/app_endpoints.dart';
import 'package:dio/dio.dart';

class ApiService {
  final Dio _dio = Dio(BaseOptions(baseUrl: AppEndpoints.baseUrl));

  Future<Response> fetchAllProducts() async {
    try {
      return await _dio.get(AppEndpoints.getAllProducts);
    } catch (e) {
      throw Exception('Failed to load products');
    }
  }

  Future<Response> fetchProductById(int id) async {
    try {
      return await _dio.get("${AppEndpoints.getAllProducts}/$id");
    } catch (e) {
      throw Exception('Failed to load product details');
    }
  }
}
