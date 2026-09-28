import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../models/history_item.dart';

class HistoryService {
  static Future<File> _file() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/history.json');
  }

  static Future<List<HistoryItem>> load() async {
    try {
      final f = await _file();
      if (!await f.exists()) return [];
      final content = await f.readAsString();
      final list = jsonDecode(content) as List;
      return list.map((e)=>HistoryItem.fromJson(e)).toList();
    } catch (_) { return []; }
  }

  static Future<void> save(List<HistoryItem> items) async {
    final f = await _file();
    await f.writeAsString(jsonEncode(items.map((e)=>e.toJson()).toList()));
  }

  static Future<void> add(HistoryItem item) async {
    final items = await load();
    items.insert(0, item);
    await save(items);
  }

  static Future<void> delete(String id) async {
    final items = await load();
    await save(items.where((e)=>e.id!=id).toList());
  }

  static Future<void> clear() async {
    await save([]);
  }
}
