import 'package:comercial_app/providers/home_provider.dart';
import 'package:comercial_app/screens/product_screen/product.dart';
import 'package:comercial_app/theme/Textstyles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class Allproducts extends StatefulWidget {
  final VoidCallback? goToCart;

  const Allproducts({super.key, required this.goToCart});

  @override
  State<Allproducts> createState() => _AllproductsState();
}

class _AllproductsState extends State<Allproducts> {
  @override
  void initState() {
    super.initState();

    // 🔥 Fetch products when screen loads
    Future.microtask(() {
      Provider.of<HomeProvider>(context, listen: false).loadProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "All Products",
          style: AppTextStyles.semiBold.copyWith(color: Colors.white),
        ),
        backgroundColor: const Color(0xFFC19375),
        foregroundColor: Colors.white,
      ),

      body: Consumer<HomeProvider>(
        builder: (context, productsprovider, _) {
          // ✅ 1. LOADING STATE
          if (productsprovider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          // ✅ 2. EMPTY STATE
          if (productsprovider.products.isEmpty) {
            return const Center(
              child: Text("No products found", style: TextStyle(fontSize: 16)),
            );
          }

          // ✅ 3. DATA UI
          return Container(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Column(
              children: [
                SizedBox(height: 15.h),

                Expanded(
                  child: GridView.builder(
                    physics: const BouncingScrollPhysics(), // ✅ scroll fixed
                    itemCount: productsprovider.products.length,

                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 10.w,
                      mainAxisSpacing: 10.h,
                      childAspectRatio: 0.7,
                    ),

                    itemBuilder: (context, index) {
                      final product = productsprovider.products[index];

                      return Stack(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15.r),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                // 🔥 IMAGE
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(15.r),
                                  child: GestureDetector(
                                    onTap: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => Product(
                                          product: product,
                                          onGoToCart: widget.goToCart,
                                        ),
                                      ),
                                    ),
                                    child: Container(
                                      height: 205.h,
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade300,
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                      child: Image.network(
                                        product['image'] ?? '',
                                        height: 180.h,
                                        width: double.infinity,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                ),

                                SizedBox(height: 4.h),

                                // 🔥 BRAND
                                Text(
                                  product['brandname'] ?? '',
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14.sp,
                                  ),
                                ),

                                // 🔥 NAME
                                Text(
                                  product['name'] ?? '',
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13.sp,
                                  ),
                                ),

                                // 🔥 PRICE
                                Text(
                                  product['price'] ?? '',
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.w500,
                                    color: Colors.grey[700],
                                    fontSize: 13.sp,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
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
