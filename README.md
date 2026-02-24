# Pembuatan Shopping Cart Enhancement
## Membuat Cart Item 
```dart
// lib/models/cart_item.dart
import 'product.dart';

class CartItem {
  final Product product;
  int quantity;

  CartItem({
    required this.product,
    this.quantity = 1,
  });

  // Calculated property
  double get totalPrice => product.price * quantity;
}
```
### Membuat Cart Model
```dart
// lib/models/cart_model.dart
import 'package:flutter/foundation.dart';
import 'product.dart';
import 'cart_item.dart';

class CartModel extends ChangeNotifier {
  // Private state - Map for O(1) lookup
  final Map<String, CartItem> _items = {};

  // Getters
  Map<String, CartItem> get items => _items;

  List<CartItem> get itemsList => _items.values.toList();

  int get itemCount => _items.length;

  int get totalQuantity {
    return _items.values.fold(0, (sum, item) => sum + item.quantity);
  }

  double get totalPrice {
    return _items.values.fold(0.0, (sum, item) => sum + item.totalPrice);
  }

  bool get isEmpty => _items.isEmpty;

  // Methods
  void addItem(Product product) {
    if (_items.containsKey(product.id)) {
      // Product already in cart, increase quantity
      _items[product.id]!.quantity++;
    } else {
      // New product, add to cart
      _items[product.id] = CartItem(product: product);
    }
    notifyListeners(); // ← Notify UI!
  }

  void removeItem(String productId) {
    _items.remove(productId);
    notifyListeners();
  }

  void increaseQuantity(String productId) {
    if (_items.containsKey(productId)) {
      _items[productId]!.quantity++;
      notifyListeners();
    }
  }

  void decreaseQuantity(String productId) {
    if (!_items.containsKey(productId)) return;

    if (_items[productId]!.quantity > 1) {
      _items[productId]!.quantity--;
    } else {
      // If quantity becomes 0, remove item
      _items.remove(productId);
    }
    notifyListeners();
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }
}

```

### Membuat product

```dart
// lib/models/product.dart
class Product {
  final String id;
  final String name;
  final double price;
  final String emoji;      // ← Emoji sebagai gambar produk (offline-friendly!)
  final String description;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.emoji,
    required this.description,
  });
}
```
# Pembuatan Pages
### Membuat Cart Page
```dart
// lib/pages/cart_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/cart_model.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shopping Cart'),
        actions: [
          // Clear cart button
          Consumer<CartModel>(
            builder: (context, cart, child) {
              return cart.isEmpty
                  ? const SizedBox.shrink()
                  : IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () {
                        // Show confirmation dialog
                        showDialog(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text('Clear Cart?'),
                            content: const Text('Remove all items from cart?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(ctx),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () {
                                  context.read<CartModel>().clear();
                                  Navigator.pop(ctx);
                                },
                                child: const Text('Clear'),
                              ),
                            ],
                          ),
                        );
                      },
                    );
            },
          ),
        ],
      ),
      body: Consumer<CartModel>(
        builder: (context, cart, child) {
          if (cart.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shopping_cart_outlined,
                    size: 100,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Your cart is empty',
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Continue Shopping'),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: cart.itemsList.length,
                  itemBuilder: (context, index) {
                    final cartItem = cart.itemsList[index];
                    final product = cartItem.product;

                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Row(
                          children: [
                            // Product emoji
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color: Colors.deepPurple.shade50,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Center(
                                child: Text(
                                  product.emoji,
                                  style: const TextStyle(fontSize: 40),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            // Product info
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    product.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Rp ${product.price.toStringAsFixed(0)}',
                                    style: TextStyle(
                                      color: Colors.green[700],
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  // Quantity controls
                                  Row(
                                    children: [
                                      IconButton(
                                        onPressed: () {
                                          cart.decreaseQuantity(product.id);
                                        },
                                        icon: const Icon(Icons.remove_circle_outline),
                                        constraints: const BoxConstraints(),
                                        padding: EdgeInsets.zero,
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 12),
                                        child: Text(
                                          '${cartItem.quantity}',
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      IconButton(
                                        onPressed: () {
                                          cart.increaseQuantity(product.id);
                                        },
                                        icon: const Icon(Icons.add_circle_outline),
                                        constraints: const BoxConstraints(),
                                        padding: EdgeInsets.zero,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            // Remove button & subtotal
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                IconButton(
                                  onPressed: () {
                                    cart.removeItem(product.id);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('${product.name} removed'),
                                        duration: const Duration(seconds: 1),
                                      ),
                                    );
                                  },
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                ),
                                Text(
                                  'Rp ${cartItem.totalPrice.toStringAsFixed(0)}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              // Total price bar
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: SafeArea(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'Total',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                          Text(
                            'Rp ${cart.totalPrice.toStringAsFixed(0)}',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                        ],
                      ),
                      ElevatedButton(
                        onPressed: () {
                          // Checkout action
                          showDialog(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text('Checkout'),
                              content: Text(
                                'Total: Rp ${cart.totalPrice.toStringAsFixed(0)}\nItems: ${cart.totalQuantity}',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx),
                                  child: const Text('Cancel'),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    cart.clear();
                                    Navigator.pop(ctx);
                                    Navigator.pop(context);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Order placed!')),
                                    );
                                  },
                                  child: const Text('Confirm'),
                                ),
                              ],
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 40,
                            vertical: 16,
                          ),
                        ),
                        child: const Text(
                          'Checkout',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

```

