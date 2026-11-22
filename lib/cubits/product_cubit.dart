import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:makers_market/models/product_model.dart';
import 'package:makers_market/repositories/product_repository.dart';

/// How the product grid is ordered.
enum ProductSort { featured, priceLowHigh, priceHighLow, name }

class ProductState {
  final List<Product> products;
  final String query;
  final String? category;
  final ProductSort sort;
  final Product? productDetails;
  final bool isLoading;
  final String? errorMessage;

  const ProductState({
    this.products = const [],
    this.query = '',
    this.category,
    this.sort = ProductSort.featured,
    this.productDetails,
    this.isLoading = false,
    this.errorMessage,
  });

  /// Every category in the catalog, in the order they first appear.
  List<String> get categories =>
      products.map((p) => p.category).toSet().toList(growable: false);

  /// The products to show after search, category and sort are applied.
  List<Product> get filteredProducts {
    final q = query.trim().toLowerCase();
    final list = products
        .where((p) => category == null || p.category == category)
        .where((p) => q.isEmpty || p.title.toLowerCase().contains(q))
        .toList();
    switch (sort) {
      case ProductSort.featured:
        break;
      case ProductSort.priceLowHigh:
        list.sort((a, b) => a.price.compareTo(b.price));
      case ProductSort.priceHighLow:
        list.sort((a, b) => b.price.compareTo(a.price));
      case ProductSort.name:
        list.sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
    }
    return list;
  }

  ProductState copyWith({
    List<Product>? products,
    String? query,
    String? Function()? category,
    ProductSort? sort,
    Product? productDetails,
    bool? isLoading,
    String? Function()? errorMessage,
  }) {
    return ProductState(
      products: products ?? this.products,
      query: query ?? this.query,
      category: category != null ? category() : this.category,
      sort: sort ?? this.sort,
      productDetails: productDetails ?? this.productDetails,
      isLoading: isLoading ?? this.isLoading,
      // Passed as a function so an old error can be cleared with () => null.
      errorMessage: errorMessage != null ? errorMessage() : this.errorMessage,
    );
  }
}

class ProductCubit extends Cubit<ProductState> {
  final ProductRepository repository;

  ProductCubit({required this.repository}) : super(const ProductState());

  Future<void> fetchProducts() async {
    emit(state.copyWith(isLoading: true, errorMessage: () => null));
    try {
      final products = await repository.getAllProducts();
      emit(state.copyWith(products: products, isLoading: false));
    } catch (_) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: () => 'Could not load products. Check your connection and try again.',
      ));
    }
  }

  void filterProducts(String query) => emit(state.copyWith(query: query));

  void selectCategory(String? category) =>
      emit(state.copyWith(category: () => category));

  void sortBy(ProductSort sort) => emit(state.copyWith(sort: sort));

  Future<void> fetchProductById(int id) async {
    emit(state.copyWith(isLoading: true, errorMessage: () => null));
    try {
      final product = await repository.getProductDetails(id);
      emit(state.copyWith(productDetails: product, isLoading: false));
    } catch (_) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: () => 'Could not load this product. Try again.',
      ));
    }
  }
}
