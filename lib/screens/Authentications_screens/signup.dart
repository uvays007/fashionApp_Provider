import 'package:comercial_app/providers/signup_provider.dart';
import 'package:comercial_app/screens/Authentications_screens/login.dart';

import 'package:comercial_app/screens/nav_screen/nav.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Signup extends StatefulWidget {
  const Signup({super.key});

  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final signupProvider = context.watch<SignupProvider>();
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 50),
              const Text(
                'FITMAX',
                style: TextStyle(
                  fontFamily: 'LondrinaSolid',
                  shadows: [
                    Shadow(
                      offset: Offset(0, 4),
                      blurRadius: 6.0,
                      color: Colors.grey,
                    ),
                  ],
                  fontWeight: FontWeight.w600,
                  fontSize: 45,
                  color: Color(0xFFC19375),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Create an account',
                style: TextStyle(
                  fontSize: 16,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Text(
                'Enter your email to sign up for this app',
                style: TextStyle(
                  fontSize: 16,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w400,
                  color: Colors.black54,
                ),
              ),
              SizedBox(height: 12),

              TextField(
                onChanged: (_) {
                  signupProvider.clearUsernameError();
                },
                controller: _usernameController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  errorText: signupProvider.usernameError,
                  contentPadding: const EdgeInsets.fromLTRB(15, 10, 10, 10),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFF828282)),
                  ),
                  hintText: 'Username',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                onChanged: (_) {
                  signupProvider.clearEmailError();
                },
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  errorText: signupProvider.emailError,
                  contentPadding: const EdgeInsets.fromLTRB(15, 10, 10, 10),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFF828282)),
                  ),
                  hintText: 'Enter your Email',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _passwordController,
                obscureText: !signupProvider.showPassword,
                onChanged: (_) {
                  context.read<SignupProvider>().clearPasswordError();
                },
                decoration: InputDecoration(
                  errorText: signupProvider.passwordError,
                  hintText: 'Enter your Password',
                  suffixIcon: GestureDetector(
                    onTapDown: (_) => context
                        .read<SignupProvider>()
                        .togglePasswordVisibility(true),
                    onTapUp: (_) => context
                        .read<SignupProvider>()
                        .togglePasswordVisibility(false),
                    onTapCancel: () => context
                        .read<SignupProvider>()
                        .togglePasswordVisibility(false),
                    child: Icon(
                      signupProvider.showPassword
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                  ),
                  contentPadding: const EdgeInsets.fromLTRB(15, 10, 10, 10),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFF828282)),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),

              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    foregroundColor: Colors.white,
                    backgroundColor: const Color(0xFFC19375),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed: signupProvider.isLoading
                      ? null
                      : () async {
                          final success = await context
                              .read<SignupProvider>()
                              .signup(
                                username: _usernameController.text,
                                email: _emailController.text,
                                password: _passwordController.text,
                              );

                          if (success && context.mounted) {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (_) => const Nav()),
                            );
                          }
                        },
                  child: signupProvider.isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Continue', style: TextStyle(fontSize: 16)),
                ),
              ),

              const SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Already have an account? ",
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => const Login()),
                      );
                    },
                    child: const Text(
                      "Log In",
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFC19375),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: const [
                  Expanded(
                    child: Divider(
                      color: Color(0xFFE6E6E6),
                      thickness: 1,
                      endIndent: 10,
                    ),
                  ),
                  Text(
                    'or',
                    style: TextStyle(
                      color: Color(0xFF828282),
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  Expanded(
                    child: Divider(
                      color: Color(0xFFE6E6E6),
                      thickness: 1,
                      indent: 10,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    foregroundColor: Colors.black,
                    backgroundColor: const Color(0xFFEEEEEE),
                  ),
                  onPressed: () {},
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(width: 12),
                      Image.asset(
                        width: 20,
                        height: 20,
                        'assets/images/Google_Favicon_2025.png',
                      ),
                      const SizedBox(width: 8),
                      const Text('Continue with Google'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 5),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    foregroundColor: Colors.black,
                    backgroundColor: const Color(0xFFEEEEEE),
                  ),
                  onPressed: () {},
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(size: 30, Icons.apple),
                      const SizedBox(width: 3),
                      const Text('Continue with Apple'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'By clicking continue, you agree to our Terms of Service and Privacy Policy',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w400,
                  color: Colors.black54,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