### Membuat Product List Page
```dart
// lib/pages/product_list_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../models/cart_model.dart';
import 'cart_page.dart';

class ProductListPage extends StatelessWidget {
  const ProductListPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Dummy products
    final products = [
      Product(
        id: '1',
        name: 'Laptop Gaming',
        price: 15000000,
        emoji: '💻',
        description: 'Laptop gaming performa tinggi',
      ),
      Product(
        id: '2',
        name: 'Smartphone Pro',
        price: 8000000,
        emoji: '📱',
        description: 'Smartphone flagship terbaru',
      ),
      Product(
        id: '3',
        name: 'Wireless Headphones',
        price: 1500000,
        emoji: '🎧',
        description: 'Headphones noise-cancelling',
      ),
      Product(
        id: '4',
        name: 'Smart Watch',
        price: 3000000,
        emoji: '⌚',
        description: 'Smartwatch dengan health tracking',
      ),
      Product(
        id: '5',
        name: 'Camera DSLR',
        price: 12000000,
        emoji: '📷',
        description: 'Kamera DSLR profesional',
      ),
      Product(
        id: '6',
        name: 'Tablet Pro',
        price: 7000000,
        emoji: '📟',
        description: 'Tablet untuk produktivitas',
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Products'),
        actions: [
          // Cart badge
          Consumer<CartModel>(
            builder: (context, cart, child) {
              return Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.shopping_cart),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CartPage(),
                        ),
                      );
                    },
                  ),
                  if (cart.itemCount > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          '${cart.itemCount}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.7,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: products.length,
        itemBuilder: (context, index) {
          final product = products[index];
          return Card(
            elevation: 3,
            child: Column(
              children: [
                Expanded(
                  child: Container(
                    color: Colors.deepPurple.shade50,
                    child: Center(
                      child: Text(
                        product.emoji,
                        style: const TextStyle(fontSize: 64),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    children: [
                      Text(
                        product.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Rp ${product.price.toStringAsFixed(0)}',
                        style: TextStyle(
                          color: Colors.green[700],
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            // Add to cart using Provider!
                            context.read<CartModel>().addItem(product);

                            // Show feedback
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('${product.name} ditambahkan ke cart!'),
                                duration: const Duration(seconds: 1),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          },
                          icon: const Icon(Icons.add_shopping_cart, size: 16),
                          label: const Text('Add', style: TextStyle(fontSize: 12)),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
```

### Main Dart 
```dart
// main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'models/cart_model.dart';
import 'pages/product_list_page.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => CartModel(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Shopping Cart',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const ProductListPage(),
    );
  }
}
```
### Dokumentasi hasil percobaan pembuatan shopping cart 

✓ Add to cart from product list
✓ Show cart items dengan quantity
✓ Update quantity (+/-)
✓ Remove items from cart
✓ Display total price correctly


<img width="953" height="906" alt="{1F8EEE8C-1890-4AF1-AB50-F09BB4175002}" src="https://github.com/user-attachments/assets/9588dd53-654a-4a63-9f82-edb4d22466e8" />



<img width="957" height="906" alt="{F34AC3EC-0116-49E2-9947-832AB0B8351E}" src="https://github.com/user-attachments/assets/b9e8e96d-f508-441f-ab58-e3a74f1b14eb" />



<img width="962" height="916" alt="{B618387A-61C6-4793-9A22-B5DA5646014E}" src="https://github.com/user-attachments/assets/301098fc-b164-490a-9258-840b813eb386" />


<img width="943" height="880" alt="image" src="https://github.com/user-attachments/assets/22791f59-3461-40ca-b172-6278ed7400b4" />


<img width="961" height="915" alt="image" src="https://github.com/user-attachments/assets/80fb6d53-9ddd-4a95-bb21-eb541d53e3ff" />


<img width="955" height="910" alt="image" src="https://github.com/user-attachments/assets/13b37ffd-7dd6-43ff-916d-e2f7bd8a1638" />


<img width="958" height="914" alt="image" src="https://github.com/user-attachments/assets/a7a4edcc-5198-49fc-9d6d-30a5e178734e" />


