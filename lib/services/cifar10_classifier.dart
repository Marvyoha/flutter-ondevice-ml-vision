import 'dart:io';
import 'dart:math' as math;
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';
import '../models/classification_result.dart';

class CIFAR10Classifier {
  static const String modelAssetPath = 'assets/models/cnn_model_int8.tflite';
  static const double confidenceThreshold = 0.45;
  static const int inputSize = 32;

  static const List<String> labels = [
    'plane',
    'car',
    'bird',
    'cat',
    'deer',
    'dog',
    'frog',
    'horse',
    'ship',
    'truck',
  ];

  static const double outputScale = 0.11211809515953064;
  static const int outputZeroPoint = -2;

  Interpreter? _interpreter;
  bool _isLoaded = false;
  bool get isLoaded => _isLoaded;

  Future<void> initialize() async {
    if (_isLoaded) return;
    try {
      final options = InterpreterOptions()..threads = 2;
      _interpreter = await Interpreter.fromAsset(
        modelAssetPath,
        options: options,
      );
      _interpreter!.allocateTensors();
      _isLoaded = true;
    } catch (e) {
      throw Exception('Failed to load TFLite model from $modelAssetPath: $e');
    }
  }

  Future<ClassificationResult> classifyImage(File imageFile) async {
    if (!_isLoaded || _interpreter == null) {
      return ClassificationResult.error('Interpreter is not initialized');
    }

    try {
      final bytes = await imageFile.readAsBytes();
      final decodedImage = img.decodeImage(bytes);
      if (decodedImage == null) {
        return ClassificationResult.error('Unable to decode image file');
      }

      final stopwatch = Stopwatch()..start();

      final inputBuffer = _preprocessImage(decodedImage);

      var outputBuffer = List.generate(
        1,
        (_) => List<int>.filled(10, 0),
      );

      _interpreter!.run(inputBuffer, outputBuffer);
      stopwatch.stop();

      final rawInt8Outputs = (outputBuffer)[0] as List<int>;
      return _postProcess(
        rawInt8Outputs,
        stopwatch.elapsedMicroseconds / 1000.0,
      );
    } catch (e) {
      return ClassificationResult.error('Inference error: $e');
    }
  }

  List<List<List<List<int>>>> _preprocessImage(img.Image srcImage) {
    final resized = img.copyResize(
      srcImage,
      width: inputSize,
      height: inputSize,
      interpolation: img.Interpolation.linear,
    );

    var input = List.generate(
      1,
      (_) => List.generate(
        inputSize,
        (y) => List.generate(inputSize, (x) {
          final pixel = resized.getPixel(x, y);
          final r = pixel.r.toInt();
          final g = pixel.g.toInt();
          final b = pixel.b.toInt();

          return [
            (r - 128).clamp(-128, 127),
            (g - 128).clamp(-128, 127),
            (b - 128).clamp(-128, 127),
          ];
        }),
      ),
    );

    return input;
  }

  ClassificationResult _postProcess(List<int> rawOutput, double latencyMs) {
    final logits = rawOutput
        .map((q) => (q - outputZeroPoint) * outputScale)
        .toList();

    final maxLogit = logits.reduce(math.max);
    final expScores = logits.map((l) => math.exp(l - maxLogit)).toList();
    final sumExp = expScores.reduce((a, b) => a + b);
    final probabilities = expScores.map((e) => e / sumExp).toList();

    int topIndex = 0;
    double maxProb = probabilities[0];
    for (int i = 1; i < probabilities.length; i++) {
      if (probabilities[i] > maxProb) {
        maxProb = probabilities[i];
        topIndex = i;
      }
    }

    final probMap = <String, double>{};
    for (int i = 0; i < labels.length; i++) {
      probMap[labels[i]] = probabilities[i];
    }

    if (maxProb >= confidenceThreshold) {
      return ClassificationResult(
        label: labels[topIndex],
        confidence: maxProb,
        isConfident: true,
        allProbabilities: probMap,
        inferenceTimeMs: latencyMs,
      );
    } else {
      return ClassificationResult.uncertain(
        confidence: maxProb,
        allProbabilities: probMap,
        inferenceTimeMs: latencyMs,
      );
    }
  }

  void dispose() {
    _interpreter?.close();
    _interpreter = null;
    _isLoaded = false;
  }
}
