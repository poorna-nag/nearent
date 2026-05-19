import 'package:equatable/equatable.dart';
import '../../domain/entities/settings_entity.dart';

abstract class SettingsEvent extends Equatable {
  const SettingsEvent();
  @override
  List<Object?> get props => [];
}

class SettingsLoadRequested extends SettingsEvent {
  const SettingsLoadRequested();
}

class SettingsUpdateRequested extends SettingsEvent {
  final SettingsEntity settings;
  const SettingsUpdateRequested(this.settings);
  @override
  List<Object?> get props => [settings];
}
