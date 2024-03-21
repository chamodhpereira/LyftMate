import 'package:flutter/material.dart';
import 'package:lyft_mate/main.dart';
import 'package:lyft_mate/screens/welcome/welcome_screen.dart';
// import 'package:lyft_mate/src/screens/welcome_screen.dart';

class OnBoardingScreen extends StatefulWidget {
  const OnBoardingScreen({super.key});

  @override
  State<OnBoardingScreen> createState() => _OnBoardingScreenState();
}

class _OnBoardingScreenState extends State<OnBoardingScreen> {
  late PageController _pageController;

  int _pageIndex = 0;
  @override
  void initState() {
    _pageController = PageController(initialPage: 0);
    super.initState();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  children: [
                    const Spacer(),
                    TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => WelcomeScreen()),
                          );
                        },
                        child: const Text(
                          "SKIP",
                          style: TextStyle(
                              letterSpacing: 2.0,
                              fontSize: 18.0,
                              color: Colors.green,
                              fontWeight: FontWeight.bold),
                        )),
                  ],
                ),
                Expanded(
                  child: PageView.builder(
                    itemCount: demoData.length,
                    controller: _pageController,
                    onPageChanged: (index) {
                      setState(() {
                        _pageIndex = index;
                      });
                    },
                    itemBuilder: (context, index) => OnBoardContent(
                      image: demoData[index].image,
                      title: demoData[index].title,
                      description: demoData[index].description,
                    ),
                  ),
                ),
                Row(
                  children: [
                    ...List.generate(
                      demoData.length,
                          (index) => Padding(
                        padding: const EdgeInsets.only(right: 4.0),
                        child: DotIndicator(
                          isActive: index == _pageIndex,
                        ),
                      ),
                    ),
                    const Spacer(),
                    SizedBox(
                      height: 60,
                      width: 60,
                      child: ElevatedButton(
                        onPressed: () {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.ease,
                          );
                          _pageIndex == demoData.length - 1
                              ? Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => WelcomeScreen()),
                          )
                              : null;
                        },
                        style: ElevatedButton.styleFrom(
                          shape: const CircleBorder(),
                          // side: const BorderSide(color: Colors.black),
                          backgroundColor: Colors.green,
                        ),
                        child: const Icon(
                          Icons.arrow_forward_ios,
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          )),
    );
  }
}

class DotIndicator extends StatelessWidget {
  const DotIndicator({super.key, this.isActive = false});

  final bool isActive;
  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      height: isActive ? 12 : 4,
      width: 4,
      decoration: BoxDecoration(
        color: isActive ? Colors.green : Colors.green.withOpacity(0.4),
        borderRadius: const BorderRadius.all(
          Radius.circular(12),
        ),
      ),
      duration: const Duration(milliseconds: 300),
    );
  }
}

class OnBoard {
  final String image, title, description;

  OnBoard({
    required this.image,
    required this.title,
    required this.description,
  });
}

final List<OnBoard> demoData = [
  OnBoard(
    image: "assets/images/carpool-image-1.jpg",
    title: "Find a Ride",
    description:
    "Going somewhere? Carpooling is the way to go! Book low cost sharing rides and travel with people going your way.",
  ),
  OnBoard(
    image: "assets/images/carpool-image-2.jpg",
    title: "Offer a Ride",
    description:
    "Driving somewhere? Publish your ride! Choose who goes with you and enjoy the least expensive ride you've ever made.",
  ),
  OnBoard(
    image: "assets/images/carpool-image-3.jpg",
    title: "Travel Together",
    description:
    "Travel with others and enjoy the journey. Carpooling is more than saving money; it's about connecting and building community.",
  ),
  OnBoard(
    image: "assets/images/carpool-image-5.jpg",
    title: "Save the Planet",
    description:
    "Help the environment by carpooling. Reduce emissions and fight pollution. Every shared ride brings us closer to a greener future. Let's drive towards sustainability together.",
  ),
];

class OnBoardContent extends StatelessWidget {
  const OnBoardContent({
    Key? key,
    required this.image,
    required this.title,
    required this.description,
  }) : super(key: key);

  final String image, title, description;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Spacer(),
        Image.asset(
          image,
          height: 250.0,
        ),
        const SizedBox(height: 16),
        Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 25.0, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            description,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13),
          ),
        ),
        const Spacer(),
      ],
    );
  }
}