# Bonus Pengerjaan
* Search/Filter (+10) - Search products by name
* Categories  (+10) - Filter products by category
* Checkout Page (+10) - Order summary + form


### perubahan kode pada file product.dart
* Pemanmbahan final String.category dan required this.category
```dart
// lib/models/product.dart
class Product {
  final String id;
  final String name;
  final double price;
  final String emoji;      // ← Emoji sebagai gambar produk (offline-friendly!)
  final String description;
  final String category;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.emoji,
    required this.description,
    required this.category
  });
}
```
### modifikasi kode pada file product_list_page.dart pada package pages
* untuk menambahkan search dan filter category

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../models/cart_model.dart';
import 'cart_page.dart';

class ProductListPage extends StatefulWidget {
  const ProductListPage({super.key});

  @override
  State<ProductListPage> createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  String searchQuery = '';
  String selectedCategory = 'All';

  final List<Product> products = [
    Product(
      id: '1',
      name: 'Laptop Gaming',
      price: 15000000,
      emoji: '💻',
      description: 'Laptop gaming performa tinggi',
      category: 'Electronics',
    ),
    Product(
      id: '2',
      name: 'Smartphone Pro',
      price: 8000000,
      emoji: '📱',
      description: 'Smartphone flagship terbaru',
      category: 'Electronics',
    ),
    Product(
      id: '3',
      name: 'Wireless Headphones',
      price: 1500000,
      emoji: '🎧',
      description: 'Headphones noise-cancelling',
      category: 'Accessories',
    ),
    Product(
      id: '4',
      name: 'Smart Watch',
      price: 3000000,
      emoji: '⌚',
      description: 'Smartwatch dengan health tracking',
      category: 'Accessories',
    ),
    Product(
      id: '5',
      name: 'Camera DSLR',
      price: 12000000,
      emoji: '📷',
      description: 'Kamera DSLR profesional',
      category: 'Electronics',
    ),

    Product(
        id: '6',
        name: 'Tablet Pro',
        price: 7000000,
        emoji: '📟',
        description: 'Tablet Serbaguna (Gaming)', category: 'Electronics',
      ),
  ];

  @override
  Widget build(BuildContext context) {
    final filteredProducts = products.where((product) {
      final matchSearch = product.name
          .toLowerCase()
          .contains(searchQuery.toLowerCase());

      final matchCategory =
          selectedCategory == 'All' || product.category == selectedCategory;

      return matchSearch && matchCategory;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Products'),
        actions: [
          Consumer<CartModel>(
            builder: (context, cart, child) {
              return Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.shopping_cart),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const CartPage(),
                        ),
                      );
                    },
                  ),
                  if (cart.itemCount > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: CircleAvatar(
                        radius: 10,
                        backgroundColor: Colors.red,
                        child: Text(
                          '${cart.itemCount}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // 🔎 SEARCH
          Padding(
            padding: const EdgeInsets.all(8),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Search product...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
              },
            ),
          ),

          // 🏷 CATEGORY FILTER
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: DropdownButtonFormField<String>(
              initialValue: selectedCategory,
              items: ['All', 'Electronics', 'Accessories']
                  .map((category) => DropdownMenuItem(
                        value: category,
                        child: Text(category),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  selectedCategory = value!;
                });
              },
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
            ),
          ),

          const SizedBox(height: 10),

