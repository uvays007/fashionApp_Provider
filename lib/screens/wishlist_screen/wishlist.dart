import 'package:comercial_app/providers/cart_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:comercial_app/providers/wishlist_provider.dart';

class WishlistPage extends StatelessWidget {
  const WishlistPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Wishlist',
          style: TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFFC19375),
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),

      body: Consumer<WishlistProvider>(
        builder: (context, wishlistProvider, _) {
          return StreamBuilder<List<Map<String, dynamic>>>(
            stream: wishlistProvider.wishlistStream(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 60,
                        color: Colors.red,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "Error: ${snapshot.error}",
                        style: const TextStyle(fontSize: 14, color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              }

              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.favorite_border, size: 60, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        "Your wishlist is empty",
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ],
                  ),
                );
              }

              final wishlistItems = snapshot.data!;

              return ListView.builder(
                padding: const EdgeInsets.all(20),
                itemCount: wishlistItems.length,
                itemBuilder: (context, index) {
                  final product = wishlistItems[index];

                  final productId = product['id']?.toString() ?? '';
                  final productName =
                      product['name']?.toString() ?? 'Unknown Product';
                  final productPrice = product['price']?.toString() ?? 'N/A';
                  final imageUrl = product['image']?.toString() ?? '';
                  final brandName = product['brandname']?.toString() ?? '';

                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF6F6F6),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        Container(
                          height: 80,
                          width: 80,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: imageUrl.isNotEmpty
                                ? Image.network(
                                    imageUrl,
                                    fit: BoxFit.cover,
                                    loadingBuilder:
                                        (context, child, loadingProgress) {
                                          if (loadingProgress == null) {
                                            return child;
                                          }
                                          return Center(
                                            child: CircularProgressIndicator(
                                              value:
                                                  loadingProgress
                                                          .expectedTotalBytes !=
                                                      null
                                                  ? loadingProgress
                                                            .cumulativeBytesLoaded /
                                                        loadingProgress
                                                            .expectedTotalBytes!
                                                  : null,
                                            ),
                                          );
                                        },
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        color: Colors.grey[200],
                                        child: const Center(
                                          child: Icon(
                                            Icons.broken_image,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      );
                                    },
                                  )
                                : Container(
                                    color: Colors.grey[200],
                                    child: const Center(
                                      child: Icon(
                                        Icons.image,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ),
                          ),
                        ),

                        const SizedBox(width: 12),

                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (brandName.isNotEmpty)
                                Text(
                                  brandName,
                                  style: const TextStyle(
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15,
                                  ),
                                ),
                              Text(
                                productName,
                                style: const TextStyle(
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                productPrice,
                                style: const TextStyle(
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFFC19375),
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 8),

                              Row(
                                children: [
                                  SizedBox(
                                    height: 36,
                                    child: ElevatedButton(
                                      onPressed: () {
                                        try {
                                          context
                                              .read<CartProvider>()
                                              .addToCart(product);
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                "$productName added to cart",
                                              ),
                                              behavior:
                                                  SnackBarBehavior.floating,
                                              backgroundColor: const Color(
                                                0xFFC19375,
                                              ),
                                            ),
                                          );
                                        } catch (e) {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                "Failed to add to cart: $e",
                                              ),
                                              behavior:
                                                  SnackBarBehavior.floating,
                                              backgroundColor: Color(
                                                0xFFC19375,
                                              ),
                                            ),
                                          );
                                        }
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(
                                          0xFFC19375,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                      ),
                                      child: const Text(
                                        "Add to Cart",
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                  ),

                                  const SizedBox(width: 8),

                                  SizedBox(
                                    height: 50,
                                    width: 90,
                                    child: IconButton(
                                      color: Colors.red,
                                      icon: Icon(Icons.delete),
                                      onPressed: () {
                                        if (productId.isNotEmpty) {
                                          context
                                              .read<WishlistProvider>()
                                              .removeFromWishlist(productId);

                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                "Removed $productName from wishlist",
                                              ),
                                              behavior:
                                                  SnackBarBehavior.floating,
                                              backgroundColor: Color(
                                                0xFFC19375,
                                              ),
                                            ),
                                          );
                                        }
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
