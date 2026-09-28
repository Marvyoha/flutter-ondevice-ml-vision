class PredictionResult {
  final String label;
  final double confidence;
  final List<PredictionItem> top5;
  final int inferenceMs;
  final String imagePath;

  PredictionResult({
    required this.label,
    required this.confidence,
    required this.top5,
    required this.inferenceMs,
    required this.imagePath,
  });
}

class PredictionItem {
  final String label;
  final double confidence;
  PredictionItem(this.label, this.confidence);
}
