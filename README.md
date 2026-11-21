# Mini Shop

[![Flutter](https://github.com/EyadOraby/Mini-Shop-App/actions/workflows/flutter.yml/badge.svg)](https://github.com/EyadOraby/Mini-Shop-App/actions/workflows/flutter.yml)

A Flutter shopping app: browse a live product catalog, search and filter it, open product details and keep a cart that survives restarts.

**Try it in the browser:** [eyadoraby.github.io/Mini-Shop-App](https://eyadoraby.github.io/Mini-Shop-App/)

## Features

- **Storefront** with search, category chips with icons, sorting, a promo banner and a responsive grid with ratings
- **Product details** with a large photo, star rating and review count, perks, an expandable description, a quantity stepper, a sticky "Add to cart" bar and "You may also like"
- **Wishlist** saved on the device, with a heart on every product
- **Cart** with steppers, swipe to remove with undo, a free-shipping progress bar, promo codes (`MINI10`, `WELCOME20`) and an order summary
- **Checkout** in three steps: validated delivery details, cash or card (demo), and a review, then an animated confirmation
- **Orders** with a processing, shipped and delivered timeline
- **Dark mode**, remembered between visits
- **Works offline**: the catalog comes from the [Fake Store API](https://fakestoreapi.com), falls back to the last good copy, then to a copy bundled with the app
- On the web, `?demo=1` fills the cart, wishlist and orders, and `?screen=cart`, `?screen=product&id=5` and similar open a screen directly

## Architecture

```
lib/
  app/           theme (light and dark)
  core/          KeyValueStore: Hive in the app, in memory in tests
  logic/         CartSummary: subtotal, promo discount, shipping and total
  cubits/        products, cart, wishlist, orders and theme (flutter_bloc)
  repositories/  ProductRepository with API, cache and bundled fallbacks
  models/        Product, CartItem, Order
  screens/       shell, shop, details, cart, checkout, orders and wishlist
  widgets/       product card, rating stars, quantity stepper, empty states
```

Screens only talk to cubits; cubits keep state and save it through `KeyValueStore`, so every rule (pricing, promo codes, cart changes, order history, fallbacks) is tested without a device.

## Tests and CI

`flutter test` covers the catalog (search, categories, sorting, retries and offline fallbacks), pricing and promo codes, the cart, wishlist, orders, theme and checkout validation. GitHub Actions runs `flutter analyze`, the tests and a web build on every pull request, and publishes the web demo to GitHub Pages from `main`.

## Run it

```bash
flutter pub get
flutter run            # a device or emulator
flutter run -d chrome  # the web version
```

Requires Flutter with Dart 3.5 or later.
