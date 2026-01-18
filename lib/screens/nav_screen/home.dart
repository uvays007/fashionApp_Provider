import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:comercial_app/providers/wishlist_provider.dart';
import 'package:comercial_app/screens/AllProducts_screen/allproducts.dart';
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

class Home extends StatefulWidget {
  final VoidCallback? goToCart;
  const Home({super.key, required this.goToCart});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int activeIndex = 0;
  final CarouselSliderController controller = CarouselSliderController();
  final searchController = TextEditingController();
  List<Map<String, dynamic>> filteredproducts = [];
  List<Map<String, dynamic>> allProducts = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    print("Home screen initialized");

    // Test Firebase connection
    FirebaseFirestore.instance
        .collection("products")
        .limit(1)
        .get()
        .then((snapshot) {
          print("Firebase connection test successful");
          print("Collection exists: products");
          if (snapshot.docs.isNotEmpty) {
            print("Sample product data: ${snapshot.docs.first.data()}");
          }
        })
        .catchError((error) {
          print("Firebase connection error: $error");
        });

    loadProducts();
  }

  Future<void> loadProducts() async {
    if (!mounted) return;

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      print("Loading products from Firebase...");

      final snapshot = await FirebaseFirestore.instance
          .collection("products")
          .get();

      print("Firebase query successful. Got ${snapshot.docs.length} documents");

      final fetchedProducts = snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        print(
          "Product ${doc.id}: ${data['name'] ?? 'No name'} - ${data['image'] ?? 'No image'}",
        );
        return data;
      }).toList();

      if (!mounted) return;

      // Load wishlist status for each product
      final wishlistProvider = Provider.of<WishlistProvider>(
        context,
        listen: false,
      );
      for (var product in fetchedProducts) {
        final productId = product['id'];
        if (productId != null) {
          wishlistProvider.loadLikeStatus(productId.toString());
        }
      }

      setState(() {
        allProducts = fetchedProducts;
        filteredproducts = List.from(fetchedProducts);
        isLoading = false;
      });

      print("Successfully loaded ${fetchedProducts.length} products");
    } catch (e, stackTrace) {
      print("Error loading products: $e");
      print("Stack trace: $stackTrace");

      if (!mounted) return;

      setState(() {
        isLoading = false;
        errorMessage = "Failed to load products. Please check your connection.";
      });
    }
  }

  void search() {
    final query = searchController.text.trim().toLowerCase();

    if (query.isEmpty) {
      setState(() {
        filteredproducts = List.from(allProducts);
      });
      return;
    }

    final matches = allProducts.where((item) {
      final brandName = (item['brandname'] ?? '').toString().toLowerCase();
      final productName = (item['name'] ?? '').toString().toLowerCase();
      final category = (item['category'] ?? '').toString().toLowerCase();

      return brandName.contains(query) ||
          productName.contains(query) ||
          category.contains(query);
    }).toList();

    setState(() {
      filteredproducts = matches;
    });
  }

  Widget _buildProductImage(String imageUrl) {
    if (imageUrl.isEmpty) {
      return Container(
        color: Colors.grey[200],
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.image, color: Colors.grey, size: 40.h),
              SizedBox(height: 8.h),
              Text(
                "No Image",
                style: TextStyle(fontSize: 12.sp, color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    return Image.network(
      imageUrl,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Center(
          child: CircularProgressIndicator(
            value: loadingProgress.expectedTotalBytes != null
                ? loadingProgress.cumulativeBytesLoaded /
                      loadingProgress.expectedTotalBytes!
                : null,
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        print("Image loading error: $error for URL: $imageUrl");
        return Container(
          color: Colors.grey[200],
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.broken_image, color: Colors.grey, size: 40.h),
                SizedBox(height: 8.h),
                Text(
                  "Failed to load",
                  style: TextStyle(fontSize: 12.sp, color: Colors.grey),
                ),
              ],
            ),
          ),
        );
      },
    );
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

              // Search Bar
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
                      child: const Icon(Icons.search),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 20.w,
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

              // Carousel Banner
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
                                  banner["alignment"] ??
                                  const Alignment(0, -0.3),
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

              SizedBox(height: 20.h),

              // Categories Section
              Row(
                children: [
                  Text(
                    'Categories',
                    style: TextStyle(
                      fontSize: 16.sp,
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

              SizedBox(height: 12.h),

              // Categories Images
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  for (int i = 0; i < categories.length; i++)
                    Column(
                      children: [
                        Container(
                          height: 70.h,
                          width: 70.w,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(100.r),
                            border: Border.all(color: Colors.grey, width: 2.w),
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
                        SizedBox(height: 6.h),
                        Text(
                          i == 0
                              ? 'Men'
                              : i == 1
                              ? 'Women'
                              : i == 2
                              ? 'Boys'
                              : 'Girls',
                          style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                ],
              ),

              SizedBox(height: 25.h),

              // All Products Header
              Row(
                children: [
                  Text(
                    'All Products',
                    style: TextStyle(
                      fontSize: 16.sp,
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
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontFamily: 'Inter',
                        color: const Color(0xFFC19375),
                      ),
                    ),
                  ),
                  SizedBox(width: 5.w),
                  SvgPicture.asset(
                    'assets/icons/expand_circle_right_41dp_000000_FILL0_wght400_GRAD0_opsz40.svg',
                    height: 20.h,
                    width: 20.w,
                    colorFilter: const ColorFilter.mode(
                      Color(0xFFC19375),
                      BlendMode.srcIn,
                    ),
                  ),
                ],
              ),

              SizedBox(height: 15.h),

              // Products Grid or Loading/Error/Empty States
              _buildProductsSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductsSection() {
    // Loading state
    if (isLoading) {
      return SizedBox(
        height: 300.h,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: const Color(0xFFC19375)),
              SizedBox(height: 16.h),
              Text(
                "Loading products...",
                style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      );
    }

    // Error state
    if (errorMessage != null) {
      return SizedBox(
        height: 300.h,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 60.h, color: Colors.red),
              SizedBox(height: 16.h),
              Text(
                errorMessage!,
                style: TextStyle(fontSize: 14.sp, color: Colors.red),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16.h),
              ElevatedButton(
                onPressed: loadProducts,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFC19375),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
                child: const Text(
                  "Retry",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Empty state
    if (filteredproducts.isEmpty) {
      return SizedBox(
        height: 300.h,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                searchController.text.isEmpty
                    ? Icons.inventory_2_outlined
                    : Icons.search_off,
                size: 60.h,
                color: Colors.grey[400],
              ),
              SizedBox(height: 16.h),
              Text(
                searchController.text.isEmpty
                    ? 'No products available'
                    : 'No products found for "${searchController.text}"',
                style: TextStyle(fontSize: 16.sp, color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
              if (searchController.text.isEmpty) ...[
                SizedBox(height: 16.h),
                ElevatedButton(
                  onPressed: loadProducts,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFC19375),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                  child: const Text(
                    "Refresh",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ],
          ),
        ),
      );
    }

    // Products Grid
    return Consumer<WishlistProvider>(
      builder: (context, wishlistProvider, _) {
        return GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: filteredproducts.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12.w,
            mainAxisSpacing: 16.h,
            childAspectRatio: 0.65,
          ),
          itemBuilder: (context, index) {
            final product = filteredproducts[index];
            final imageUrl = product['image']?.toString() ?? '';
            final productId = product['id']?.toString() ?? '';
            final brandName = product['brandname']?.toString() ?? 'Brand';
            final productName = product['name']?.toString() ?? 'Product';
            final productPrice = product['price']?.toString() ?? '0';

            // Check if product is in wishlist
            final isLiked = productId.isNotEmpty
                ? wishlistProvider.isLiked(productId)
                : false;

            return GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      Product(product: product, onGoToCart: widget.goToCart),
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.r),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 6.r,
                      offset: Offset(0, 2.h),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Product Image
                    Stack(
                      children: [
                        Container(
                          height: 180.h,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(12.r),
                              topRight: Radius.circular(12.r),
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(12.r),
                              topRight: Radius.circular(12.r),
                            ),
                            child: _buildProductImage(imageUrl),
                          ),
                        ),

                        // Wishlist Button
                        Positioned(
                          right: 8.w,
                          top: 8.h,
                          child: GestureDetector(
                            onTap: () async {
                              if (productId.isEmpty) return;

                              if (!isLiked) {
                                // Show confirmation dialog for adding to wishlist
                                final bool?
                                confirm = await showModalBottomSheet<bool>(
                                  context: context,
                                  isScrollControlled: true,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.vertical(
                                      top: Radius.circular(20.r),
                                    ),
                                  ),
                                  builder: (context) {
                                    return Container(
                                      padding: EdgeInsets.all(20.w),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            "Add to Wishlist?",
                                            style: TextStyle(
                                              fontSize: 18.sp,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          SizedBox(height: 10.h),
                                          Text(
                                            "Do you really want to add this item to your wishlist?",
                                            textAlign: TextAlign.center,
                                            style: TextStyle(fontSize: 14.sp),
                                          ),
                                          SizedBox(height: 20.h),
                                          Row(
                                            children: [
                                              Expanded(
                                                child: OutlinedButton(
                                                  onPressed: () =>
                                                      Navigator.pop(
                                                        context,
                                                        false,
                                                      ),
                                                  style: OutlinedButton.styleFrom(
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            8.r,
                                                          ),
                                                    ),
                                                    side: BorderSide(
                                                      color: Colors.grey[300]!,
                                                    ),
                                                  ),
                                                  child: Text(
                                                    "Cancel",
                                                    style: TextStyle(
                                                      fontSize: 14.sp,
                                                      color: Colors.grey[700],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              SizedBox(width: 12.w),
                                              Expanded(
                                                child: ElevatedButton(
                                                  onPressed: () =>
                                                      Navigator.pop(
                                                        context,
                                                        true,
                                                      ),
                                                  style: ElevatedButton.styleFrom(
                                                    backgroundColor:
                                                        const Color(0xFFC19375),
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            8.r,
                                                          ),
                                                    ),
                                                  ),
                                                  child: Text(
                                                    "Yes",
                                                    style: TextStyle(
                                                      fontSize: 14.sp,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(
                                            height: MediaQuery.of(
                                              context,
                                            ).viewInsets.bottom,
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                );

                                if (confirm == true) {
                                  await wishlistProvider.toggleLike(product);
                                  print('clicked');
                                }
                              } else {
                                // Remove from wishlist directly
                                await wishlistProvider.toggleLike(product);
                              }
                            },
                            child: Container(
                              padding: EdgeInsets.all(6.w),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20.r),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 4.r,
                                    offset: Offset(0, 2.h),
                                  ),
                                ],
                              ),
                              child: Icon(
                                isLiked
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                color: isLiked
                                    ? Colors.redAccent
                                    : Colors.grey[600],
                                size: 18.w,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    // Product Details
                    Padding(
                      padding: EdgeInsets.all(10.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            brandName,
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w600,
                              fontSize: 14.sp,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            productName,
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w500,
                              fontSize: 13.sp,
                              color: Colors.grey[700],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 6.h),
                          Text(
                            productPrice.startsWith('₹')
                                ? productPrice
                                : '₹$productPrice',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFFC19375),
                              fontSize: 15.sp,
                            ),
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
    );
  }
}
