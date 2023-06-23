import 'dart:async';
import 'dart:ui';

class StreamSubscriptionWrapper<T> {
  StreamSubscriptionWrapper(this._subscription, this._onCancel);
  final StreamSubscription<T> _subscription;
  final VoidCallback _onCancel;
  bool isCanceled = false;

  Future<void> cancel() async {
    await _subscription.cancel();
    isCanceled = true;
    _onCancel();
  }

  void onData(void Function(T data)? handleData) =>
      _subscription.onData(handleData);
  void onError(Function? handleError) => _subscription.onError(handleError);
  void onDone(void Function()? handleDone) => _subscription.onDone(handleDone);
  void pause([Future<void>? resumeSignal]) => _subscription.pause(resumeSignal);
  void resume() => _subscription.resume();
  bool get isPaused => _subscription.isPaused;
}
