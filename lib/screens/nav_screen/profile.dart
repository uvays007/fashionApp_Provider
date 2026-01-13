import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:comercial_app/screens/Authentications_screens/login.dart';
import 'package:comercial_app/screens/global_screen/global.dart';
import 'package:comercial_app/screens/order_screen/order.dart';
import 'package:comercial_app/screens/wishlist_screen/wishlist.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class Profile extends StatelessWidget {
  const Profile({super.key});

  Future<Map<String, dynamic>> getname() async {
    final namedata = await FirebaseFirestore.instance
        .collection('Users')
        .doc(nameid)
        .get();

    return namedata.data() ?? {};
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 10),
            Center(
              child: Stack(
                children: [
                  Container(
                    height: 110,
                    width: 110,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFFC19375),
                        width: 3,
                      ),
                      image: DecorationImage(
                        image: AssetImage('assets/images/blue_prof.jpg'),
                        fit: BoxFit.fill,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 4,
                    right: 4,
                    child: Container(
                      height: 30,
                      width: 30,
                      decoration: const BoxDecoration(
                        color: Color(0xFFC19375),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.edit,
                        size: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            FutureBuilder<Map<String, dynamic>>(
              future: getname(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Text(
                    "loading",
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w700,
                      fontSize: 20,
                    ),
                  );
                }
                final user = snapshot.data!;
                final username = user['name'] ?? "no name";
                final email = user['email'] ?? "no email";
                return Column(
                  children: [
                    Text(
                      username,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w700,
                        fontSize: 20,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      email,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w500,
                        fontSize: 20,
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                );
              },
            ),

            _buildProfileOption(
              icon:
                  'assets/icons/orders_24dp_000000_FILL0_wght400_GRAD0_opsz24.svg',
              title: "My Orders",
              subtitle: "View your past and current orders",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => OrderPage()),
                );
              },
            ),
            _buildProfileOption(
              icon:
                  'assets/icons/bookmark_heart_24dp_000000_FILL0_wght400_GRAD0_opsz24.svg',
              title: "Wishlist",
              subtitle: "Your saved products",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => WishlistPage()),
                );
              },
            ),
            _buildProfileOption(
              icon:
                  'assets/icons/settings_account_box_24dp_000000_FILL0_wght400_GRAD0_opsz24.svg',
              title: "Account Settings",
              subtitle: "Change password, update details",
              onTap: () {},
            ),
            _buildProfileOption(
              icon:
                  'assets/icons/help_24dp_000000_FILL0_wght400_GRAD0_opsz24.svg',
              title: "Help & Support",
              subtitle: "FAQs and contact support",
              onTap: () {},
            ),

            const SizedBox(height: 10),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFC19375),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => Login()),
                  );
                },
                child: const Text(
                  "Log Out",
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileOption({
    required String icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFF6F6F6),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            SvgPicture.asset(
              icon,
              height: 26,
              width: 26,
              colorFilter: const ColorFilter.mode(
                Color(0xFFC19375),
                BlendMode.srcIn,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      color: Colors.grey[700],
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
