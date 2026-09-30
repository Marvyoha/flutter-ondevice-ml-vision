class ClassificationResult {
  final String? label;
  final double confidence;
  final bool isConfident;
  final Map<String, double> allProbabilities;
  final double inferenceTimeMs;
  final String? error;

  const ClassificationResult({
    this.label,
    required this.confidence,
    required this.isConfident,
    required this.allProbabilities,
    required this.inferenceTimeMs,
    this.error,
  });

  factory ClassificationResult.uncertain({
    required double confidence,
    required Map<String, double> allProbabilities,
    required double inferenceTimeMs,
  }) {
    return ClassificationResult(
      label: null,
      confidence: confidence,
      isConfident: false,
      allProbabilities: allProbabilities,
      inferenceTimeMs: inferenceTimeMs,
    );
  }

  factory ClassificationResult.error(String message) {
    return ClassificationResult(
      label: null,
      confidence: 0.0,
      isConfident: false,
      allProbabilities: const {},
      inferenceTimeMs: 0.0,
      error: message,
    );
  }
}
