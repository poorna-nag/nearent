import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../routes/app_routes.dart';
import '../bloc/settings_bloc.dart';
import '../bloc/settings_event.dart';
import '../bloc/settings_state.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<SettingsBloc>().add(const SettingsLoadRequested());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.settings),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: BlocBuilder<SettingsBloc, SettingsState>(
        builder: (context, state) {
          if (state is SettingsLoading) return const LoadingWidget();
          if (state is! SettingsLoaded) return const SizedBox.shrink();
          final s = state.settings;

          return ListView(
            children: [
              _sectionHeader('Appearance'),
              SwitchListTile(
                secondary: const Icon(Icons.dark_mode_outlined),
                title: const Text('Dark Mode'),
                subtitle: const Text('Switch between light and dark theme'),
                value: s.isDarkMode,
                activeThumbColor: AppColors.primary,
                onChanged: (v) => context.read<SettingsBloc>().add(
                      SettingsUpdateRequested(s.copyWith(isDarkMode: v)),
                    ),
              ),
              _sectionHeader('Notifications'),
              SwitchListTile(
                secondary: const Icon(Icons.notifications_outlined),
                title: const Text('Push Notifications'),
                subtitle: const Text('Receive alerts for chats and listings'),
                value: s.notificationsEnabled,
                activeThumbColor: AppColors.primary,
                onChanged: (v) => context.read<SettingsBloc>().add(
                      SettingsUpdateRequested(s.copyWith(notificationsEnabled: v)),
                    ),
              ),
              _sectionHeader('Discovery'),
              ListTile(
                leading: const Icon(Icons.radar_rounded),
                title: const Text('Search Radius'),
                subtitle: Text('${s.searchRadiusKm.toStringAsFixed(0)} km'),
                trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textHint),
                onTap: () => _showRadiusPicker(context, s.searchRadiusKm),
              ),
              _sectionHeader('About'),
              ListTile(
                leading: const Icon(Icons.help_outline_rounded),
                title: const Text(AppStrings.helpCenter),
                trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textHint),
                onTap: () => context.push(AppRoutes.help),
              ),
              ListTile(
                leading: const Icon(Icons.info_outline_rounded),
                title: const Text(AppStrings.about),
                trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textHint),
                onTap: () => context.push(AppRoutes.about),
              ),
              ListTile(
                leading: const Icon(Icons.privacy_tip_outlined),
                title: const Text(AppStrings.privacyPolicy),
                trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textHint),
                onTap: () {},
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppDimensions.md, AppDimensions.lg, AppDimensions.md, AppDimensions.xs,
      ),
      child: Text(
        title.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: AppColors.textSecondary,
              letterSpacing: 0.8,
            ),
      ),
    );
  }

  void _showRadiusPicker(BuildContext context, double current) {
    double picked = current;
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppDimensions.radiusXl)),
      ),
      builder: (_) => StatefulBuilder(
        builder: (ctx, setModal) => Padding(
          padding: const EdgeInsets.all(AppDimensions.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Search Radius', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: AppDimensions.lg),
              Text('${picked.toStringAsFixed(0)} km',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                      )),
              Slider(
                value: picked,
                min: 1,
                max: 50,
                divisions: 49,
                activeColor: AppColors.primary,
                onChanged: (v) => setModal(() => picked = v),
              ),
              const SizedBox(height: AppDimensions.md),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    context.read<SettingsBloc>().add(
                          SettingsUpdateRequested(
                            (context.read<SettingsBloc>().state as SettingsLoaded)
                                .settings
                                .copyWith(searchRadiusKm: picked),
                          ),
                        );
                    Navigator.pop(ctx);
                  },
                  child: const Text('Apply'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
