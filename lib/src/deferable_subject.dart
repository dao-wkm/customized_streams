part of customized_streams;

///
/// 1.  defer stream
/// 2.  broadcast stream (reusable: true)
/// 3.  transform I stream
///
class DeferableSubject<T> {
  StreamSubscription<T> outputSubscription;
  Stream<T> outputStream;
  dynamic _lastestValue;
  StreamController<T> controller;
  bool isDisposed;
  DeferableSubject(
      {Stream<T> Function(Stream<T> stream) transformInput,
      bool cacheLatest = true}) {
    controller = StreamController<T>();
    Stream<T> inputStream;
    if (transformInput != null) {
      inputStream = transformInput(controller.stream);
    } else {
      inputStream = controller.stream;
    }

    inputStream = inputStream.asBroadcastStream();

    outputSubscription = inputStream.listen(null);
    if (cacheLatest) {
      outputStream = DeferStream(
          () => observableOutput
              .startWith(isDisposed == true ? null : _lastestValue),
          reusable: true);
    } else {
      outputStream = inputStream;
    }
  }
  T get output => _lastestValue;
  set input(T value) {
    if (isDisposed == true) return;
    _lastestValue = value;
    controller.add(value);
  }

  dispose() {
    isDisposed = true;
    outputSubscription.cancel();
    controller.close();
    outputStream.drain();
  }
}
