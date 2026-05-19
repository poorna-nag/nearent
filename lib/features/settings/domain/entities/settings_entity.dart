import 'package:equatable/equatable.dart';

class SettingsEntity extends Equatable {
  final bool isDarkMode;
  final bool notificationsEnabled;
  final String language;
  final double searchRadiusKm;

  const SettingsEntity({
    this.isDarkMode = false,
    this.notificationsEnabled = true,
    this.language = 'en',
    this.searchRadiusKm = 10.0,
  });

  SettingsEntity copyWith({
    bool? isDarkMode,
    bool? notificationsEnabled,
    String? language,
    double? searchRadiusKm,
  }) {
    return SettingsEntity(
      isDarkMode: isDarkMode ?? this.isDarkMode,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      language: language ?? this.language,
      searchRadiusKm: searchRadiusKm ?? this.searchRadiusKm,
    );
  }

  @override
  List<Object?> get props => [isDarkMode, notificationsEnabled, language, searchRadiusKm];
}
