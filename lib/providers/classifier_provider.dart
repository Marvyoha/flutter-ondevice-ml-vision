import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../models/classification_result.dart';
import '../services/cifar10_classifier.dart';

final classifierServiceProvider = Provider<CIFAR10Classifier>((ref) {
  final service = CIFAR10Classifier();
  ref.onDispose(() => service.dispose());
  return service;
});

class ClassifierState {
  final bool isModelReady;
  final bool isProcessing;
  final File? selectedImage;
  final ClassificationResult? result;
  final String? errorMessage;

  const ClassifierState({
    this.isModelReady = false,
    this.isProcessing = false,
    this.selectedImage,
    this.result,
    this.errorMessage,
  });

  ClassifierState copyWith({
    bool? isModelReady,
    bool? isProcessing,
    File? selectedImage,
    ClassificationResult? result,
    String? errorMessage,
  }) {
    return ClassifierState(
      isModelReady: isModelReady ?? this.isModelReady,
      isProcessing: isProcessing ?? this.isProcessing,
      selectedImage: selectedImage ?? this.selectedImage,
      result: result ?? this.result,
      errorMessage: errorMessage,
    );
  }
}

class ClassifierNotifier extends Notifier<ClassifierState> {
  late final CIFAR10Classifier _classifier;
  final ImagePicker _picker = ImagePicker();

  @override
  ClassifierState build() {
    _classifier = ref.read(classifierServiceProvider);
    _init();
    return const ClassifierState();
  }

  Future<void> _init() async {
    try {
      await _classifier.initialize();
      state = state.copyWith(isModelReady: true);
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
    }
  }

  Future<void> pickFromCamera() async {
    await _pickAndProcess(ImageSource.camera);
  }

  Future<void> pickFromGallery() async {
    await _pickAndProcess(ImageSource.gallery);
  }

  Future<void> _pickAndProcess(ImageSource source) async {
    if (!state.isModelReady) return;

    try {
      final pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (pickedFile == null) return;

      final file = File(pickedFile.path);
      state = state.copyWith(
        selectedImage: file,
        isProcessing: true,
        errorMessage: null,
      );

      final result = await _classifier.classifyImage(file);

      state = state.copyWith(
        isProcessing: false,
        result: result,
        errorMessage: result.error,
      );
    } catch (e) {
      state = state.copyWith(
        isProcessing: false,
        errorMessage: 'Image pick/process failed: $e',
      );
    }
  }
}

final classifierProvider = NotifierProvider<ClassifierNotifier, ClassifierState>(() {
  return ClassifierNotifier();
});
