/// Extensions on [Map] for index-based access.
extension MapExtensions on Map {
  /// Returns the entry at the given [index] in insertion order.
  MapEntry elementAt(int index) {
    return entries.elementAt(index);
  }

  E keyAt<E>(int index) {
    return keys.elementAt(index);
  }

  E valueAt<E>(int index) {
    return values.elementAt(index);
  }
}
