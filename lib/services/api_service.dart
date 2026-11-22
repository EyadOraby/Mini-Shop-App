import 'package:makers_market/constants/app_endpoints.dart';
import 'package:dio/dio.dart';

class ApiService {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: AppEndpoints.baseUrl,
    connectTimeout: const Duration(seconds: 8),
    receiveTimeout: const Duration(seconds: 10),
  ));

  Future<Response> fetchAllProducts() async {
    try {
      return await _dio.get(AppEndpoints.getAllProducts);
    } catch (e) {
      throw Exception('Failed to load products');
    }
  }
}
