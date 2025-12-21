import 'package:yaqeen_app/core/common/base_state.dart';
import 'package:yaqeen_app/features/splash/models/splash_model.dart';

class SplashState extends BaseStatusState {
  final SplashModel model;

  const SplashState({
    required this.model,
    super.isLoading,
    super.errorMessage,
  });

  SplashState copyWith({
    SplashModel? model,
    bool? isLoading,
    String? errorMessage,
  }) {
    return SplashState(
      model: model ?? this.model,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [model, isLoading, errorMessage];

  factory SplashState.initial() {
    return SplashState(
      model: const SplashModel(),
    );
  }
}

