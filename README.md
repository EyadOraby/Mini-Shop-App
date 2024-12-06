
# **Flutter Shopping Cart Application**

## **Description**
This Flutter application is a fully functional shopping cart app that demonstrates key features of modern app development, including state management, API integration, and local data storage. The app leverages clean architecture principles, making it modular, scalable, and easy to maintain.

## **Features**
- **Product Management**:
  - Fetch and display products from a remote API.
  - View detailed product information, including image, price, and description.
  - Search for products locally by name.

- **Shopping Cart**:
  - Add products to the cart with adjustable quantities.
  - Long press on a cart item to show a delete confirmation dialog.
  - Remove individual items or clear all items in the cart with a single button.
  - Real-time updates for item quantity and total price.

- **State Management**:
  - Manage states using `Cubit` from the `flutter_bloc` package.
  - Separate Cubits for handling products, cart operations, and quantity.

- **Local Storage**:
  - Persist cart data using Hive for offline functionality.
  - Cart data remains intact even after the app is restarted.

- **UI and UX**:
  - Clean, responsive, and modern UI design.
  - Interactive components such as long-press gestures and stylish buttons.

## **Technologies Used**
- **Flutter Framework**: For building a cross-platform app.
- **Dio (v5.0.0)**: For API integration and HTTP requests.
- **Hive Flutter (v1.1.0)**: For lightweight, local data storage.
- **flutter_bloc (v8.1.2)**: For state management using the Bloc pattern.
- **Path Provider (v2.0.10)**: For accessing file paths in the device.
- **Build Runner (v2.4.13)**: For code generation during development.

## **Setup Instructions**
1. Clone this repository:
   ```bash
   git clone https://github.com/EyadOraby/Mini-Shop-App.git
   ```
2. Navigate to the project directory:
   ```bash
   cd flutter-shopping-cart
   ```
3. Install dependencies:
   ```bash
   flutter pub get
   ```
4. Run the app:
   ```bash
   flutter run
   ```

## **Folder Structure**
```
lib/
├── cubits/              # State management using Cubit
├── models/              # Data models (e.g., Product, CartItem)
├── repositories/        # Repository layer for API and local data handling
├── screens/             # UI screens (e.g., Product List, Cart Screen)
├── services/            # API service for HTTP calls
├── widgets/             # Reusable UI components
└── main.dart            # Application entry point
```
