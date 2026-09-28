class HistoryItem {
  final String id;
  final String imagePath;
  final String label;
  final double confidence;
  final DateTime timestamp;

  HistoryItem({
    required this.id,
    required this.imagePath,
    required this.label,
    required this.confidence,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'imagePath': imagePath,
    'label': label,
    'confidence': confidence,
    'timestamp': timestamp.toIso8601String(),
  };

  factory HistoryItem.fromJson(Map<String, dynamic> json) => HistoryItem(
    id: json['id'],
    imagePath: json['imagePath'],
    label: json['label'],
    confidence: json['confidence'],
    timestamp: DateTime.parse(json['timestamp']),
  );
}
