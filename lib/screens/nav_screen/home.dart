import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:comercial_app/providers/wishList_provider.dart';
import 'package:comercial_app/screens/AllProducts_screen/allproducts.dart';
import 'package:comercial_app/screens/global_screen/global.dart';
import 'package:comercial_app/screens/product_screen/product.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

final List<String> categories = [
  'assets/images/full-length-portrait-businessman-isolated-gray-wall.jpg',
  'assets/images/high-fashion-look-glamor-stylish-sexy-beautiful-young-woman-model-summer-black-hipster-dress.jpg',
  'assets/images/full-shot-modern-boy-posing-with-sunglasses.jpg',
  'assets/images/little-fashionista-with-shopping-bag-summer-hat-glasses-colored-pink-background-mom-s-shoes-concept-children-s-fashion.jpg',
];

final List<Map<String, dynamic>> banners = [
  {
    "Text1": "Womens Day",
    "Text2": "Up to 50% off",
    "image":
        "assets/images/carousel_banner/attractive-redhead-girl-sweater-smiling-staring-camera-standing-confident-against-blue-bac-min.jpg",
  },
  {
    "Text1": "Mens Day",
    "Text2": "Up to 80% off",
    "image":
        "assets/images/carousel_banner/handsome-smiling-adult-man-casual-outfit-smiling-looking-left-promo-offer-standing-against-min.jpg",
    "alignment": Alignment(0, -0.5),
  },
  {
    "Text1": "Kids Day",
    "Text2": "Up to 30% off",
    "image":
        "assets/images/carousel_banner/young-smiley-girl-portrait-pointing (1).jpg",
  },
];

int activeIndex = 0;
final CarouselSliderController controller = CarouselSliderController();
final searchController = TextEditingController();
List<Map<String, dynamic>> filteredproducts = [];
List<Map<String, dynamic>> products = [];

class Home extends StatefulWidget {
  final VoidCallback? goToCart;
  const Home({super.key, required this.goToCart});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  void initState() {
    super.initState();
    loadProducts();
    filteredproducts = List.from(products);
  }

