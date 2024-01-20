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

  Iterable<E> shuffled([Random? random]) {
    List<E> list = [...this];
    list.shuffle(random);
    return list;
  }

  Iterable<E> sorted([int Function(E, E)? compare]) {
    List<E> list = [...this];
    list.sort(compare);
    return list;
  }

}
