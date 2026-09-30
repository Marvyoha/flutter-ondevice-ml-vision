import 'package:cifar_lens/screens/onboarding_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../providers/classifier_provider.dart';

class OnboardingGate extends ConsumerWidget {
  const OnboardingGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder<bool>(
      future: _checkOnboardingComplete(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.data == false) {
          return const OnboardingScreen();
        }

        return ClassificationScreen();
      },
    );
  }

  Future<bool> _checkOnboardingComplete() async {
    const storage = FlutterSecureStorage();
    final val = await storage.read(key: 'onboarding_complete');
    return val == 'true';
  }
}

class ClassificationScreen extends ConsumerWidget {
  const ClassificationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(classifierProvider);
    final notifier = ref.read(classifierProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('CIFAR-10 Edge AI'),
        centerTitle: true,
        actions: [
          Icon(
            state.isModelReady ? Icons.check_circle : Icons.hourglass_top,
            color: state.isModelReady ? Colors.green : Colors.orange,
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              flex: 5,
              child: Container(
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outlineVariant,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: state.selectedImage != null
                      ? Image.file(
                          state.selectedImage!,
                          fit: BoxFit.cover,
                          width: double.infinity,
                        )
                      : Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.photo_library_outlined,
                                size: 64,
                                color: Theme.of(context).colorScheme.outline,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                state.isModelReady
                                    ? 'Select or capture an image'
                                    : 'Loading INT8 model...',
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.outline,
                                ),
                              ),
                            ],
                          ),
                        ),
                ),
              ),
            ),

            if (state.isProcessing)
              const Padding(
                padding: EdgeInsets.all(16),
                child: LinearProgressIndicator(),
              )
            else if (state.result != null)
              Expanded(
                flex: 4,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: ResultCard(result: state.result!),
                ),
              )
            else
              const Spacer(flex: 4),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: state.isModelReady && !state.isProcessing
                          ? () => notifier.pickFromCamera()
                          : null,
                      icon: const Icon(Icons.camera_alt),
                      label: const Text('Camera'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton.tonalIcon(
                      onPressed: state.isModelReady && !state.isProcessing
                          ? () => notifier.pickFromGallery()
                          : null,
                      icon: const Icon(Icons.photo),
                      label: const Text('Gallery'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ResultCard extends StatelessWidget {
  final dynamic result;

  const ResultCard({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    final isConfident = result.isConfident as bool;
    final label = result.label as String?;
    final confidence = (result.confidence as double) * 100;
    final latency = result.inferenceTimeMs as double;

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isConfident
                      ? (label?.toUpperCase() ?? 'UNKNOWN')
                      : 'UNCERTAIN',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isConfident ? Colors.green : Colors.orange,
                  ),
                ),
                Chip(
                  label: Text('${latency.toStringAsFixed(1)} ms'),
                  avatar: const Icon(Icons.speed, size: 16),
                ),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: result.confidence as double,
              color: isConfident ? Colors.green : Colors.orange,
            ),
            const SizedBox(height: 6),
            Text(
              isConfident
                  ? 'Confidence: ${confidence.toStringAsFixed(1)}%'
                  : 'Low Confidence (${confidence.toStringAsFixed(1)}% < 65% threshold)',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const Divider(height: 16),
            Expanded(
              child: ListView(
                children: (result.allProbabilities as Map<String, double>)
                    .entries
                    .map(
                      (e) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(e.key),
                            Text('${(e.value * 100).toStringAsFixed(1)}%'),
                          ],
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
