import "dart:math";

/// Extensions on [Iterable] for common collection operations.
extension IterableExtensions<E> on Iterable<E> {
  /// Returns the first element that satisfies [test], or null if none match.
  E? firstWhereOrNull(bool Function(E) test) {
    for (E element in this) {
      if (test(element)) return element;
    }
    return null;
  }

  /// Returns the first element, or null if the iterable is empty.
  E? get firstOrNull {
    for (E element in this) {
      return element;
    }
    return null;
  }

  /// Returns the last element, or null if the iterable is empty.
  E? get lastOrNull {
    if (isNotEmpty) {
      return elementAt(length - 1);
    }
    return null;
  }

  /// Returns a random element, or null if the iterable is empty.
  ///
  /// Optionally accepts a [seed] for deterministic selection.
  E? getRandomElement({int? seed}) {
    if (isEmpty) return null;
    if (seed != null) {
      final Random random = Random(seed);
      return elementAt(random.nextInt(length));
    } else {
      return elementAt(Random().nextInt(length));
    }
  }

  /// Returns true if all elements satisfy the given [test].
  bool all(bool Function(E) test) {
    for (E element in this) {
      if (!test(element)) return false;
    }
    return true;
  }

  /// Returns true if at least one element in [other] is contained in this iterable.
  bool containsAny(Iterable<E> other) {
    for (E element in other) {
      if (contains(element)) return true;
    }
    return false;
  }

  /// Counts the number of elements that satisfy [test].
  int count(bool Function(E) test) {
    return where(test).length;
  }

  /// Returns the element at [index], or null if the index is out of bounds.
  E? elementAtOrNull(int index) {
    if (index < 0 || index >= length) return null;
    try {
      return elementAt(index);
    } catch (_) {
      return null;
    }
  }

  /// Returns the index of the first element matching [test], or null if none found.
  int? indexWhereOrNull(bool Function(E element) test) {
    int index = 0;
    for (E element in this) {
      if (test(element)) return index;
      index++;
    }
    return null;
  }

  /// Returns a new iterable with elements in shuffled order.
  Iterable<E> shuffled([Random? random]) {
    List<E> list = [...this];
    list.shuffle(random);
    return list;
  }

  /// Returns a new iterable with elements sorted by [compare].
  Iterable<E> sorted([int Function(E, E)? compare]) {
    List<E> list = [...this];
    list.sort(compare);
    return list;
  }

  /// Joins the first [quantity] elements with [separator].
  String joinElements(int quantity, [String separator = ""]) {
    return take(quantity).join(separator);
  }

  /// Returns a JSON-like prettified string of all elements.
  String get jsonPrettified => "[\n${map((E e) => "  $e").join(",\n")}\n]";
}

/// Extensions on [Iterable] of nullable elements.
extension NullableIterableExtensions<E> on Iterable<E?> {
  /// Filters out null elements and returns a non-nullable iterable.
  Iterable<E> whereNotNull() {
    return where((E? e) => e != null).map((E? e) => e!);
  }
}
