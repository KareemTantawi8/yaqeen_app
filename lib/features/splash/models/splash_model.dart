import 'package:equatable/equatable.dart';

class SplashModel extends Equatable {
  final bool isInitialized;

  const SplashModel({
    this.isInitialized = false,
  });

  SplashModel copyWith({
    bool? isInitialized,
  }) {
    return SplashModel(
      isInitialized: isInitialized ?? this.isInitialized,
    );
  }

  @override
  List<Object?> get props => [isInitialized];
}

