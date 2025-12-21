import 'package:yaqeen_app/core/common/base_cubit.dart';
import 'package:yaqeen_app/core/common/result.dart';
import 'package:yaqeen_app/features/splash/cubit/splash_state.dart';

class SplashCubit extends BaseCubit<SplashState> {
  SplashCubit() : super(SplashState.initial()) {
    _initialize();
  }

  Future<void> _initialize() async {
    await execute(
      action: () => _performInitialization(),
      onStateChange: (isLoading, errorMessage) =>
          state.copyWith(isLoading: isLoading, errorMessage: errorMessage),
      onSuccess: (_) {
        emit(state.copyWith(
          model: state.model.copyWith(isInitialized: true),
        ));
      },
      onError: (_) {
        // Handle initialization error
      },
    );
  }

  /// Retry initialization
  void retry() {
    _initialize();
  }

  Future<Result<void>> _performInitialization() async {
    try {
      // Simulate initialization delay (e.g., loading config, checking auth, etc.)
      // Dependency injection is already initialized in main.dart
      await Future.delayed(const Duration(seconds: 2));
      
      return const Success(null);
    } catch (e) {
      return Failure('Initialization failed: $e');
    }
  }
}

