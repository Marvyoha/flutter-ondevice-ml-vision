import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'homescreen.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final pageController = PageController();
  int page = 0;

  final pages = const [
    _OnboardPage(
      title: 'Real-Time Image Classification',
      subtitle:
          'Identify everyday objects instantly using our custom lightweight CIFAR-10 deep learning model.',
      hero: Icons.auto_awesome,
    ),
    _OnboardPage(
      title: 'Trained on 10 Distinct Classes',
      subtitle:
          'Get instant inference with high accuracy across 10 fundamental vehicle and animal categories.',
      hero: Icons.grid_view,
    ),
    _OnboardPage(
      title: 'Fast, On-Device Neural Power',
      subtitle:
          'Run inference locally on your Flutter device with low latency and total data privacy.',
      hero: Icons.shield,
    ),
    _OnboardPage(
      title: 'Capture Better Photos',
      subtitle:
          'Fill 40-60% of frame, use plain background, ensure good lighting for best accuracy.',
      hero: Icons.camera_alt,
    ),
  ];

  Future<void> finish() async {
    const storage = FlutterSecureStorage();
    await storage.write(key: 'onboarding_complete', value: 'true');
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const ClassificationScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: pageController,
              onPageChanged: (i) => setState(() => page = i),
              itemCount: pages.length,
              itemBuilder: (_, i) => pages[i],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    4,
                    (i) => Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: page == i ? 24 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: page == i
                            ? Theme.of(context).colorScheme.primary
                            : Colors.grey,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    if (page > 0)
                      TextButton(
                        onPressed: () => pageController.previousPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.ease,
                        ),
                        child: const Text('Back'),
                      ),
                    const Spacer(),
                    ElevatedButton(
                      onPressed: page == 3
                          ? finish
                          : () => pageController.nextPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.ease,
                            ),
                      child: Text(page == 3 ? 'Get Started' : 'Next'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OnboardPage extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData hero;
  const _OnboardPage({
    required this.title,
    required this.subtitle,
    required this.hero,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(hero, size: 120),
          const SizedBox(height: 32),
          Text(
            title,
            style: Theme.of(context).textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
