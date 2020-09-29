import 'package:shared_preferences/shared_preferences.dart';

/// Modified version of shared preferences
/// Saving data in local storage
class Saver {
  Saver._();
  static final Saver instance = Saver._();
  factory Saver() {
    return instance;
  }

  Future<dynamic> _doWork(Function(SharedPreferences) work) async {
    return await SharedPreferences.getInstance()
        .then(work)
        .catchError((e) => throw Exception(e));
  }

  Future<dynamic> retrieve(String key) async {
    return await _doWork((pref) {
      return (pref.containsKey(key)) ? pref.get(key) : null;
    }).catchError((e) => throw Exception(e));
  }

  Future<bool> save(String key, dynamic value) async {
    return await _doWork((pref) async {
      try {
        if (value is String) {
          return await pref.setString(key, value);
        } else if (value is int) {
          return await pref.setInt(key, value);
        } else if (value is bool) {
          return await pref.setBool(key, value);
        } else if (value is double) {
          return await pref.setDouble(key, value);
        } else if (value is List<String>) {
          return await pref.setStringList(key, value);
        } else {
          throw Exception('Type ${value.runtimeType} is undefined');
        }
      } catch (_) {
        throw Exception('Failed to save $key: ${value.toString()}');
      }
    }).catchError((e) => throw Exception(e));
  }

  Future<bool> validateKey(String key) async {
    return await _doWork((pref) {
      return pref.containsKey(key);
    }).catchError((e) => throw Exception(e));
  }

  Future<bool> remove(String key) async {
    return await _doWork((pref) async {
      return await pref.remove(key);
    }).catchError((e) => throw Exception(e));
  }

  Future<bool> removeList(List<String> keys) async {
    return await _doWork((pref) async {
      for (var key in keys) {
        if (pref.containsKey(key)) {
          await pref.remove(key);
        }
      }
    }).catchError((e) => throw Exception(e));
  }

  Future<bool> clearSession() async {
    return await _doWork((pref) async {
      return await pref.clear();
    }).catchError((e) => throw Exception(e));
  }

  Future<void> reload() async {
    await _doWork((pref) async {
      await pref.reload();
    }).catchError((e) => throw Exception(e));
  }
}
