import 'package:equatable/equatable.dart';

class HomeModel extends Equatable {
  final int counter;

  const HomeModel({
    this.counter = 0,
  });

  HomeModel copyWith({
    int? counter,
  }) {
    return HomeModel(
      counter: counter ?? this.counter,
    );
  }

  @override
  List<Object?> get props => [counter];
}

