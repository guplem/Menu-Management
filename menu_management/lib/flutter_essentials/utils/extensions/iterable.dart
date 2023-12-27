import "dart:math";

extension IterableExtensions<E> on Iterable<E> {
  E? firstWhereOrNull(bool Function(E) test) {
    for (E element in this) {
      if (test(element)) return element;
    }
    return null;
  }

  E? get firstOrNull {
    for (E element in this) {
      return element;
    }
    return null;
  }

  E? get lastOrNull {
    if (isNotEmpty) {
      return elementAt(length - 1);
    }

    return null;
  }

  E? getRandomElement({int? seed}) {
    if (isEmpty) {
      return null;
    }

    if (seed != null) {
      final Random random = Random(seed);
      return elementAt(random.nextInt(length));
    } else {
      return elementAt(Random().nextInt(length));
    }

  }
}