  Future<void> loadProducts() async {
    final wishlistProvider = context.read<WishlistProvider>();

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection("products")
          .get();

      final fetchedProducts = snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();

      if (!mounted) return;

      setState(() {
        filteredproducts = fetchedProducts;
      });

      for (var product in fetchedProducts) {
        wishlistProvider.loadLikeStatus(product['id']);
      }
    } catch (e) {
      debugPrint("Error loading products: $e");
    }
  }

  void search() {
    final query = searchController.text.toLowerCase();

    if (query.isEmpty) {
      setState(() {
        filteredproducts = List.from(filteredproducts);
      });
      return;
    }

    final matches = offlineproducts
        .where((item) => item['brandname']!.toLowerCase().contains(query))
        .toList();
    final nonmatches = offlineproducts
        .where((item) => !item['brandname']!.toLowerCase().contains(query))
        .toList();

    setState(() {
      filteredproducts = [...matches, ...nonmatches];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 20.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 7.h),

              Container(
                height: 45.h,
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F3F4),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: TextFormField(
                  onChanged: (_) => search(),
                  controller: searchController,
                  decoration: InputDecoration(
                    suffixIcon: GestureDetector(
                      onTap: search,
                      child: Icon(Icons.search),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 20.h,
                      vertical: 10.h,
                    ),
                    border: InputBorder.none,
                    hintText: 'Search Products',

                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12.r)),
                      borderSide: const BorderSide(
                        color: Color(0xFFC19375),
                        width: 2,
                      ),
                    ),
                  ),
                ),
              ),

              SizedBox(height: 10.h),
              Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(25.r),
                    child: CarouselSlider.builder(
                      carouselController: controller,
                      itemCount: banners.length,
                      options: CarouselOptions(
                        height: 150.h,
                        autoPlay: true,
                        viewportFraction: 0.99,
                        autoPlayCurve: Curves.fastEaseInToSlowEaseOut,
                        onPageChanged: (index, reason) =>
                            setState(() => activeIndex = index),
                      ),
                      itemBuilder: (context, index, _) {
                        final banner = banners[index];

                        return Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(255, 31, 151, 169),
                            image: DecorationImage(
                              alignment:
                                  banner["alignment"] ?? Alignment(0, -0.3),
                              image: AssetImage(banner["image"]!),
                              fit: BoxFit.cover,
                              colorFilter: ColorFilter.mode(
                                Colors.black.withOpacity(0.2),
                                BlendMode.darken,
                              ),
                            ),
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(16.w),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(height: 10.h),
                                Text(
                                  banner["Text1"]!,
                                  style: TextStyle(
                                    fontFamily: 'Jomolhari',
                                    color: Colors.white,
                                    fontSize: 21.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 8.h),
                                Text(
                                  banner["Text2"]!,
                                  style: TextStyle(
                                    fontFamily: 'Jomolhari',
                                    color: Colors.white,
                                    fontSize: 18.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  Positioned(
                    bottom: 10.h,
                    child: AnimatedSmoothIndicator(
                      activeIndex: activeIndex,
                      count: banners.length,
                      effect: ExpandingDotsEffect(
                        expansionFactor: 2.5,
                        dotHeight: 6.h,
                        dotWidth: 10.w,
                        activeDotColor: Colors.white,
                        dotColor: Colors.white.withOpacity(.5),
                        spacing: 5.w,
                      ),
                      onDotClicked: (index) => controller.animateToPage(index),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 12.h),

              Row(
                children: [
                  Text(
                    'Categories',
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'See all',
                    style: TextStyle(fontSize: 14.sp, fontFamily: 'Inter'),
                  ),
                  SizedBox(width: 5.w),
                  SvgPicture.asset(
                    'assets/icons/expand_circle_right_41dp_000000_FILL0_wght400_GRAD0_opsz40.svg',
                    height: 20.h,
                    width: 20.w,
                  ),
                ],
              ),

              SizedBox(height: 8.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  for (int i = 0; i < categories.length; i++)
                    Container(
                      height: 70.h,
                      width: 70.w,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(100.r),
                        border: Border.all(color: Colors.grey, width: 3.w),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(100.r),
                        child: Image.asset(
                          categories[i],
                          alignment: i > 1
                              ? const Alignment(0, -0.5)
                              : const Alignment(0, -1),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                ],
              ),

              SizedBox(height: 8.h),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Text(
                    'Men',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    'Women',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    'Boys',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    'Girls',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),

              SizedBox(height: 12.h),

              Row(
                children: [
                  Text(
                    'All Products',
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              Allproducts(goToCart: widget.goToCart),
                        ),
                      );
                    },
                    child: Text(
                      'See all',
                      style: TextStyle(fontSize: 14.sp, fontFamily: 'Inter'),
                    ),
                  ),
                  SizedBox(width: 5.w),
                  SvgPicture.asset(
                    'assets/icons/expand_circle_right_41dp_000000_FILL0_wght400_GRAD0_opsz40.svg',
                    height: 20.h,
                    width: 20.w,
                  ),
                ],
              ),

              SizedBox(height: 7.h),

              GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: filteredproducts.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10.w,
                  mainAxisSpacing: 10.h,
                  childAspectRatio: 0.7,
                ),
                itemBuilder: (context, index) {
                  final product = filteredproducts[index];

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
                                    product['image'] ??
                                        'https://via.placeholder.com/150',
                                    height: 180.h,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              product['brandname'] ?? 'brand',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w600,
                                fontSize: 14.sp,
                              ),
                            ),
                            Text(
                              product['name'] ?? 'name',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w600,
                                fontSize: 13.sp,
                              ),
                            ),
                            Text(
                              product['price'] ?? 'price',
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
                      Positioned(
                        right: 10,
                        top: 5,
                        child: Consumer<WishlistProvider>(
                          builder: (context, wishlist, _) {
                            final productId = product['id'];
                            final liked = wishlist.isLiked(productId);

                            return GestureDetector(
                              onTap: () async {
                                final wishlist = context
                                    .read<WishlistProvider>();

                                if (!liked) {
                                  final bool?
                                  confirm = await showModalBottomSheet<bool>(
                                    context: context,
                                    shape: const RoundedRectangleBorder(
                                      borderRadius: BorderRadius.vertical(
                                        top: Radius.circular(20),
                                      ),
                                    ),
                                    builder: (_) {
                                      return Padding(
                                        padding: const EdgeInsets.all(20),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Text(
                                              "Add to Wishlist?",
                                              style: TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(height: 10),
                                            const Text(
                                              "Do you really want to add this item to your wishlist?",
                                              textAlign: TextAlign.center,
                                            ),
                                            const SizedBox(height: 20),
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: OutlinedButton(
                                                    onPressed: () =>
                                                        Navigator.pop(
                                                          context,
                                                          false,
                                                        ),
                                                    child: const Text("Cancel"),
                                                  ),
                                                ),
                                                const SizedBox(width: 12),
                                                Expanded(
                                                  child: ElevatedButton(
                                                    onPressed: () =>
                                                        Navigator.pop(
                                                          context,
                                                          true,
                                                        ),
                                                    child: const Text("Yes"),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  );

                                  if (confirm == true) {
                                    await wishlist.toggleLike(product);
                                  }
                                } else {
                                  wishlist.toggleLike(product);
                                }
                              },
                              child: AnimatedSwitcher(
                                duration: const Duration(milliseconds: 300),
                                transitionBuilder: (child, animation) {
                                  return ScaleTransition(
                                    scale: CurvedAnimation(
                                      parent: animation,
                                      curve: Curves.elasticOut,
                                    ),
                                    child: child,
                                  );
                                },
                                child: Icon(
                                  liked
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                  key: ValueKey<bool>(liked),
                                  color: liked ? Colors.redAccent : null,
                                  size: liked ? 28 : 26,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
