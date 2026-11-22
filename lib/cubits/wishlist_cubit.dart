import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:makers_market/core/storage.dart';

/// Ids of saved products, kept on the device.
class WishlistCubit extends Cubit<Set<int>> {
  WishlistCubit(this._store) : super(<int>{}) {
    final saved = _store.read(_key);
    if (saved is List) emit(saved.cast<int>().toSet());
  }

  static const _key = 'wishlist';
  final KeyValueStore _store;

  void toggle(int productId) {
    final next = {...state};
    if (!next.remove(productId)) next.add(productId);
    emit(next);
    _store.write(_key, next.toList());
  }
}