          // GRID
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.7,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: filteredProducts.length,
              itemBuilder: (context, index) {
                final product = filteredProducts[index];

                return Card(
                  child: Column(
                    children: [
                      Expanded(
                        child: Center(
                          child: Text(
                            product.emoji,
                            style: const TextStyle(fontSize: 64),
                          ),
                        ),
                      ),
                      Text(product.name,
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text(
                        'Rp ${product.price.toStringAsFixed(0)}',
                        style: const TextStyle(color: Colors.green),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          context.read<CartModel>().addItem(product);
                        },
                        child: const Text('Add'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
```

### Membuat file baru dengan nama checkout_page.dart pada package pages
* berikut kode pada file checkout_page.dart

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/cart_model.dart';

class CheckoutPage extends StatelessWidget {
  const CheckoutPage({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartModel>();

    final nameController = TextEditingController();
    final addressController = TextEditingController();
    final phoneController = TextEditingController();

    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            const Text(
              'Order Summary',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            ...cart.itemsList.map((item) => ListTile(
                  title: Text(item.product.name),
                  subtitle: Text('Qty: ${item.quantity}'),
                  trailing: Text(
                      'Rp ${item.totalPrice.toStringAsFixed(0)}'),
                )),

            const Divider(),
            Text(
              'Total: Rp ${cart.totalPrice.toStringAsFixed(0)}',
              style: const TextStyle(
                  fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 20),

            const Text(
              'Customer Information',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            TextField(
              controller: nameController,
              decoration:
                  const InputDecoration(labelText: 'Full Name'),
            ),
            TextField(
              controller: addressController,
              decoration:
                  const InputDecoration(labelText: 'Address'),
            ),
            TextField(
              controller: phoneController,
              decoration:
                  const InputDecoration(labelText: 'Phone Number'),
              keyboardType: TextInputType.phone,
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: () {
                cart.clear();
                Navigator.pop(context);
                Navigator.pop(context);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Order successfully placed!'),
                  ),
                );
              },
              child: const Text('Confirm Order'),
            )
          ],
        ),
      ),
    );
  }
}
```

### Modifikasi kode pada cart_page.dart 
```dart
// lib/pages/cart_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/cart_model.dart';
import 'checkout_page.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shopping Cart'),
        actions: [
          // Clear cart button
          Consumer<CartModel>(
            builder: (context, cart, child) {
              return cart.isEmpty
                  ? const SizedBox.shrink()
                  : IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () {
                        // Show confirmation dialog
                        showDialog(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text('Clear Cart?'),
                            content: const Text('Remove all items from cart?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(ctx),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () {
                                  context.read<CartModel>().clear();
                                  Navigator.pop(ctx);
                                },
                                child: const Text('Clear'),
                              ),
                            ],
                          ),
                        );
                      },
                    );
            },
          ),
        ],
      ),
      body: Consumer<CartModel>(
        builder: (context, cart, child) {
          if (cart.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shopping_cart_outlined,
                    size: 100,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Your cart is empty',
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Continue Shopping'),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: cart.itemsList.length,
                  itemBuilder: (context, index) {
                    final cartItem = cart.itemsList[index];
                    final product = cartItem.product;

                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Row(
                          children: [
                            // Product emoji
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color: Colors.deepPurple.shade50,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Center(
                                child: Text(
                                  product.emoji,
                                  style: const TextStyle(fontSize: 40),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            // Product info
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    product.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Rp ${product.price.toStringAsFixed(0)}',
                                    style: TextStyle(
                                      color: Colors.green[700],
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  // Quantity controls
                                  Row(
                                    children: [
                                      IconButton(
                                        onPressed: () {
                                          cart.decreaseQuantity(product.id);
                                        },
                                        icon: const Icon(Icons.remove_circle_outline),
                                        constraints: const BoxConstraints(),
                                        padding: EdgeInsets.zero,
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 12),
                                        child: Text(
                                          '${cartItem.quantity}',
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      IconButton(
                                        onPressed: () {
                                          cart.increaseQuantity(product.id);
                                        },
                                        icon: const Icon(Icons.add_circle_outline),
                                        constraints: const BoxConstraints(),
                                        padding: EdgeInsets.zero,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            // Remove button & subtotal
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                IconButton(
                                  onPressed: () {
                                    cart.removeItem(product.id);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('${product.name} removed'),
                                        duration: const Duration(seconds: 1),
                                      ),
                                    );
                                  },
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                ),
                                Text(
                                  'Rp ${cartItem.totalPrice.toStringAsFixed(0)}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              // Total price bar
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      // ignore: deprecated_member_use
                      color: Colors.grey.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: SafeArea(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'Total',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                          Text(
                            'Rp ${cart.totalPrice.toStringAsFixed(0)}',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                        ],
                      ),
                      ElevatedButton(
                        onPressed: () {
                          // Checkout action
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const CheckoutPage(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 40,
                            vertical: 16,
                          ),
                        ),
                        child: const Text(
                          'Checkout',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

```

# Dokumentasi Hasil Modifikasi 

<img width="954" height="914" alt="{CFFC9FAC-15BC-4D22-88B2-B8B3F4A6EA10}" src="https://github.com/user-attachments/assets/7206bc60-b141-476e-8dd1-67af572dd087" />


<img width="958" height="911" alt="{96209762-F02B-46E8-8687-1DF7E0315853}" src="https://github.com/user-attachments/assets/d056058c-ae81-4347-91fd-bded3f366520" />


<img width="957" height="916" alt="{92FE857D-3840-4A63-950D-B6FB73CA48CC}" src="https://github.com/user-attachments/assets/7e3874e5-4a99-419a-96a0-179e4371b908" />


<img width="957" height="916" alt="{8F42696C-E174-4089-AAC5-9FDF2636CAB0}" src="https://github.com/user-attachments/assets/f855c914-1468-4c30-bfc0-7d07bf468744" />


<img width="956" height="915" alt="{C0ECEEE2-AE92-4E55-8F72-0B075B2F38B0}" src="https://github.com/user-attachments/assets/db4d6618-8a93-4df5-93b8-47b1af0b44fb" />
