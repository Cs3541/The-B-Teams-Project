import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/settings_model.dart';

class SettingsPresenter extends ChangeNotifier {
  static const _storageKey = 'background_color';
  BackgroundColor _background = BackgroundColor.defaultColor;
  bool _changed = false;

  BackgroundColor get background => _background;

  Future<void> load() async {
    final preferences = await SharedPreferences.getInstance();
    if (_changed) return;
    final saved = preferences.getString(_storageKey);
    _background = BackgroundColor.values.firstWhere(
      (option) => option.name == saved,
      orElse: () => BackgroundColor.defaultColor,
    );
    notifyListeners();
  }

  Future<void> setBackground(BackgroundColor background) async {
    _changed = true;
    _background = background;
    notifyListeners();
    final preferences = await SharedPreferences.getInstance();
    final saved = await preferences.setString(_storageKey, background.name);
    if (!saved) throw Exception('Could not save the background color.');
  }
}
