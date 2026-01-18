import 'package:comercial_app/providers/login_provider.dart';
import 'package:comercial_app/providers/signup_provider.dart';
import 'package:comercial_app/providers/wishlist_provider.dart';
import 'package:comercial_app/screens/Authentications_screens/login.dart';
import 'package:comercial_app/screens/nav_screen/nav.dart';
import 'package:comercial_app/screens/onboarding_screen/onboarding.dart';
import 'package:comercial_app/screens/order_screen/order.dart';
import 'package:comercial_app/screens/wishlist_screen/wishlist.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SignupProvider()),
        ChangeNotifierProvider(create: (_) => LoginProvider()),
        ChangeNotifierProvider(create: (_) => WishlistProvider()),
      ],
      child: ScreenUtilInit(
        designSize: const Size(390, 844),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) => const MainApp(),
      ),
    ),
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'FITMAX',
      theme: ThemeData(
        primaryColor: const Color(0xFFC19375),
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFC19375),
          elevation: 0.5,
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const Nav(),
        '/login': (context) => const Login(),
        '/home': (context) => const Nav(),
        '/wishlist': (context) => const WishlistPage(),
        '/orders': (context) => const OrderPage(),
      },
      // Optional: Handle unknown routes
      onGenerateRoute: (settings) {
        return MaterialPageRoute(builder: (context) => const Nav());
      },
    );
  }
}
