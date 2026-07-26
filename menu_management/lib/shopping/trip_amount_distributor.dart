import "package:menu_management/ingredients/models/ingredient.dart";
import "package:menu_management/recipes/models/quantity.dart";
import "package:menu_management/shopping/multi_trip_planner.dart";

/// One ingredient's amount to buy on a single shopping trip, in the SAME normalized unit(s)
/// the on-screen shopping list shows.
class TripAllocation {
  const TripAllocation({required this.weekIndex, required this.quantities, required this.freezeOnArrival});

  final int weekIndex;

  /// Amounts in the on-screen (normalized) units, each a whole number.
  final List<Quantity> quantities;

  /// True when the planner marked this ingredient's trip items as frozen on arrival.
  final bool freezeOnArrival;
}

/// Splits an ingredient's on-screen remaining amount across the trips the planner chose, so the
/// copied per-trip lines match the on-screen list exactly.
///
/// Why this exists: the on-screen list normalizes units (e.g. pieces to grams via `gramsPerPiece`)
/// and rounds the total once, while the planner works on the raw, per-day cooking timeline in the
/// recipe's own units. Reading the planner output straight into the copied text made the copy show
/// a different unit or a total that was off by one from the page. This function keeps the on-screen
/// unit and total ([pageRemaining]) and only borrows the planner's [trips] to decide how to spread
/// that total across the weeks.
///
/// [pageRemaining] must be the on-screen remaining (normalized, owned-subtracted, already rounded).
/// Each trip's share of a unit is weighted by that trip's raw need for this ingredient, expressed in
/// grams so pieces and volume compare on the same scale. A largest-remainder split keeps every
/// per-trip amount a whole number while guaranteeing they sum to [pageRemaining].
List<TripAllocation> distributeRemainingAcrossTrips({
  required Ingredient ingredient,
  required List<Quantity> pageRemaining,
  required List<ShoppingTrip> trips,
}) {
  // Weeks (in trip order) that include this ingredient, each with its raw grams-equivalent weight
  // and whether any of its items must be frozen on arrival.
  List<int> weeks = [];
  Map<int, double> weightByWeek = {};
  Map<int, bool> freezeByWeek = {};

  for (ShoppingTrip trip in trips) {
    double weight = 0;
    bool freeze = false;
    bool present = false;
    for (TripItem item in trip.items) {
      if (item.ingredientId != ingredient.id) continue;
      present = true;
      weight += ingredient.toGrams(Quantity(amount: item.amount, unit: item.unit)) ?? item.amount;
      if (item.freezeOnArrival) freeze = true;
    }
    if (present) {
      weeks.add(trip.weekIndex);
      weightByWeek[trip.weekIndex] = weight;
      freezeByWeek[trip.weekIndex] = freeze;
    }
  }

  if (weeks.isEmpty) return const [];

  Map<int, List<Quantity>> quantitiesByWeek = {for (int week in weeks) week: []};

  for (Quantity quantity in pageRemaining) {
    int total = quantity.amount.round();
    if (total <= 0) continue;
    Map<int, int> perWeek = _largestRemainderSplit(total: total, weeks: weeks, weights: weightByWeek);
    for (int week in weeks) {
      int amount = perWeek[week] ?? 0;
      if (amount > 0) quantitiesByWeek[week]!.add(Quantity(amount: amount.toDouble(), unit: quantity.unit));
    }
  }

  List<TripAllocation> result = [];
  for (int week in weeks) {
    List<Quantity> quantities = quantitiesByWeek[week]!;
    if (quantities.isEmpty) continue;
    result.add(TripAllocation(weekIndex: week, quantities: quantities, freezeOnArrival: freezeByWeek[week] ?? false));
  }
  return result;
}

/// Distributes an integer [total] across [weeks] proportionally to [weights], using the
/// largest-remainder method so the parts always sum to [total]. When every weight is zero, the
/// whole total lands on the first week (it still has to be bought somewhere).
Map<int, int> _largestRemainderSplit({required int total, required List<int> weeks, required Map<int, double> weights}) {
  double weightSum = weeks.fold(0, (double sum, int week) => sum + (weights[week] ?? 0));

  Map<int, int> result = {for (int week in weeks) week: 0};
  if (weightSum <= 0) {
    result[weeks.first] = total;
    return result;
  }

  Map<int, double> fractional = {};
  int assigned = 0;
  for (int week in weeks) {
    double exact = total * (weights[week] ?? 0) / weightSum;
    int floor = exact.floor();
    result[week] = floor;
    fractional[week] = exact - floor;
    assigned += floor;
  }

  int remaining = total - assigned;
  // Give leftover units to the largest fractional parts; break ties by trip order (earliest first).
  List<int> order = [...weeks]
    ..sort((int a, int b) {
      int byFraction = fractional[b]!.compareTo(fractional[a]!);
      if (byFraction != 0) return byFraction;
      return weeks.indexOf(a).compareTo(weeks.indexOf(b));
    });
  for (int i = 0; i < remaining; i++) {
    int week = order[i % order.length];
    result[week] = result[week]! + 1;
  }
  return result;
}
