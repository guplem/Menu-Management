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

  E? get randomElement {
    return elementAt(Random().nextInt(length));
  }
}
