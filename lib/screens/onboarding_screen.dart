
import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _introKey = GlobalKey<IntroductionScreenState>();

  void _onIntroEnd(context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('seenOnboarding', true);
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    const pageDecoration = PageDecoration(
      titleTextStyle: TextStyle(fontSize: 28.0, fontWeight: FontWeight.w700),
      bodyTextStyle: TextStyle(fontSize: 19.0),
      imagePadding: EdgeInsets.zero,
    );

    return IntroductionScreen(
      key: _introKey,
      pages: [
        PageViewModel(
          title: "Добро пожаловать в FreeDome Sphere",
          body: "Профессиональный редактор сферического 3D и 2D контента.",
          image: const Center(
            child: Icon(Icons.threesixty, size: 175.0),
          ),
          decoration: pageDecoration,
        ),
        PageViewModel(
          title: "Система понимания Любомира",
          body: "Интегрированная система для помощи в творческом процессе.",
          image: const Center(
            child: Icon(Icons.lightbulb_outline, size: 175.0),
          ),
          decoration: pageDecoration,
        ),
        PageViewModel(
          title: "Начните творить",
          body: "Готовы начать?",
          image: const Center(
            child: Icon(Icons.rocket_launch, size: 175.0),
          ),
          decoration: pageDecoration,
        ),
      ],
      onDone: () => _onIntroEnd(context),
      onSkip: () => _onIntroEnd(context), // You can also add a skip button
      showSkipButton: true,
      skip: const Text('Пропустить'),
      next: const Icon(Icons.arrow_forward),
      done: const Text('Готово', style: TextStyle(fontWeight: FontWeight.w600)),
      dotsDecorator: const DotsDecorator(
        size: Size(10.0, 10.0),
        color: Color(0xFFBDBDBD),
        activeSize: Size(22.0, 10.0),
        activeShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(25.0)),
        ),
      ),
    );
  }
}
