import 'package:comercial_app/screens/Authentications_screens/signup.dart';
import 'package:flutter/material.dart';

class Onboarding extends StatefulWidget {
  const Onboarding({super.key});

  @override
  State<Onboarding> createState() => _OnboardingState();
}

class _OnboardingState extends State<Onboarding> {
  final PageController _controller = PageController();
  int currentPage = 0;

  final List<String> images = [
    "assets/images/onboard.jpg",
    "assets/images/onboard2.jpg",
    "assets/images/onboard3.jpg",
  ];

  final List<String> titles = [
    "Choose\nYour Perfect\nFashion",
    "Discover\nNew Trendy\nCollections",
    "Upgrade\nYour Style\nToday",
  ];

  final List<String> subtitles = [
    "Find the latest & best outfits\nthat match your lifestyle.",
    "Browse thousands of trendy outfits\ncrafted for your personality.",
    "Shop smart & stylish — your new wardrobe\nstarts here.",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView.builder(
            controller: _controller,
            itemCount: 3,
            onPageChanged: (index) {
              setState(() => currentPage = index);
            },
            itemBuilder: (context, index) {
              return Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage(images[index]),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),

                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.black.withOpacity(0.8),
                          Colors.black.withOpacity(0.3),
                          Colors.transparent,
                        ],
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                      ),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Spacer(),

                        ShaderMask(
                          shaderCallback: (bounds) => const LinearGradient(
                            colors: [Colors.amber, Colors.orangeAccent],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ).createShader(bounds),
                          child: Text(
                            titles[index],
                            style: const TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                              height: 1.1,
                              color: Colors.white,
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        Text(
                          subtitles[index],
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.white70,
                            height: 1.5,
                          ),
                        ),

                        const SizedBox(height: 40),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: List.generate(
                                3,
                                (dotIndex) => AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  margin: const EdgeInsets.only(right: 6),
                                  height: 10,
                                  width: currentPage == dotIndex ? 26 : 10,
                                  decoration: BoxDecoration(
                                    color: currentPage == dotIndex
                                        ? Colors.amber
                                        : Colors.white54,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                ),
                              ),
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.amber,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              onPressed: () {
                                if (currentPage == 2) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => Signup(),
                                    ),
                                  );
                                } else {
                                  _controller.nextPage(
                                    duration: const Duration(milliseconds: 400),
                                    curve: Curves.easeInOut,
                                  );
                                }
                              },
                              child: Text(
                                currentPage == 2 ? "Get Started" : "Next",
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
