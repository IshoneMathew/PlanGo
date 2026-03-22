import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../theme/app_theme.dart';
import 'auth/sign_in_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});
  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<_OnboardData> _pages = [
    _OnboardData(
      imageUrl: 'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=800&q=80',
      headline: 'Life is short and the\nworld is ', highlight: 'wide',
      subtitle: 'At PlanGo, we help you discover and explore the most beautiful destinations across Sri Lanka.',
      buttonLabel: 'Get Started',
    ),
    _OnboardData(
      imageUrl: 'https://images.unsplash.com/photo-1588416936097-41850ab3d86d?w=800&q=80',
      headline: "It's a big world out\nthere go ", highlight: 'explore',
      subtitle: 'To get the best of your adventure you just need to leave and go where you like. We are waiting for you.',
      buttonLabel: 'Next',
    ),
    _OnboardData(
      imageUrl: 'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=800&q=80',
      headline: "People don't take trips,\ntrips take ", highlight: 'people',
      subtitle: 'Plan your perfect Sri Lanka trip with AI, book destinations, and create unforgettable memories.',
      buttonLabel: 'Next',
    ),
  ];

  Future<void> _done() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_done', true);
    if (mounted) {
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const SignInScreen()));
    }
  }

  void _next() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(duration: const Duration(milliseconds: 400), curve: Curves.easeInOut);
    } else {
      _done();
    }
  }

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent, statusBarIconBrightness: Brightness.light));
  }

  @override
  void dispose() { _pageController.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Expanded(
            flex: 55,
            child: PageView.builder(
              controller: _pageController,
              itemCount: _pages.length,
              onPageChanged: (i) => setState(() => _currentPage = i),
              itemBuilder: (_, i) => _OnboardImage(data: _pages[i], onSkip: _done),
            ),
          ),
          Expanded(
            flex: 45,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                children: [
                  const SizedBox(height: 28),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: Text(_pages[_currentPage].subtitle,
                        key: ValueKey(_currentPage),
                        textAlign: TextAlign.center,
                        style: GoogleFonts.spaceGrotesk(fontSize: 14, color: AppColors.textSecondary, height: 1.7)),
                  ),
                  const Spacer(),
                  SmoothPageIndicator(
                    controller: _pageController,
                    count: _pages.length,
                    effect: ExpandingDotsEffect(
                      activeDotColor: AppColors.primary, dotColor: AppColors.primary.withOpacity(0.25),
                      dotHeight: 8, dotWidth: 8, expansionFactor: 3, spacing: 6),
                  ),
                  const SizedBox(height: 28),
                  ElevatedButton(
                    onPressed: _next,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.dark,
                      minimumSize: const Size(double.infinity, 56),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: Text(
                      _currentPage == _pages.length - 1 ? 'Get Started' : _pages[_currentPage].buttonLabel,
                      style: GoogleFonts.spaceGrotesk(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OnboardImage extends StatelessWidget {
  final _OnboardData data;
  final VoidCallback onSkip;
  const _OnboardImage({required this.data, required this.onSkip});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.network(data.imageUrl, fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(color: Colors.grey.shade800)),
        Container(decoration: const BoxDecoration(
          gradient: LinearGradient(colors: [Colors.transparent, Color(0x66000000)],
              begin: Alignment.topCenter, end: Alignment.bottomCenter))),
        Positioned(
          top: 52, right: 20,
          child: GestureDetector(
            onTap: onSkip,
            child: Text('Skip', style: GoogleFonts.spaceGrotesk(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w500)),
          ),
        ),
        Positioned(
          bottom: 32, left: 24, right: 24,
          child: RichText(
            text: TextSpan(children: [
              TextSpan(text: data.headline,
                  style: GoogleFonts.spaceGrotesk(fontSize: 26, fontWeight: FontWeight.w700, color: Colors.white, height: 1.3)),
              TextSpan(text: data.highlight,
                  style: GoogleFonts.spaceGrotesk(fontSize: 26, fontWeight: FontWeight.w700, color: AppColors.accent, height: 1.3)),
            ]),
          ),
        ),
      ],
    );
  }
}

class _OnboardData {
  final String imageUrl, headline, highlight, subtitle, buttonLabel;
  const _OnboardData({required this.imageUrl, required this.headline, required this.highlight, required this.subtitle, required this.buttonLabel});
}
