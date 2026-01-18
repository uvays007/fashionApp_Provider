import 'package:comercial_app/providers/cart_provider.dart';
import 'package:comercial_app/screens/order_screen/orderpayment.dart';
import 'package:comercial_app/theme/Textstyles.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Cart extends StatefulWidget {
  const Cart({super.key});

  @override
  State<Cart> createState() => _CartState();
}

class _CartState extends State<Cart> {


  double calculateTotal(List<Map<String, dynamic>> carts) {
    double sum = 0;

    for (var cart in carts) {
      final priceString = cart['price'].toString().replaceAll(
        RegExp(r'[^0-9.]'),
        '',
      );

      double price = double.tryParse(priceString) ?? 0;
      int qty = cart['qty'] ?? 1;

      sum += price * qty;
    }
    return sum;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CartProvider>(builder: (context, cartProvider, _) {
     return Scaffold(
        backgroundColor: const Color(0xFFF8F6F3),
      
        body: StreamBuilder<List<Map<String, dynamic>>>(
          stream: cartProvider.cartStream(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
      
            final carts = snapshot.data!;
            final totalPrice = calculateTotal(carts);
      
            if (carts.isEmpty) {
              return const Center(
                child: Text(
                  "Your Cart is Empty",
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              );
            }
      
            return SafeArea(
              child: Column(
                children: [
                  Expanded(
                    child: ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: carts.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final cart = carts[index];
      
                        final priceString = cart['price'].toString().replaceAll(
                          RegExp(r'[^0-9.]'),
                          '',
                        );
      
                        double basePrice = double.tryParse(priceString) ?? 0;
                        int qty = cart['qty'] ?? 1;
      
                        double itemTotal = basePrice * qty;
      
                        return Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.network(
                                  cart['image'],
                                  width: 90,
                                  height: 90,
                                  fit: BoxFit.cover,
                                ),
                              ),
      
                              const SizedBox(width: 12),
      
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      cart['brandname'],
                                      style: AppTextStyles.bold.copyWith(
                                        fontSize: 15,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      cart['name'],
                                      style: AppTextStyles.medium.copyWith(
                                        color: Colors.grey[700],
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
      
                                    const SizedBox(height: 10),
      
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: Colors.grey.shade300,
                                        ),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          InkWell(
                                            onTap: () {
                                              if (qty > 1) {
                                                cartslist.addToCart({
                                                  ...cart,
                                                  "qty": qty - 1,
                                                });
                                              }
                                            },
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
                                            child: Container(
                                              padding: const EdgeInsets.all(6),
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: Colors.grey.shade200,
                                              ),
                                              child: const Icon(
                                                Icons.remove,
                                                size: 13,
                                              ),
                                            ),
                                          ),
      
                                          const SizedBox(width: 12),
      
                                          Text(
                                            "$qty",
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
      
                                          const SizedBox(width: 12),
      
                                          InkWell(
                                            onTap: () {
                                              cartslist.addToCart({
                                                ...cart,
                                                "qty": qty + 1,
                                              });
                                            },
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
                                            child: Container(
                                              padding: const EdgeInsets.all(6),
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: Colors.grey.shade200,
                                              ),
                                              child: const Icon(
                                                Icons.add,
                                                size: 13,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
      
                              const SizedBox(width: 10),
      
                              Column(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Rs.${itemTotal.toStringAsFixed(2)}",
                                    style: AppTextStyles.bold.copyWith(
                                      fontSize: 16,
                                    ),
                                  ),
                                  SizedBox(height: 40),
      
                                  InkWell(
                                    onTap: () =>
                                        cartslist.removeFromCart(cart['id']),
                                    borderRadius: BorderRadius.circular(8),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade200,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Row(
                                        children: [
                                          Text(
                                            "Remove",
                                            style: AppTextStyles.semiBold,
                                          ),
                                          SizedBox(width: 4),
                                          Icon(
                                            Icons.delete,
                                            color: Colors.red,
                                            size: 20,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
      
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.06),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          _totalRow(
                            "Subtotal",
                            "Rs.${totalPrice.toStringAsFixed(2)}",
                          ),
                          const SizedBox(height: 6),
                          _totalRow("Shipping", "Free", valueColor: Colors.green),
                          const Divider(height: 25),
                          _totalRow(
                            "Total",
                            "Rs.${totalPrice.toStringAsFixed(2)}",
                            isBold: true,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      
        bottomNavigationBar: StreamBuilder<List<Map<String, dynamic>>>(
          stream: cartslist.getCartlist(),
          builder: (context, snapshot) {
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const SizedBox();
            }
      
            final totalPrice = calculateTotal(snapshot.data!);
      
            return Container(
              padding: const EdgeInsets.all(18),
              decoration: const BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 8,
                    offset: Offset(0, -3),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFC19375),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => OrderPaymentPage(
                              total: totalPrice.toStringAsFixed(2),
                            ),
                          ),
                        );
                      },
                      child: const Text(
                        "Place Order",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
      
    },
      
    );
  }

  Widget _totalRow(
    String title,
    String value, {
    bool isBold = false,
    Color? valueColor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: isBold ? 17 : 15,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isBold ? 17 : 15,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
            color: valueColor,
          ),
        ),
      ],
    );
  }
}
