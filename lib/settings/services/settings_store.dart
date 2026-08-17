import 'package:flutter/foundation.dart';
import 'package:kazi/settings/models/app_language.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsStore extends ChangeNotifier {
  SettingsStore._();

  static final SettingsStore instance = SettingsStore._();

  static const _languageKey = 'kazi.language';
  static const _jobUpdatesKey = 'kazi.notify.jobs';
  static const _messagesKey = 'kazi.notify.messages';
  static const _remindersKey = 'kazi.notify.reminders';
  static const _marketingKey = 'kazi.notify.marketing';

  SharedPreferences? _prefs;

  AppLanguage language = AppLanguage.english;
  bool jobUpdates = true;
  bool messages = true;
  bool reminders = true;
  bool marketing = false;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    language = AppLanguage.values.firstWhere(
      (value) => value.name == _prefs!.getString(_languageKey),
      orElse: () => AppLanguage.english,
    );
    jobUpdates = _prefs!.getBool(_jobUpdatesKey) ?? true;
    messages = _prefs!.getBool(_messagesKey) ?? true;
    reminders = _prefs!.getBool(_remindersKey) ?? true;
    marketing = _prefs!.getBool(_marketingKey) ?? false;
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

  Future<void> setMessages(bool value) async {
    messages = value;
    notifyListeners();
    await _prefs?.setBool(_messagesKey, value);
  }

  Future<void> setReminders(bool value) async {
    reminders = value;
    notifyListeners();
    await _prefs?.setBool(_remindersKey, value);
  }

  Future<void> setMarketing(bool value) async {
    marketing = value;
    notifyListeners();
    await _prefs?.setBool(_marketingKey, value);
  }
}
