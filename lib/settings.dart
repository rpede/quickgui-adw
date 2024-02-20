import 'dart:io';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String _kWorkingDirectory = 'workingDirectory';
const String _kThemeMode = 'themeMode';
const String _kCurrentLocale = 'currentLocale';

class Settings extends ChangeNotifier {
  final SharedPreferences _storage;

  Settings(this._storage);

  String? get workingDirectory => _storage.getString(_kWorkingDirectory);

  setWorkingDirectory(String? value) {
    _setOrRemoveString(_kWorkingDirectory, value);
    notifyListeners();
  }

  ThemeMode get themeMode => switch (_storage.getBool(_kThemeMode)) {
        true => ThemeMode.dark,
        false => ThemeMode.light,
        null => ThemeMode.system,
      };

  setThemeMode(ThemeMode value) {
    if (value == ThemeMode.system) {
      _removeIfPresent(_kThemeMode);
    } else {
      _storage.setBool(_kThemeMode, value == ThemeMode.dark);
    }
    notifyListeners();
  }

  String? get locale =>
      _storage.getString(_kCurrentLocale) ?? Platform.localeName;

  setLocale(String? value) {
    _setOrRemoveString(_kCurrentLocale, value);
    notifyListeners();
  }

  void _setOrRemoveString(String key, String? value) {
    if (value == null) {
      _removeIfPresent(key);
    } else {
      _storage.setString(key, value);
    }
  }

  void _removeIfPresent(String key) {
    if (_storage.containsKey(key)) {
      _storage.remove(key);
    }
  }
}
