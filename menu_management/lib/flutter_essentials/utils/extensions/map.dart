extension MapExtensions on Map {
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
