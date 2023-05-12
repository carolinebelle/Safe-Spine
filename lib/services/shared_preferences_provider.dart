import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesProvider {
  static SharedPreferencesProvider? _instance;
  final SharedPreferences _preferences;

  static Future<SharedPreferencesProvider> getInstance() async {
    if (_instance == null) {
      final sharedPreferences = await SharedPreferences.getInstance();
      _instance = SharedPreferencesProvider._(sharedPreferences);
    }
    return _instance!;
  }

  SharedPreferencesProvider._(SharedPreferences sharedPreferences)
      : _preferences = sharedPreferences;

  Timestamp getSyncDate() {
    final int? microseconds = _preferences.getInt('last_sync');

    if (microseconds != null) {
      return Timestamp.fromMicrosecondsSinceEpoch(microseconds);
    } else {
      return Timestamp.fromMicrosecondsSinceEpoch(0);
    }
  }

  Future<void> setSyncDate(Timestamp lastSync) async {
    await _preferences.setInt('last_sync', lastSync.microsecondsSinceEpoch);
  }
}
