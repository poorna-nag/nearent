import '../../domain/entities/settings_entity.dart';

class SettingsModel extends SettingsEntity {
  const SettingsModel({
    super.isDarkMode,
    super.notificationsEnabled,
    super.language,
    super.searchRadiusKm,
  });

  factory SettingsModel.fromMap(Map<String, dynamic> map) {
    return SettingsModel(
      isDarkMode: map['isDarkMode'] as bool? ?? false,
      notificationsEnabled: map['notificationsEnabled'] as bool? ?? true,
      language: map['language'] as String? ?? 'en',
      searchRadiusKm: (map['searchRadiusKm'] as num?)?.toDouble() ?? 10.0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'isDarkMode': isDarkMode,
      'notificationsEnabled': notificationsEnabled,
      'language': language,
      'searchRadiusKm': searchRadiusKm,
    };
  }

  factory SettingsModel.fromEntity(SettingsEntity entity) {
    return SettingsModel(
      isDarkMode: entity.isDarkMode,
      notificationsEnabled: entity.notificationsEnabled,
      language: entity.language,
      searchRadiusKm: entity.searchRadiusKm,
    );
  }
}
