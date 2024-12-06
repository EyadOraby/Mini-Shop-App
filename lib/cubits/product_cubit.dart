import 'package:corporatica_task_2/models/product_model.dart';
import 'package:corporatica_task_2/repositories/product_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProductState {
  final List<Product> products;
  final List<Product> filteredProducts;
  final Product? productDetails;
  final bool isLoading;
  final String? errorMessage;

  ProductState({
    this.products = const [],
    this.filteredProducts = const [],
    this.productDetails,
    this.isLoading = false,
    this.errorMessage,
  });

  ProductState copyWith({
    List<Product>? products,
    List<Product>? filteredProducts,
    Product? productDetails,
    bool? isLoading,
    String? errorMessage,
  }) {
    return ProductState(
      products: products ?? this.products,
      filteredProducts: filteredProducts ?? this.filteredProducts,
      productDetails: productDetails ?? this.productDetails,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class ProductCubit extends Cubit<ProductState> {
  final ProductRepository repository;

  ProductCubit({required this.repository}) : super(ProductState());

  void fetchProducts() async {
    emit(state.copyWith(isLoading: true));
    try {
      final products = await repository.getAllProducts();
      emit(state.copyWith(
          products: products, filteredProducts: products, isLoading: false));
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString(), isLoading: false));
    }
  }

  void filterProducts(String query) {
    final filtered = state.products
        .where((product) =>
            product.title.toLowerCase().contains(query.toLowerCase()))
        .toList();
    emit(state.copyWith(filteredProducts: filtered));
  }

  void fetchProductById(int id) async {
    emit(state.copyWith(isLoading: true));
    try {
      final product = await repository.getProductDetails(id);
      emit(state.copyWith(productDetails: product, isLoading: false));
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString(), isLoading: false));
    }
  }
}
