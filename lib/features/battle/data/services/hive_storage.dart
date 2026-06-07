import 'package:hive_flutter/hive_flutter.dart';

/// Raw Hive access layer.
/// All app data lives in two boxes:
///   'user'     — single user profile (Map)
///   'queue'    — problem queue state (int pointer)
///
/// Nothing else should import Hive directly — go through this class.
class HiveStorage {
  static const String _userBox = 'user';
  static const String _queueBox = 'queue';

  static const String _userKey = 'profile';
  static const String _queueKey = 'pointer';

  // ── Singleton ────────────────────────────────────────────────────────────

  HiveStorage._();
  static final HiveStorage instance = HiveStorage._();

  late Box _user;
  late Box _queue;
  bool _initialised = false;

  // ── Init ─────────────────────────────────────────────────────────────────

  /// Call once from main() before runApp.
  Future<void> init() async {
    if (_initialised) return;
    await Hive.initFlutter();
    _user = await Hive.openBox(_userBox);
    _queue = await Hive.openBox(_queueBox);
    _initialised = true;
  }

  // ── User profile ─────────────────────────────────────────────────────────

  /// Returns raw Map or null if never saved.
  Map<dynamic, dynamic>? readUserProfile() {
    return _user.get(_userKey) as Map?;
  }

  Future<void> writeUserProfile(Map<String, dynamic> data) async {
    await _user.put(_userKey, data);
  }

  // ── Problem queue pointer ─────────────────────────────────────────────────

  int readQueuePointer() {
    return _queue.get(_queueKey, defaultValue: 0) as int;
  }

  Future<void> writeQueuePointer(int index) async {
    await _queue.put(_queueKey, index);
  }

  // ── Nuke everything (dev/testing only) ───────────────────────────────────

  Future<void> clearAll() async {
    await _user.clear();
    await _queue.clear();
  }
}