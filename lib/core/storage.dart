import 'package:hive_flutter/hive_flutter.dart';

/// A tiny key-value store so features can persist data without knowing
/// about Hive, and tests can use an in-memory version.
abstract class KeyValueStore {
  dynamic read(String key);
  Future<void> write(String key, dynamic value);
}

class HiveStore implements KeyValueStore {
  HiveStore(this._box);

  static Future<HiveStore> open(String name) async => HiveStore(await Hive.openBox(name));

  final Box _box;

  @override
  dynamic read(String key) => _box.get(key);

  @override
  Future<void> write(String key, dynamic value) => _box.put(key, value);
}

class MemoryStore implements KeyValueStore {
  final Map<String, dynamic> data = {};

  @override
  dynamic read(String key) => data[key];

  @override
  Future<void> write(String key, dynamic value) async => data[key] = value;
}
