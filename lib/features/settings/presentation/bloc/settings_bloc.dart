import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/settings_repository.dart';
import 'settings_event.dart';
import 'settings_state.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final SettingsRepository _repository;

  SettingsBloc({required SettingsRepository repository})
      : _repository = repository,
        super(const SettingsInitial()) {
    on<SettingsLoadRequested>(_onLoad);
    on<SettingsUpdateRequested>(_onUpdate);
  }

  Future<void> _onLoad(SettingsLoadRequested event, Emitter<SettingsState> emit) async {
    emit(const SettingsLoading());
    try {
      final settings = await _repository.getSettings();
      emit(SettingsLoaded(settings));
    } catch (e) {
      emit(SettingsError(e.toString()));
    }
  }

  Future<void> _onUpdate(SettingsUpdateRequested event, Emitter<SettingsState> emit) async {
    try {
      await _repository.saveSettings(event.settings);
      emit(SettingsLoaded(event.settings));
    } catch (e) {
      emit(SettingsError(e.toString()));
    }
  }
}
