import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo_firebase_app/providers/cart_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProductDetailScreen extends StatefulWidget {
  final Map<String, dynamic> productData;
  final String productID;

  const ProductDetailScreen({
    super.key,
    required this.productData,
    required this.productID,
  });

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _quantity = 1;
  double _userRating = 0.0;
  String _userReview = '';
  final TextEditingController _reviewController = TextEditingController();
  bool _isSubmitting = false;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _loadUserRating();
  }

  User? get _currentUser => FirebaseAuth.instance.currentUser;

  Future<void> _loadUserRating() async {
    if (_currentUser == null) return;
    try {
      final doc = await _firestore
          .collection('products')
          .doc(widget.productID)
          .collection('ratings')
          .doc(_currentUser!.uid)
          .get();
      if (doc.exists) {
        setState(() {
          _userRating = (doc['rating'] as num).toDouble();
          _userReview = doc['review'] ?? '';
          _reviewController.text = _userReview;
        });
      }
    } catch (e) {
      debugPrint("Error loading user rating: $e");
    }
  }

  Future<void> _submitRating(double rating, String review) async {
    final user = _currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You must log in to submit a review.')),
      );
      return;
    }

    if (rating == 0.0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a rating before submitting.')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      String userName = 'Anonymous';
      try {
        final userDoc = await _firestore.collection('users').doc(user.uid).get();
        if (userDoc.exists) {
          userName = userDoc['name'] ?? 'Anonymous';
        }
      } catch (e) {
        debugPrint("Error fetching user name: $e");
      }

      await _firestore
          .collection('products')
          .doc(widget.productID)
          .collection('ratings')
          .doc(user.uid)
          .set({
        'rating': rating,
        'review': review,
        'userName': userName,
        'timestamp': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      setState(() {
        _userRating = rating;
        _userReview = review;
        _reviewController.text = review;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Review submitted successfully!')),
      );
    } catch (e) {
      debugPrint("Error submitting rating: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to submit review: $e')),
      );
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  void _incrementQuantity() => setState(() => _quantity++);
  void _decrementQuantity() {
    if (_quantity > 1) setState(() => _quantity--);
  }

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context, listen: false);
    final data = widget.productData;
    final String name = data['name'];
    final String description = data['description'];
    final String imageUrl = data['imageUrl'];
    final double price = data['price'];

    return Scaffold(
      appBar: AppBar(title: Text(name)),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Image.network(
              imageUrl,
              height: 300,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, progress) =>
              progress == null ? child : const SizedBox(height: 300, child: Center(child: CircularProgressIndicator())),
              errorBuilder: (context, error, _) => const SizedBox(height: 300, child: Center(child: Icon(Icons.broken_image, size: 100))),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text('₱${price.toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w600, color: Colors.deepPurple)),
                  const SizedBox(height: 16),
                  const Divider(thickness: 1),
                  const SizedBox(height: 16),
                  Text('About this item', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 8),
                  Text(description, style: const TextStyle(fontSize: 16, height: 1.5)),
                  const SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton.filledTonal(icon: const Icon(Icons.remove), onPressed: _decrementQuantity),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Text('$_quantity', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                      ),
                      IconButton.filled(icon: const Icon(Icons.add), onPressed: _incrementQuantity),
                    ],
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: () {
                      cart.addItem(widget.productID, name, price, _quantity);
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text('Added $_quantity x $name to cart!'),
                        duration: const Duration(seconds: 2),
                      ));
                    },
                    icon: const Icon(Icons.shopping_cart_outlined),
                    label: const Text('Add to Cart'),
                    style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16), textStyle: const TextStyle(fontSize: 18)),
                  ),
                  const SizedBox(height: 40),
                  Text('Rate this product', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      5,
                          (index) => IconButton(
                        icon: Icon(index < _userRating ? Icons.star : Icons.star_border, color: Colors.amber, size: 32),
                        onPressed: () => setState(() => _userRating = index + 1.0),
                      ),
                    ),
                  ),
                  TextField(
                    controller: _reviewController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      hintText: 'Write your review...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: (_currentUser == null || _userRating == 0.0 || _isSubmitting) ? null : () => _submitRating(_userRating, _reviewController.text.trim()),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple),
                    child: _isSubmitting ? const CircularProgressIndicator(color: Colors.white) : Text(
                        _currentUser == null ? 'Login to Review' : _userRating == 0.0 ? 'Select Rating' : 'Submit Review'
                    ),
                  ),
                  const SizedBox(height: 30),
                  const Divider(thickness: 1),
                  const SizedBox(height: 10),
                  Text('Customer Reviews', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 10),
                  StreamBuilder<QuerySnapshot>(
                    stream: _firestore
                        .collection('products')
                        .doc(widget.productID)
                        .collection('ratings')
                        .orderBy('timestamp', descending: true)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text('No reviews yet'),
                        );
                      }

                      final reviews = snapshot.data!.docs;
                      double totalRating = 0;
                      for (var doc in reviews) {
                        totalRating += (doc['rating'] as num).toDouble();
                      }
                      final avgRating = reviews.isNotEmpty ? totalRating / reviews.length : 0.0;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              ...List.generate(
                                5,
                                    (index) => Icon(index < avgRating.round() ? Icons.star : Icons.star_border, color: Colors.amber, size: 22),
                              ),
                              const SizedBox(width: 6),
                              Text(avgRating.toStringAsFixed(1), style: const TextStyle(fontWeight: FontWeight.bold)),
                              Text(' (${reviews.length} reviews)', style: const TextStyle(color: Colors.black54)),
                            ],
                          ),
                          const SizedBox(height: 16),
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: reviews.length,
                            itemBuilder: (context, index) {
                              final review = reviews[index].data() as Map<String, dynamic>;
                              final userName = review['userName'] ?? 'User';
                              final rating = (review['rating'] as num?)?.toDouble() ?? 0.0;
                              final comment = review['review'] ?? '';
                              final timestamp = review['timestamp'] as Timestamp?;
                              final date = timestamp != null
                                  ? DateTime.fromMillisecondsSinceEpoch(timestamp.millisecondsSinceEpoch)
                                  : null;

                              return Card(
                                margin: const EdgeInsets.symmetric(vertical: 6),
                                child: ListTile(
                                  title: Text(userName, style: const TextStyle(fontWeight: FontWeight.bold)),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: List.generate(
                                          5,
                                              (i) => Icon(i < rating ? Icons.star : Icons.star_border, color: Colors.amber, size: 18),
                                        ),
                                      ),
                                      if (comment.isNotEmpty)
                                        Padding(padding: const EdgeInsets.only(top: 4.0), child: Text(comment)),
                                      if (date != null)
                                        Padding(
                                          padding: const EdgeInsets.only(top: 2.0),
                                          child: Text('${date.year}-${date.month}-${date.day}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                                        ),
                                    ],
                                  ),
                                ),
                              );
                            },
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
  }
}