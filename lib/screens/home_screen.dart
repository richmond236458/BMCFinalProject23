import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:todo_firebase_app/screens/admin_panel_screen.dart';
import 'package:todo_firebase_app/screens/product_detail_screen.dart';
import 'package:todo_firebase_app/providers/cart_provider.dart';
import 'package:todo_firebase_app/screens/cart_screen.dart';
import 'package:provider/provider.dart';
import 'package:todo_firebase_app/screens/order_history_screen.dart';
import 'package:todo_firebase_app/screens/profile_screen.dart';
import 'package:todo_firebase_app/widgets/notifications_icon.dart';
import 'package:todo_firebase_app/screens/chat_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String _userRole = 'user';
  final User? _currentUser = FirebaseAuth.instance.currentUser;
  String searchQuery = '';
  String selectedCategory = 'All';

  @override
  void initState() {
    super.initState();
    _fetchUserRole();
  }

  Future<void> _fetchUserRole() async {
    if (_currentUser == null) return;
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(_currentUser!.uid)
          .get();
      if (doc.exists && doc.data() != null) {
        setState(() {
          _userRole = doc.data()!['role'];
        });
      }
    } catch (e) {
      debugPrint("Error fetching user role: $e");
    }
  }

  Future<Map<String, dynamic>> _fetchProductRatings(String productId) async {
    try {
      final ratingsSnapshot = await _firestore
          .collection('products')
          .doc(productId)
          .collection('ratings')
          .get();

      if (ratingsSnapshot.docs.isEmpty) {
        return {'avgRating': 0.0, 'totalRatings': 0};
      }

      double totalRating = 0.0;
      int count = ratingsSnapshot.docs.length;

      for (var doc in ratingsSnapshot.docs) {
        totalRating += (doc['rating'] as num).toDouble();
      }

      double avgRating = totalRating / count;

      return {'avgRating': avgRating, 'totalRatings': count};
    } catch (e) {
      debugPrint("Error fetching ratings for product $productId: $e");
      return {'avgRating': 0.0, 'totalRatings': 0};
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color accent = Color(0xFFFC4800);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 3,
        shadowColor: Colors.grey.withOpacity(0.2),
        titleSpacing: 0,
        title: Row(
          children: [
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Richmond Store',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.black,
                  ),
                ),
                Text(
                  'Kitchen & Appliances',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
            const Spacer(),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  Consumer<CartProvider>(
                    builder: (context, cart, child) {
                      return Badge(
                        label: Text(cart.itemCount.toString()),
                        isLabelVisible: cart.itemCount > 0,
                        child: IconButton(
                          icon: const Icon(Icons.shopping_cart_outlined,
                              color: accent),
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                  builder: (_) => const CartScreen()),
                            );
                          },
                        ),
                      );
                    },
                  ),
                  const NotificationIcon(),
                  IconButton(
                    icon:
                    const Icon(Icons.receipt_long_outlined, color: accent),
                    tooltip: 'My Orders',
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (_) => const OrderHistoryScreen()),
                      );
                    },
                  ),
                  if (_userRole == 'admin')
                    IconButton(
                      icon: const Icon(Icons.admin_panel_settings_outlined,
                          color: accent),
                      tooltip: 'Admin Panel',
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (_) => const AdminPanelScreen()),
                        );
                      },
                    ),
                  IconButton(
                    icon: const Icon(Icons.person_outline, color: accent),
                    tooltip: 'Profile',
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (_) => const ProfileScreen()),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(width: 4),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // 🔍 Search bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.15),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    )
                  ],
                ),
                child: TextField(
                  decoration: const InputDecoration(
                    hintText: 'Search products...',
                    prefixIcon: Icon(Icons.search, color: accent),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(12),
                  ),
                  onChanged: (value) =>
                      setState(() => searchQuery = value.toLowerCase()),
                ),
              ),
            ),

            // 🏷️ Category chips
            SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                children: ['Home', 'Kitchenware', 'Appliances', 'Sales']
                    .map((category) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: ChoiceChip(
                    label: Text(
                      category,
                      style: TextStyle(
                        fontSize: 12,

                        color: selectedCategory == category
                            ? Colors.white
                            : Colors.grey[700],
                      ),
                    ),
                    selected: selectedCategory == category,
                    onSelected: (_) =>
                        setState(() => selectedCategory = category),
                    selectedColor: accent,
                    backgroundColor: Colors.grey.shade200,
                    padding:
                    const EdgeInsets.symmetric(horizontal: 8),
                  ),
                ))
                    .toList(),
              ),
            ),
            const SizedBox(height: 6),

            // 🛍️ Product grid with ratings
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('products')
                    .orderBy('createdAt', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(
                        child: Text('Error: ${snapshot.error}',
                            style: const TextStyle(color: Colors.red)));
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(
                      child: Text('No products found.',
                          style: TextStyle(color: Colors.black54)),
                    );
                  }

                  final products = snapshot.data!.docs.where((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    final name = data['name']?.toString().toLowerCase() ?? '';
                    final category = data['category']?.toString() ?? 'Home';
                    final matchesSearch = name.contains(searchQuery);
                    final matchesCategory = selectedCategory == 'Home' ||
                        category == selectedCategory;
                    return matchesSearch && matchesCategory;
                  }).toList();

                  if (products.isEmpty) {
                    return const Center(
                      child: Text('No matching products found.',
                          style: TextStyle(color: Colors.black54)),
                    );
                  }

                  return GridView.builder(
                    padding: const EdgeInsets.all(10),
                    gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                      childAspectRatio: 2.8 / 4,
                    ),
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      final productDoc = products[index];
                      final productData =
                      productDoc.data() as Map<String, dynamic>;

                      return GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (_) => ProductDetailScreen(
                              productData: productData,
                              productID: productDoc.id,
                            ),
                          ));
                        },
                        child: Card(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          elevation: 3,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(12)),
                                  child: Image.network(
                                    productData['imageUrl'],
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, _) =>
                                    const Icon(Icons.broken_image,
                                        size: 80),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(productData['name'],
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis),
                                    const SizedBox(height: 4),
                                    Text(
                                      '₱${productData['price'].toStringAsFixed(2)}',
                                      style: const TextStyle(
                                          color: Colors.deepPurple,
                                          fontWeight: FontWeight.w600),
                                    ),
                                    const SizedBox(height: 4),
                                    FutureBuilder<Map<String, dynamic>>(
                                      future: _fetchProductRatings(productDoc.id),
                                      builder: (context, ratingSnapshot) {
                                        if (ratingSnapshot.connectionState == ConnectionState.waiting) {
                                          return const Row(
                                            children: [
                                              Icon(Icons.star_border, color: Colors.amber, size: 14),
                                              SizedBox(width: 4),
                                              Text('Loading...', style: TextStyle(fontSize: 12)),
                                            ],
                                          );
                                        }
                                        if (ratingSnapshot.hasError || !ratingSnapshot.hasData) {
                                          return const Row(
                                            children: [
                                              Icon(Icons.star_border, color: Colors.amber, size: 14),
                                              SizedBox(width: 4),
                                              Text('0.0 (0)', style: TextStyle(fontSize: 12)),
                                            ],
                                          );
                                        }

                                        final ratingsData = ratingSnapshot.data!;
                                        final double avgRating = ratingsData['avgRating'];
                                        final int totalRatings = ratingsData['totalRatings'];

                                        return Row(
                                          children: [
                                            ...List.generate(
                                              5,
                                                  (i) => Icon(
                                                i < avgRating.round()
                                                    ? Icons.star
                                                    : Icons.star_border,
                                                color: Colors.amber,
                                                size: 14,
                                              ),
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              avgRating.toStringAsFixed(1),
                                              style: const TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            Text(
                                              ' ($totalRatings)',
                                              style: const TextStyle(
                                                  fontSize: 11,
                                                  color: Colors.black54),
                                            ),
                                          ],
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),

      floatingActionButton: _userRole == 'user'
          ? StreamBuilder<DocumentSnapshot>(
        stream: _firestore
            .collection('chats')
            .doc(_currentUser!.uid)
            .snapshots(),
        builder: (context, snapshot) {
          int unreadCount = 0;
          if (snapshot.hasData && snapshot.data!.exists) {
            final data = snapshot.data!.data();
            if (data != null) {
              unreadCount =
                  (data as Map<String, dynamic>)['unreadByUserCount'] ??
                      0;
            }
          }
          return Badge(
            label: Text('$unreadCount'),
            isLabelVisible: unreadCount > 0,
            child: FloatingActionButton.extended(
              backgroundColor: accent,
              icon: const Icon(Icons.support_agent),
              label: const Text('Contact Admin'),
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) =>
                      ChatScreen(chatRoomId: _currentUser!.uid),
                ));
              },
            ),
          );
        },
      )
          : null,
    );
  }
}