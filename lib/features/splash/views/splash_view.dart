import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yaqeen_app/core/style/app_colors.dart';
import 'package:yaqeen_app/features/home/views/home_view.dart';
import 'package:yaqeen_app/features/splash/cubit/splash_cubit.dart';
import 'package:yaqeen_app/features/splash/cubit/splash_state.dart';
import 'package:yaqeen_app/features/splash/widgets/splash_background.dart';
import 'package:yaqeen_app/features/splash/widgets/splash_logo.dart';

class SplashView extends StatelessWidget {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SplashCubit(),
      child: const _SplashViewContent(),
    );
  }
}

class _SplashViewContent extends StatelessWidget {
  const _SplashViewContent();

  @override
  Widget build(BuildContext context) {
    return BlocListener<SplashCubit, SplashState>(
      listener: (context, state) {
        if (state.model.isInitialized && state.isSuccess) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const HomeView()),
          );
        }
      },
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: Scaffold(
          backgroundColor: AppColors.primary,
          body: Stack(
            children: [
              // Background with patterns
              const SplashBackground(),
              // Main content
              SafeArea(
                child: BlocBuilder<SplashCubit, SplashState>(
                  builder: (context, state) {
                    if (state.hasError) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.error_outline,
                                color: AppColors.textWhite,
                                size: 48,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                state.errorMessage ?? 'An error occurred',
                                style: const TextStyle(
                                  color: AppColors.textWhite,
                                  fontSize: 16,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 24),
                              ElevatedButton(
                                onPressed: () =>
                                    context.read<SplashCubit>().retry(),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.textWhite,
                                  foregroundColor: AppColors.primary,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 32,
                                    vertical: 12,
                                  ),
                                ),
                                child: const Text('Retry'),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Logo with Arabic text
                          const SplashLogo(),
                          const SizedBox(height: 48),
                          // Loading indicator
                          if (state.isLoading)
                            const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  AppColors.textWhite,
                                ),
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

