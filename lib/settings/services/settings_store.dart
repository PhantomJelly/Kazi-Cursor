import 'package:flutter/foundation.dart';
import 'package:kazi/settings/models/app_language.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Language and the one notification toggle that the app actually honours.
class SettingsStore extends ChangeNotifier {
  SettingsStore._();

  static final SettingsStore instance = SettingsStore._();

  static const _languageKey = 'kazi.language';
  static const _jobUpdatesKey = 'kazi.notify.jobs';

  SharedPreferences? _prefs;

  AppLanguage language = AppLanguage.english;
  bool jobUpdates = true;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    language = AppLanguage.values.firstWhere(
      (value) => value.name == _prefs!.getString(_languageKey),
      orElse: () => AppLanguage.english,
    );
    jobUpdates = _prefs!.getBool(_jobUpdatesKey) ?? true;
    notifyListeners();
  }

  Future<void> setLanguage(AppLanguage value) async {
    language = value;
    notifyListeners();
    await _prefs?.setString(_languageKey, value.name);
  }

  Future<void> setJobUpdates(bool value) async {
    jobUpdates = value;
    notifyListeners();
    await _prefs?.setBool(_jobUpdatesKey, value);
  }
}
