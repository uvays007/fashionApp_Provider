import 'package:comercial_app/screens/global_screen/global.dart';
import 'package:comercial_app/screens/product_screen/product.dart';
import 'package:comercial_app/theme/Textstyles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class Allproducts extends StatelessWidget {
  final VoidCallback? goToCart;
  const Allproducts({super.key, required this.goToCart});

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
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 20.h),
        child: Column(
          children: [
            SizedBox(height: 15.h),
            Expanded(
              child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: offlineproducts.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10.w,
                  mainAxisSpacing: 10.h,
                  childAspectRatio: 0.7,
                ),
                itemBuilder: (context, index) {
                  final product = offlineproducts[index];
                  return Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15.r),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(15.r),
                              child: GestureDetector(
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => Product(
                                      product: product,
                                      onGoToCart: goToCart,
                                    ),
                                  ),
                                ),
                                child: Container(
                                  height: 205.h,
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade300,
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  child: Image.asset(
                                    product['image']!,
                                    height: 180.h,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              product['brandname']!,
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w600,
                                fontSize: 14.sp,
                              ),
                            ),
                            Text(
                              product['name']!,
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w600,
                                fontSize: 13.sp,
                              ),
                            ),
                            Text(
                              product['price']!,
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
      ),
    );
  }
}
