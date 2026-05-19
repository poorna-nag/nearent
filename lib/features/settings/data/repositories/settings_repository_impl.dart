import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/settings_entity.dart';
import '../../domain/repositories/settings_repository.dart';
import '../models/settings_model.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  static const _keyDarkMode = 'settings_dark_mode';
  static const _keyNotifications = 'settings_notifications';
  static const _keyLanguage = 'settings_language';
  static const _keyRadius = 'settings_radius';

  @override
  Future<SettingsEntity> getSettings() async {
    final prefs = await SharedPreferences.getInstance();
    return SettingsModel.fromMap({
      'isDarkMode': prefs.getBool(_keyDarkMode),
      'notificationsEnabled': prefs.getBool(_keyNotifications),
      'language': prefs.getString(_keyLanguage),
      'searchRadiusKm': prefs.getDouble(_keyRadius),
    });
  }

  @override
  Future<void> saveSettings(SettingsEntity settings) async {
    final prefs = await SharedPreferences.getInstance();
    await Future.wait([
      prefs.setBool(_keyDarkMode, settings.isDarkMode),
      prefs.setBool(_keyNotifications, settings.notificationsEnabled),
      prefs.setString(_keyLanguage, settings.language),
      prefs.setDouble(_keyRadius, settings.searchRadiusKm),
    ]);
  }
}
