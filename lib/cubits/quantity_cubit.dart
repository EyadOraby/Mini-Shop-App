// ignore_for_file: depend_on_referenced_packages

import 'package:bloc/bloc.dart';

class QuantityState {
  final int quantity;

  const QuantityState({required this.quantity});
}

class QuantityCubit extends Cubit<QuantityState> {
  QuantityCubit() : super(const QuantityState(quantity: 1));

  void increment() {
    emit(QuantityState(quantity: state.quantity + 1));
  }

  void decrement() {
    if (state.quantity > 1) {
      emit(QuantityState(quantity: state.quantity - 1));
    }
  }
}
