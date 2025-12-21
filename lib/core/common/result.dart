import 'package:equatable/equatable.dart';

/// A result type that represents either success or failure
sealed class Result<T> extends Equatable {
  const Result();

  R when<R>({
    required R Function(T data) success,
    required R Function(String message) failure,
  }) {
    return switch (this) {
      Success<T>(:final data) => success(data),
      Failure<T>(:final message) => failure(message),
    };
  }

  bool get isSuccess => this is Success<T>;
  bool get isFailure => this is Failure<T>;

  T? get dataOrNull => switch (this) {
        Success<T>(:final data) => data,
        Failure<T>() => null,
      };

  String? get errorOrNull => switch (this) {
        Success<T>() => null,
        Failure<T>(:final message) => message,
      };
}

class Success<T> extends Result<T> {
  final T data;

  const Success(this.data);

  @override
  List<Object?> get props => [data];
}

class Failure<T> extends Result<T> {
  final String message;

  const Failure(this.message);

  @override
  List<Object?> get props => [message];
}

