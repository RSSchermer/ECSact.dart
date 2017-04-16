import 'dart:async';

class ChangeRecorder<T> {
  final Stream<T> stream;

  List<T> _recording;

  Completer<Iterable<T>> _completer;

  StreamSubscription<T> _subscription;

  ChangeRecorder(this.stream);

  Future<Iterable<T>> start() {
    _completer = new Completer();
    _recording = [];

    _subscription = stream.listen((t) => _recording.add(t));

    return _completer.future;
  }

  void stop() {
    _subscription.cancel();
    _completer.complete(_recording);
  }
}
