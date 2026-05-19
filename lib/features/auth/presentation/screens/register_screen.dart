import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: AppColors.error),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_rounded),
            onPressed: () => context.pop(),
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppDimensions.xl),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader().animate().fadeIn().slideY(begin: -0.2),
                  const SizedBox(height: AppDimensions.xl),
                  _buildForm().animate().fadeIn(delay: 200.ms),
                  const SizedBox(height: AppDimensions.xl),
                  _buildSubmitButton().animate().fadeIn(delay: 350.ms),
                  const SizedBox(height: AppDimensions.lg),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        AppStrings.alreadyHaveAccount,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      GestureDetector(
                        onTap: () => context.pop(),
                        child: const Text(
                          AppStrings.signIn,
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Create account',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: AppDimensions.xs),
        Text(
          'Join the local community marketplace',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildForm() {
    return Column(
      children: [
        AppTextField(
          label: AppStrings.fullName,
          hint: 'Your full name',
          controller: _nameController,
          validator: Validators.name,
          prefixIcon: const Icon(Icons.person_outline, color: AppColors.textSecondary),
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: AppDimensions.md),
        AppTextField(
          label: AppStrings.emailAddress,
          hint: 'you@example.com',
          controller: _emailController,
          validator: Validators.email,
          keyboardType: TextInputType.emailAddress,
          prefixIcon: const Icon(Icons.email_outlined, color: AppColors.textSecondary),
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: AppDimensions.md),
        AppTextField(
          label: AppStrings.password,
          hint: 'At least 6 characters',
          controller: _passwordController,
          validator: Validators.password,
          isPassword: true,
          prefixIcon: const Icon(Icons.lock_outline, color: AppColors.textSecondary),
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: AppDimensions.md),
        AppTextField(
          label: AppStrings.confirmPassword,
          hint: 'Repeat password',
          controller: _confirmPasswordController,
          validator: (v) => Validators.confirmPassword(v, _passwordController.text),
          isPassword: true,
          prefixIcon: const Icon(Icons.lock_outline, color: AppColors.textSecondary),
          textInputAction: TextInputAction.done,
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) => AppButton(
        text: AppStrings.signUp,
        isLoading: state is AuthLoading,
        onPressed: _register,
      ),
    );
  }

  void _register() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthBloc>().add(AuthSignUpWithEmailPassword(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
      ));
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}
