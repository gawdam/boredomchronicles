import 'dart:async';

class ValueMonitor {
  late final Duration debounceDuration;
  late final Function(double) onChange;
  Timer? _timer;
  dynamic? _lastValue;

  ValueMonitor(this.debounceDuration, this.onChange);

  void setValue(dynamic value) {
    _lastValue = value;
    _timer?.cancel();
    print("last value : $_lastValue");
    _timer = Timer(debounceDuration, () {
      onChange(_lastValue);

      _lastValue = null;
    });
  }
}
