import 'package:comercial_app/screens/Authentications_screens/signup.dart';
import 'package:comercial_app/screens/nav_screen/nav.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String? emailError;
  String? passwordError;
  bool loading = false;
  bool haserror = false;
  bool showpassword = false;

  Future<void> login() async {
    haserror = false;
    setState(() {
      emailError = null;
      passwordError = null;
    });

    if (_emailController.text.trim().isEmpty) {
      setState(() => emailError = "Please enter your email");
      haserror = true;
    }
    if (_passwordController.text.trim().isEmpty) {
      setState(() => passwordError = "Please enter your password");
      haserror = true;
    }
    if (haserror) return;

    setState(() => loading = true);

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const Nav()),
      );
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'email-already-in-use':
          setState(() => emailError = "This email is already registered");
          break;

        case 'invalid-email':
          setState(() => emailError = "Invalid email address");
          break;

        case 'weak-password':
          setState(() => passwordError = "Password is too weak");
          break;
        case 'user-not-found':
          setState(() => emailError = "No account found for this email");
          break;
        case 'invalid-credential':
          setState(() => passwordError = "Password is incorrect");
          break;

        case 'operation-not-allowed':
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Email/password sign-up not enabled."),
            ),
          );
          break;

        case 'too-many-requests':
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Too many attempts. Try again later."),
            ),
          );
          break;

        default:
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Sign-up failed. Please try again.")),
          );
      }
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
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
                  'Welcome Back',
                  style: TextStyle(
                    fontSize: 16,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 5),
                const Text(
                  'Log in to your account',
                  style: TextStyle(
                    fontSize: 16,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w400,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 40),

                TextField(
                  onChanged: (_) {
                    if (emailError != null) {
                      setState(() => emailError = null);
                    }
                  },
                  controller: _emailController,
                  decoration: InputDecoration(
                    errorText: emailError,
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
                  obscureText: !showpassword,
                  decoration: InputDecoration(
                    suffixIcon: GestureDetector(
                      onTapDown: (_) {
                        setState(() {
                          showpassword = true;
                        });
                      },
                      onTapUp: (_) {
                        setState(() {
                          showpassword = false;
                        });
                      },
                      onTapCancel: () {
                        setState(() {
                          showpassword = false;
                        });
                      },
                      child: showpassword
                          ? Icon(Icons.visibility)
                          : Icon(Icons.visibility_off),
                    ),
                    errorText: passwordError,
                    contentPadding: const EdgeInsets.fromLTRB(15, 10, 10, 10),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Color(0xFF828282)),
                    ),
                    hintText: 'Enter your Password',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      foregroundColor: Colors.white,
                      backgroundColor: const Color(0xFFC19375),
                    ),
                    onPressed: loading ? null : login,
                    child: loading
                        ? SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Log In'),
                  ),
                ),

                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {},
                    child: const Text(
                      'Forgot password?',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        color: Color(0xFFC19375),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
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

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Don't have an account? ",
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => Signup()),
                        );
                      },
                      child: const Text(
                        "Sign up",
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFC19375),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
