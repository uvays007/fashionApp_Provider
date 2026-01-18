import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:comercial_app/screens/global_screen/global.dart';
import 'package:comercial_app/screens/nav_screen/home.dart'; // Import actual Home
import 'package:comercial_app/screens/nav_screen/tryon.dart'; // Import actual Tryon
import 'package:comercial_app/screens/nav_screen/cart.dart'; // Import actual Cart
import 'package:comercial_app/screens/nav_screen/profile.dart'; // Import actual Profile
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class Nav extends StatefulWidget {
  const Nav({super.key});

  @override
  State<Nav> createState() => _NavState();
}

class _NavState extends State<Nav> with SingleTickerProviderStateMixin {
  int selectedIndex = 0;
  bool showNotifications = false;
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final List<String> icons = [
    'assets/icons/bottm_nav/home_30dp_000000_FILL0_wght400_GRAD0_opsz24.svg',
    'assets/icons/bottm_nav/checkroom_30dp_000000_FILL0_wght400_GRAD0_opsz24.svg',
    'assets/icons/bottm_nav/shopping_cart_30dp_000000_FILL0_wght400_GRAD0_opsz24.svg',
    'assets/icons/bottm_nav/person_30dp_000000_FILL0_wght400_GRAD0_opsz24.svg',
  ];

  void goToCart() {
    setState(() => selectedIndex = 2);
  }

  @override
  void initState() {
    super.initState();
    user();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
  }

  Future<Map<String, dynamic>> user() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('Users')
        .doc(nameid)
        .get();
    final data = snapshot.data();
    return data!;
  }

  void toggleNotifications() {
    setState(() {
      showNotifications = !showNotifications;
      showNotifications ? _controller.forward() : _controller.reverse();
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      Home(goToCart: goToCart), // Your actual Home screen
      Tryon(), // Your actual Tryon screen
      Cart(), // Your actual Cart screen
      Profile(), // Your actual Profile screen
    ];

    return Scaffold(
      drawer: buildDrawer(context),
      appBar: AppBar(
        backgroundColor: const Color(0xFFC19375),
        centerTitle: true,
        title: const Text(
          'FITMAX',
          style: TextStyle(
            fontFamily: 'LondrinaSolid',
            fontWeight: FontWeight.w600,
            fontSize: 30,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            onPressed: toggleNotifications,
            icon: const Icon(Icons.notifications_none, color: Colors.black87),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: GestureDetector(
              onTap: () => setState(() => selectedIndex = 3),
              child: selectedIndex == 0
                  ? Container(
                      width: 35,
                      height: 35,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.grey.shade400,
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(100),
                        image: const DecorationImage(
                          image: AssetImage("assets/images/blue_prof.jpg"),
                          fit: BoxFit.cover,
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          AnimatedSwitcher(
            switchInCurve: Curves.easeInCubic,
            duration: const Duration(milliseconds: 300),
            child: pages[selectedIndex],
          ),
          if (showNotifications)
            GestureDetector(
              onTap: toggleNotifications,
              child: Container(color: Colors.transparent),
            ),
          Positioned(
            right: 10,
            top: kToolbarHeight + 5,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: Material(
                  color: Colors.transparent,
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.9,
                    constraints: const BoxConstraints(maxHeight: 300),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ListView.separated(
                      shrinkWrap: true,
                      padding: const EdgeInsets.all(12),
                      itemCount: notifications.length,
                      separatorBuilder: (_, __) => const Divider(height: 10),
                      itemBuilder: (context, index) {
                        final n = notifications[index];
                        return ListTile(
                          leading: const Icon(
                            Icons.notifications,
                            color: Color(0xFFC19375),
                          ),
                          title: Text(
                            n["message"],
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          trailing: Text(
                            n["time"].toString(),
                            style: const TextStyle(
                              fontSize: 11,
                              color: Colors.grey,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(color: Color(0xFFC19375)),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(icons.length, (index) {
            final bool isSelected = selectedIndex == index;
            return GestureDetector(
              onTap: () => setState(() => selectedIndex = index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                height: 45,
                width: 45,
                decoration: BoxDecoration(
                  color: isSelected ? Colors.black : Colors.transparent,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: SvgPicture.asset(
                    icons[index],
                    height: 24,
                    width: 24,
                    colorFilter: const ColorFilter.mode(
                      Colors.white,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  Drawer buildDrawer(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.grey.shade100,
      child: Column(
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(color: Color(0xFFC19375)),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 35,
                  backgroundImage: AssetImage("assets/images/blue_prof.jpg"),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FutureBuilder<Map<String, dynamic>>(
                        future: user(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return const Text('Loading...');
                          }
                          var data = snapshot.data!;
                          return Text(
                            data['name'],
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Colors.black87,
                            ),
                          );
                        },
                      ),
                      FutureBuilder<Map<String, dynamic>>(
                        future: user(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return const Text('Loading...');
                          }
                          var data = snapshot.data;
                          return Text(
                            data!['email'],
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.black87,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          buildDrawerItem(
            icon: Icons.home_outlined,
            text: "Home",
            onTap: () => _navigateTo(0),
          ),
          buildDrawerItem(
            icon: Icons.shopping_cart_checkout,
            text: "Orders",
            onTap: () => Navigator.pushNamed(context, '/orders'),
          ),
          buildDrawerItem(
            icon: Icons.favorite_outline,
            text: "Wishlist",
            onTap: () => Navigator.pushNamed(context, '/wishlist'),
          ),
          buildDrawerItem(
            icon: Icons.settings_outlined,
            text: "Settings",
            onTap: () {},
          ),
          buildDrawerItem(icon: Icons.help_outline, text: "Help", onTap: () {}),
          const Spacer(),
          const Divider(thickness: 1, color: Colors.grey),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.redAccent),
            title: const Text(
              "Logout",
              style: TextStyle(color: Colors.redAccent),
            ),
            onTap: () => Navigator.pushNamedAndRemoveUntil(
              context,
              '/login',
              (route) => false,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildDrawerItem({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.black87),
      title: Text(
        text,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      ),
      onTap: () {
        Navigator.pop(context);
        onTap();
      },
    );
  }

  void _navigateTo(int index) => setState(() => selectedIndex = index);
}

// Remove these dummy classes! They were just for demonstration
// class Home extends StatelessWidget { ... }
// class Tryon extends StatelessWidget { ... }
// class Cart extends StatelessWidget { ... }
// class Profile extends StatelessWidget { ... }
