import 'package:flutter_riverpod/flutter_riverpod.dart';

extension AsyncValueStreamX<T> on AsyncValue<T> {
  /// Convert an [AsyncValue] into a single-subscription [Stream].
  Stream<T?> asStream() {
    return when<Stream<T?>>(
      data: (data) => Stream<T>.value(data),
      error: (err, st) => Stream<T>.error(err, st),
      loading: () => const Stream.empty(),
    );
  }
}
