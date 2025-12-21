import 'package:yaqeen_app/core/common/base_state.dart';
import 'package:yaqeen_app/features/home/models/home_model.dart';

class HomeState extends BaseStatusState {
  final HomeModel model;

  const HomeState({
    required this.model,
    super.isLoading,
    super.errorMessage,
  });

  HomeState copyWith({
    HomeModel? model,
    bool? isLoading,
    String? errorMessage,
  }) {
    return HomeState(
      model: model ?? this.model,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [model, isLoading, errorMessage];

  factory HomeState.initial() {
    return HomeState(
      model: const HomeModel(),
    );
  }
}

