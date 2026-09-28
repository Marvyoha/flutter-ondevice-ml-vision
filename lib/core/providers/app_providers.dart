import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../services/tflite_service.dart';
import '../services/history_service.dart';
import '../models/history_item.dart';

final themeProvider = StateProvider<bool>((ref) => false);

final onboardingProvider = FutureProvider<bool>((ref) async {
  const storage = FlutterSecureStorage();
  final val = await storage.read(key: 'onboarding_complete');
  return val == 'true';
});

final tfliteServiceProvider = Provider((ref) => TfliteService());

final historyProvider = StateNotifierProvider<HistoryNotifier, AsyncValue<List<HistoryItem>>>((ref) {
  return HistoryNotifier();
});

class HistoryNotifier extends StateNotifier<AsyncValue<List<HistoryItem>>> {
  HistoryNotifier() : super(const AsyncValue.loading()) {
    _load();
  }
  Future<void> _load() async {
    state = await AsyncValue.guard(() => HistoryService.load());
  }
  Future<void> refresh() => _load();
}
