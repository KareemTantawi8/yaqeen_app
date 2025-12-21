import 'package:yaqeen_app/core/common/base_cubit.dart';
import 'package:yaqeen_app/core/utils/screenshot_utils.dart';
import 'package:yaqeen_app/features/home/cubit/home_state.dart';
import 'package:screenshot/screenshot.dart';
import 'package:yaqeen_app/core/di/injection_container.dart';

class HomeCubit extends BaseCubit<HomeState> {
  final ScreenshotController _screenshotController;

  HomeCubit({
    ScreenshotController? screenshotController,
  })  : _screenshotController = screenshotController ?? sl<ScreenshotController>(),
        super(HomeState.initial());

  ScreenshotController get screenshotController => _screenshotController;

  /// Increment counter
  void incrementCounter() {
    final newCounter = state.model.counter + 1;
    emit(state.copyWith(
      model: state.model.copyWith(counter: newCounter),
    ));
  }

  /// Take screenshot and share
  Future<void> takeScreenshot() async {
    await execute(
      action: () => ScreenshotUtils.captureSaveAndShare(_screenshotController),
      onStateChange: (isLoading, errorMessage) =>
          state.copyWith(isLoading: isLoading, errorMessage: errorMessage),
      onSuccess: (_) {
        // Screenshot shared successfully
      },
      onError: (error) {
        // Error handled in state
      },
    );
  }
}

