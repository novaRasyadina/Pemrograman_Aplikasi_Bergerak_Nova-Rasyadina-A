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