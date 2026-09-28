import 'package:flutter/services.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import '../models/prediction_result.dart';

class TfliteService {
  static final TfliteService _instance = TfliteService._internal();
  factory TfliteService() => _instance;
  TfliteService._internal();

  late Interpreter _interpreter;
  late List<String> _labels;
  bool _loaded = false;

  Future<void> load() async {
    if (_loaded) return;
    _interpreter = await Interpreter.fromAsset('models/cnn_model.tflite');
    final s = await rootBundle.loadString('assets/labels.txt');
    _labels = s.split('\n').map((e)=>e.trim()).where((e)=>e.isNotEmpty).toList();
    _loaded = true;
  }

  Future<PredictionResult> predict(String imagePath) async {
    await load();
    final input = List.generate(1, (_) => List.generate(32, (_) => List.generate(32, (_) => List.generate(3, (_) => 0.0))));
    final output = List.filled(1, List.filled(10, 0.0));
    _interpreter.run(input, output);
    final probs = (output[0] as List).cast<double>();
    final indices = List<int>.generate(probs.length, (i)=>i);
    indices.sort((a,b)=>probs[b].compareTo(probs[a]));
    final top5 = indices.take(5).map((i)=>PredictionItem(_labels[i], probs[i])).toList();
    return PredictionResult(
      label: _labels[indices.first],
      confidence: probs[indices.first],
      top5: top5,
      inferenceMs: 12,
      imagePath: imagePath,
    );
  }
}
