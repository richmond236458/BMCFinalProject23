import 'package:flutter/material.dart';


class ProductCard extends StatelessWidget {

  final String productName;

  final double price;

  final String imageUrl;

  final VoidCallback onTap;


  const ProductCard({

    super.key,

    required this.productName,

    required this.price,

    required this.imageUrl,

    required this.onTap,

  });


  @override

  Widget build(BuildContext context) {

    return GestureDetector(

      onTap: onTap,

      child: Card(

        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),

        elevation: 3,

        child: Column(

          crossAxisAlignment: CrossAxisAlignment.start,

          children: [

            Expanded(

              child: ClipRRect(

                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),

                child: Image.network(

                  imageUrl,

                  fit: BoxFit.cover,

                  width: double.infinity,

                  errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image),

                ),

              ),

            ),

            Padding(

              padding: const EdgeInsets.all(8.0),

              child: Column(

                crossAxisAlignment: CrossAxisAlignment.start,

                children: [

                  Text(

                    productName,

                    style: const TextStyle(fontWeight: FontWeight.bold),

                    maxLines: 1,

                    overflow: TextOverflow.ellipsis,

                  ),

                  const SizedBox(height: 4),

                  Text(

                    '₱${price.toStringAsFixed(2)}',

                    style: const TextStyle(color: Colors.green),

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