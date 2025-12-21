import 'package:equatable/equatable.dart';

/// Base class for all Cubit states
abstract class BaseState extends Equatable {
  const BaseState();

  @override
  List<Object?> get props => [];
}

/// Base class for states that can be in loading, success, or error states
abstract class BaseStatusState extends BaseState {
  final bool isLoading;
  final String? errorMessage;

  const BaseStatusState({
    this.isLoading = false,
    this.errorMessage,
  });

  @override
  List<Object?> get props => [isLoading, errorMessage];

  bool get hasError => errorMessage != null;
  bool get isSuccess => !isLoading && !hasError;
}

