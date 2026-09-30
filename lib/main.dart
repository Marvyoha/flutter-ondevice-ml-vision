import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/homescreen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: CIFAR10App()));
}

class CIFAR10App extends StatelessWidget {
  const CIFAR10App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CIFAR-10 On-Device Classifier',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.indigo,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        fontFamily: GoogleFonts.spaceGrotesk().fontFamily,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.indigo,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        fontFamily: GoogleFonts.spaceGrotesk().fontFamily,
      ),
      home: const OnboardingGate(),
    );
  }
}
