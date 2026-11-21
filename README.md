# Mini Shop

[![Flutter](https://github.com/EyadOraby/Mini-Shop-App/actions/workflows/flutter.yml/badge.svg)](https://github.com/EyadOraby/Mini-Shop-App/actions/workflows/flutter.yml)

A Flutter shopping app: browse a live product catalog, search and filter it, open product details and keep a cart that survives restarts.

**Try it in the browser:** [eyadoraby.github.io/Mini-Shop-App](https://eyadoraby.github.io/Mini-Shop-App/)

## Features

- **Catalog** from a REST API ([Fake Store API](https://fakestoreapi.com)) through Dio
- **Search** by name, **category chips** and **sorting** (price either way, name), all combined
- **Pull to refresh**, a loading state, and a friendly error with **Try again** when offline
- **Product details** with a hero transition from the grid
- **Cart** with quantities and a running total, **saved offline with Hive** on every platform, including the web
- **Responsive grid** that adds columns on tablets and desktop browsers
- Material 3 design

## Architecture

```
lib/
  cubits/        state (ProductCubit, CartCubit, QuantityCubit) with flutter_bloc
  repositories/  ProductRepository (API) and CartRepository (Hive)
  services/      ApiService: the Dio client
  models/        Product and CartItem (with a generated Hive adapter)
  screens/       product list, product details, cart
  widgets/       cards, buttons and shared UI
```

The UI only talks to cubits, cubits only talk to repositories, and repositories hide where data comes from, so the API or the storage can change without touching screens. Search, category and sort are kept in the cubit's state and applied in one place (`ProductState.filteredProducts`), which keeps them consistent and easy to test.

## Tests and CI

`flutter test` covers JSON parsing and the catalog logic: loading, case-insensitive search, categories combined with search, every sort order, and errors that clear after a successful retry. GitHub Actions runs `flutter analyze`, the tests and a web build on every pull request, and publishes the web demo to GitHub Pages from `main`.

## Run it

```bash
flutter pub get
flutter run            # a device or emulator
flutter run -d chrome  # the web version
```

Requires Flutter with Dart 3.5 or later.
