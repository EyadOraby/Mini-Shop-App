import 'package:flutter_test/flutter_test.dart';
import 'package:mini_shop/cubits/product_cubit.dart';
import 'package:mini_shop/models/product_model.dart';
import 'package:mini_shop/repositories/product_repository.dart';
import 'package:mini_shop/services/api_service.dart';

Product product(int id, String title, double price, String category) => Product(
      id: id,
      title: title,
      price: price,
      description: '',
      category: category,
      image: '',
    );

final catalog = [
  product(1, 'Backpack', 109.95, "men's clothing"),
  product(2, 'Gold ring', 168, 'jewelery'),
  product(3, 'Cotton jacket', 55.99, "men's clothing"),
  product(4, 'SSD drive', 64, 'electronics'),
];

class FakeRepository extends ProductRepository {
  FakeRepository({this.fail = false}) : super(apiService: ApiService());

  bool fail;

  @override
  Future<List<Product>> getAllProducts() async {
    if (fail) throw Exception('offline');
    return catalog;
  }
}

void main() {
  group('Product.fromJson', () {
    test('reads whole-number prices as doubles', () {
      final p = Product.fromJson({
        'id': 1,
        'title': 'Ring',
        'price': 168,
        'description': 'Gold',
        'category': 'jewelery',
        'image': 'https://example.com/ring.png',
      });
      expect(p.price, 168.0);
      expect(p.category, 'jewelery');
    });
  });

  group('ProductCubit', () {
    late ProductCubit cubit;

    setUp(() async {
      cubit = ProductCubit(repository: FakeRepository());
      await cubit.fetchProducts();
    });

    tearDown(() => cubit.close());

    test('loads the catalog and lists categories once each', () {
      expect(cubit.state.products, hasLength(4));
      expect(cubit.state.categories, ["men's clothing", 'jewelery', 'electronics']);
      expect(cubit.state.isLoading, isFalse);
    });

    test('searches titles without caring about case', () {
      cubit.filterProducts('JACKET');
      expect(cubit.state.filteredProducts.map((p) => p.id), [3]);
    });

    test('filters by category and combines with search', () {
      cubit.selectCategory("men's clothing");
      expect(cubit.state.filteredProducts.map((p) => p.id), [1, 3]);
      cubit.filterProducts('back');
      expect(cubit.state.filteredProducts.map((p) => p.id), [1]);
      cubit.selectCategory(null);
      cubit.filterProducts('');
      expect(cubit.state.filteredProducts, hasLength(4));
    });

    test('sorts by price and name', () {
      cubit.sortBy(ProductSort.priceLowHigh);
      expect(cubit.state.filteredProducts.map((p) => p.id), [3, 4, 1, 2]);
      cubit.sortBy(ProductSort.priceHighLow);
      expect(cubit.state.filteredProducts.map((p) => p.id), [2, 1, 4, 3]);
      cubit.sortBy(ProductSort.name);
      expect(cubit.state.filteredProducts.map((p) => p.title).first, 'Backpack');
    });

    test('shows a friendly error and clears it after a successful retry', () async {
      final repository = FakeRepository(fail: true);
      final offline = ProductCubit(repository: repository);
      await offline.fetchProducts();
      expect(offline.state.errorMessage, contains('Could not load products'));

      repository.fail = false;
      await offline.fetchProducts();
      expect(offline.state.errorMessage, isNull);
      expect(offline.state.products, hasLength(4));
      await offline.close();
    });
  });
}
