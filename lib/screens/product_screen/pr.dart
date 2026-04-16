import 'package:comercial_app/providers/cart_provider.dart';
import 'package:comercial_app/screens/order_screen/orderpayment.dart';
import 'package:comercial_app/theme/Textstyles.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Product extends StatefulWidget {
  final Map<String, dynamic> product;
  final VoidCallback? onGoToCart;

  const Product({super.key, required this.product, required this.onGoToCart});

  @override
  State<Product> createState() => _ProductState();
}

class _ProductState extends State<Product> with SingleTickerProviderStateMixin {
  String? selectedSize;
  Color selectedColor = Colors.black;
  int quantity = 1;
  bool iscart = false;

  // 🔥 Animation
  late AnimationController controller;
  late Animation<double> xAnimation;
  late Animation<double> yAnimation;
  late Animation<double> scaleAnimation;

  bool showFlyingImage = false;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 800),
    );

    xAnimation = Tween(begin: 150.0, end: 320.0).animate(controller);

    yAnimation = Tween(
      begin: 300.0,
      end: 60.0,
    ).animate(CurvedAnimation(parent: controller, curve: Curves.easeInOut));

    scaleAnimation = Tween(begin: 1.0, end: 0.2).animate(controller);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void startAddToCartAnimation() {
    setState(() {
      showFlyingImage = true;
    });

    controller.forward(from: 0).whenComplete(() {
      setState(() {
        showFlyingImage = false;
        iscart = true;
      });

      // 🔥 Add to cart AFTER animation
      context.read<CartProvider>().addToCart({
        ...widget.product,
        'quantity': quantity,
        'size': selectedSize,
        'color': selectedColor.value,
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Added to cart!')));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.product['name'] ?? ''),
        backgroundColor: const Color(0xFFC19375),
        foregroundColor: Colors.white,
        actions: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Icon(Icons.shopping_cart, size: 30),
          ),
        ],
      ),

      backgroundColor: Colors.white,

      // 🔥 STACK ADDED
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 🔥 PRODUCT IMAGE
                        Container(
                          height: 340,
                          margin: const EdgeInsets.only(top: 10, bottom: 20),
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(255, 240, 240, 240),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Hero(
                              tag: widget.product['image'],
                              child: Image.network(
                                widget.product['image'],
                                fit: BoxFit.cover,
                                width: double.infinity,
                              ),
                            ),
                          ),
                        ),

                        // NAME + PRICE
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              widget.product['name'] ?? '',
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              widget.product['price'] ?? '',
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 10),

                        // QUANTITY
                        Row(
                          children: [
                            Text(
                              'Qty',
                              style: AppTextStyles.semiBold.copyWith(
                                fontSize: 20,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Row(
                              children: [
                                IconButton(
                                  onPressed: () {
                                    if (quantity > 1)
                                      setState(() => quantity--);
                                  },
                                  icon: Icon(Icons.remove),
                                ),
                                Text(quantity.toString()),
                                IconButton(
                                  onPressed: () {
                                    setState(() => quantity++);
                                  },
                                  icon: Icon(Icons.add),
                                ),
                              ],
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // SIZE
                        const Text(
                          'Select Size',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Row(
                          children: ['S', 'M', 'L', 'XL']
                              .map(
                                (size) => GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      selectedSize = size;
                                    });
                                  },
                                  child: Container(
                                    margin: EdgeInsets.all(5),
                                    padding: EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: selectedSize == size
                                            ? Colors.red
                                            : Colors.grey,
                                      ),
                                    ),
                                    child: Text(size),
                                  ),
                                ),
                              )
                              .toList(),
                        ),

                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 🔥 FLYING IMAGE
          if (showFlyingImage)
            AnimatedBuilder(
              animation: controller,
              builder: (context, child) {
                return Positioned(
                  left: xAnimation.value,
                  top: yAnimation.value,
                  child: Transform.scale(
                    scale: scaleAnimation.value,
                    child: child,
                  ),
                );
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  widget.product['image'],
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                ),
              ),
            ),
        ],
      ),

      // 🔥 BOTTOM BUTTONS
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  if (selectedSize == null) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text("Select size")));
                    return;
                  }

                  if (!iscart) {
                    startAddToCartAnimation();
                  } else {
                    widget.onGoToCart?.call();
                    Navigator.pop(context);
                  }
                },
                child: Text(iscart ? "Go to Cart" : "Add to Cart"),
              ),
            ),
            SizedBox(width: 10),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          OrderPaymentPage(total: widget.product['price']),
                    ),
                  );
                },
                child: Text("Buy Now"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
