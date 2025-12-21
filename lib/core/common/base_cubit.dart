import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yaqeen_app/core/common/base_state.dart';
import 'package:yaqeen_app/core/common/result.dart';

/// Base class for all Cubits with common functionality
abstract class BaseCubit<T extends BaseState> extends Cubit<T> {
  BaseCubit(super.initialState);

  /// Helper method to handle async operations with loading and error states
  Future<void> execute<TResult>({
    required Future<Result<TResult>> Function() action,
    required T Function(bool isLoading, String? errorMessage) onStateChange,
    Function(TResult data)? onSuccess,
    Function(String error)? onError,
  }) async {
    emit(onStateChange(true, null));
    
    try {
      final result = await action();
      
      result.when(
        success: (data) {
          onSuccess?.call(data);
          emit(onStateChange(false, null));
        },
        failure: (error) {
          onError?.call(error);
          emit(onStateChange(false, error));
        },
      );
    } catch (e) {
      final errorMessage = e.toString();
      onError?.call(errorMessage);
      emit(onStateChange(false, errorMessage));
    }
  }
}

