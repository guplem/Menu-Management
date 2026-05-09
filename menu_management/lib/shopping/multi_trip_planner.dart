import "dart:math";

import "package:menu_management/ingredients/models/ingredient.dart";
import "package:menu_management/ingredients/models/product.dart";
import "package:menu_management/recipes/enums/unit.dart";
import "package:menu_management/recipes/models/quantity.dart";
import "package:menu_management/shopping/cooking_timeline.dart";

/// A grouped item to buy on a specific [ShoppingTrip].
class TripItem {
  const TripItem({
    required this.ingredientId,
    required this.amount,
    required this.unit,
    this.freezeOnArrival = false,
  });

  final String ingredientId;
  final double amount;
  final Unit unit;

  /// True when the planner assumed this item is frozen on arrival to extend its shelf life.
  /// Only set when [planShoppingTrips] is called with `assumeFreezerForFreezable: true`
  /// AND the item's matching product has [Product.canBeFrozen] set AND the item would
  /// otherwise have been past sealed shelf life on its cooking day.
  final bool freezeOnArrival;
}

/// A single shopping trip scheduled the day before week [weekIndex] starts.
///
/// Trip with [weekIndex] = 0 happens on day -1 (the day before menu day 0).
/// Trip with [weekIndex] = N happens on day `N * 7 - 1`.
class ShoppingTrip {
  const ShoppingTrip({required this.weekIndex, required this.items});

  final int weekIndex;
  final List<TripItem> items;

  int get tripDay => weekIndex * 7 - 1;
}

/// Plans a minimal set of shopping trips that respects sealed shelf life.
///
/// One trip is scheduled the day before each week it covers. For every cooking
/// event, the planner finds the latest trip that still gets the item fresh
/// (using the matching product's [Product.shelfLifeDaysClosed]). A greedy
/// interval point cover then picks the minimum number of trips that covers
/// every event.
///
/// Items whose unit has no matching product, or whose matching product has
/// [Product.shelfLifeDaysClosed] = null, are treated as non-perishable: they
/// have no upper expiry constraint and ride along on the trips already chosen
/// by perishable items, only adding trip 0 if no other trip exists.
///
/// If an event cannot be served fresh by any prior trip (very short shelf life
/// relative to the cooking day), the planner falls back to the latest trip on
/// or before the event day. The matching menu warning surfaces this to the user.
///
/// [ownedAmounts] is consumed against the earliest events first, per matching unit.
///
/// When [assumeFreezerForFreezable] is true, every event whose matching product has
/// [Product.canBeFrozen] set is treated as non-perishable for trip assignment, so freezable
/// items ride the earliest available trip. Such an event is also tagged with
/// [TripItem.freezeOnArrival] when its sealed shelf life would otherwise have been exceeded
/// by the cooking day (i.e. the user actually has to freeze it to keep it usable).
List<ShoppingTrip> planShoppingTrips({
  required Map<String, List<CookingEvent>> cookingTimeline,
  required List<Ingredient> ingredients,
  Map<String, List<Quantity>> ownedAmounts = const {},
  bool assumeFreezerForFreezable = false,
}) {
  Map<String, Ingredient> ingredientsById = {for (Ingredient i in ingredients) i.id: i};

  List<_PlanEvent> events = _buildPlanEvents(
    cookingTimeline: cookingTimeline,
    ingredientsById: ingredientsById,
    ownedAmounts: ownedAmounts,
    assumeFreezerForFreezable: assumeFreezerForFreezable,
  );

  if (events.isEmpty) return const [];

  // Cap trips to the menu's actual week range. Trip W = "shop for week W+1", so for an
  // N-week menu the highest valid weekIndex is N - 1. We derive N from the latest event
  // day, since events span the menu and a week with no events would not need a trip anyway.
  int maxEventDay = events.map((_PlanEvent e) => e.dayIndex).reduce((int a, int b) => a > b ? a : b);
  int maxWeekIndex = maxEventDay >= 0 ? maxEventDay ~/ 7 : 0;

  for (_PlanEvent event in events) {
    _attachTripWindow(event, maxWeekIndex: maxWeekIndex);
  }

  List<_PlanEvent> freezing = events.where((_PlanEvent e) => e.requiresFreezing).toList();
  List<_PlanEvent> perishable = events.where((_PlanEvent e) => !e.requiresFreezing && e.shelfLifeDaysClosed != null).toList();
  List<_PlanEvent> nonPerishable = events.where((_PlanEvent e) => !e.requiresFreezing && e.shelfLifeDaysClosed == null).toList();

  // Greedy interval point cover for perishables: sort by latest week ascending,
  // reuse a chosen trip if it's in the event's [earliest, latest] window,
  // otherwise add the event's latest as a new trip.
  perishable.sort(_compareForGreedy);
  List<int> chosenTrips = [];
  for (_PlanEvent event in perishable) {
    int? assigned;
    for (int trip in chosenTrips) {
      if (trip >= event.earliestWeek && trip <= event.latestWeek) {
        assigned = trip;
        break;
      }
    }
    if (assigned == null) {
      assigned = event.latestWeek;
      chosenTrips.add(assigned);
    }
    event.assignedTrip = assigned;
  }

  // Freezing-required events are pinned to trip 0: the user buys them on the first trip
  // and freezes them on arrival to last across the menu. They never ride a later trip.
  if (freezing.isNotEmpty && !chosenTrips.contains(0)) chosenTrips.add(0);
  for (_PlanEvent event in freezing) {
    event.assignedTrip = 0;
  }

  // Non-perishables ride along on the earliest chosen trip that is on or before
  // their event day. If no such trip exists, add trip 0 (so we never store a
  // non-perishable beyond its event by accident, and so single-non-perishable
  // menus end up with a single trip 0).
  for (_PlanEvent event in nonPerishable) {
    chosenTrips.sort();
    int? assigned;
    for (int trip in chosenTrips) {
      if (trip <= event.latestWeek) {
        assigned = trip;
        break;
      }
    }
    if (assigned == null) {
      assigned = 0;
      if (!chosenTrips.contains(0)) chosenTrips.add(0);
    }
    event.assignedTrip = assigned;
  }

  return _aggregate(events: events, ingredientsById: ingredientsById);
}

/// Builds per-(ingredient, unit) plan events from the timeline, after applying
/// owned amounts chronologically against matching-unit events.
///
/// When [assumeFreezerForFreezable] is true and the matching product is freezable,
/// the event's effective shelf life is null (treated as non-perishable for trip assignment).
/// The event is also tagged [_PlanEvent.requiresFreezing] when the sealed shelf life would
/// otherwise have been exceeded by the cooking day.
List<_PlanEvent> _buildPlanEvents({
  required Map<String, List<CookingEvent>> cookingTimeline,
  required Map<String, Ingredient> ingredientsById,
  required Map<String, List<Quantity>> ownedAmounts,
  required bool assumeFreezerForFreezable,
}) {
  List<_PlanEvent> result = [];

  for (MapEntry<String, List<CookingEvent>> entry in cookingTimeline.entries) {
    String ingredientId = entry.key;
    List<CookingEvent> events = [...entry.value]..sort((a, b) => a.dayIndex.compareTo(b.dayIndex));
    Ingredient? ingredient = ingredientsById[ingredientId];

    Map<Unit, double> ownedRemainingByUnit = {};
    if (ownedAmounts[ingredientId] != null) {
      for (Quantity owned in ownedAmounts[ingredientId]!) {
        ownedRemainingByUnit[owned.unit] = (ownedRemainingByUnit[owned.unit] ?? 0) + owned.amount;
      }
    }

    for (CookingEvent event in events) {
      for (Quantity quantity in event.quantities) {
        double remainingNeed = quantity.amount;
        double owned = ownedRemainingByUnit[quantity.unit] ?? 0;
        if (owned > 0 && remainingNeed > 0) {
          double consumed = min(owned, remainingNeed);
          ownedRemainingByUnit[quantity.unit] = owned - consumed;
          remainingNeed -= consumed;
        }
        if (remainingNeed <= 0) continue;

        // Any-match across same-unit variants: the user can pick the longest-shelf-life
        // and/or freezable variant at the store, so the planner uses the most permissive
        // values rather than the first match. This mirrors the menu warning's `any` policy.
        int? shelfLife;
        bool canBeFrozen = false;
        if (ingredient != null) {
          List<Product> matchingProducts = ingredient.products.where((p) => p.unit == quantity.unit).toList();
          if (matchingProducts.isNotEmpty) {
            bool anyIndefinite = matchingProducts.any((Product p) => p.shelfLifeDaysClosed == null);
            if (anyIndefinite) {
              shelfLife = null;
            } else {
              shelfLife = matchingProducts.map((Product p) => p.shelfLifeDaysClosed!).reduce((int a, int b) => a > b ? a : b);
            }
            canBeFrozen = matchingProducts.any((Product p) => p.canBeFrozen);
          }
        }

        bool requiresFreezing = false;
        int? effectiveShelfLife = shelfLife;
        if (assumeFreezerForFreezable && canBeFrozen && shelfLife != null) {
          // Item must actually be frozen to last only when the sealed shelf life would not
          // cover the gap from trip 0 (day -1) to the cooking day.
          if (event.dayIndex + 1 >= shelfLife) {
            requiresFreezing = true;
          }
          effectiveShelfLife = null;
        }

        result.add(_PlanEvent(
          ingredientId: ingredientId,
          unit: quantity.unit,
          dayIndex: event.dayIndex,
          amount: remainingNeed,
          shelfLifeDaysClosed: effectiveShelfLife,
          requiresFreezing: requiresFreezing,
        ));
      }
    }
  }

  return result;
}

/// Computes [_PlanEvent.earliestWeek] and [_PlanEvent.latestWeek] in place.
///
/// Trip W happens on day `W * 7 - 1`. Item is fresh on event day D when
/// `D - tripDay < shelfLifeDaysClosed`. When no trip can satisfy freshness,
/// fall back to the closest trip on or before the event day. [maxWeekIndex]
/// caps the latest trip so an N-week menu never produces more than N trips.
void _attachTripWindow(_PlanEvent event, {required int maxWeekIndex}) {
  int latestWeek = (event.dayIndex + 1) ~/ 7;
  if (latestWeek > maxWeekIndex) latestWeek = maxWeekIndex;
  if (latestWeek < 0) latestWeek = 0;

  int earliestWeek;
  int? shelfLife = event.shelfLifeDaysClosed;
  if (shelfLife == null) {
    earliestWeek = 0;
  } else {
    earliestWeek = 0;
    while (earliestWeek * 7 - 1 + shelfLife <= event.dayIndex) {
      earliestWeek++;
    }
    if (earliestWeek > latestWeek) earliestWeek = latestWeek;
  }

  event.earliestWeek = earliestWeek;
  event.latestWeek = latestWeek;
}

int _compareForGreedy(_PlanEvent a, _PlanEvent b) {
  int byLatest = a.latestWeek.compareTo(b.latestWeek);
  if (byLatest != 0) return byLatest;
  return a.earliestWeek.compareTo(b.earliestWeek);
}

List<ShoppingTrip> _aggregate({
  required List<_PlanEvent> events,
  required Map<String, Ingredient> ingredientsById,
}) {
  Map<int, Map<String, Map<Unit, _AggregatedAmount>>> byTrip = {};
  for (_PlanEvent event in events) {
    int trip = event.assignedTrip!;
    byTrip[trip] ??= {};
    byTrip[trip]![event.ingredientId] ??= {};
    _AggregatedAmount? existing = byTrip[trip]![event.ingredientId]![event.unit];
    byTrip[trip]![event.ingredientId]![event.unit] = _AggregatedAmount(
      amount: (existing?.amount ?? 0) + event.amount,
      requiresFreezing: (existing?.requiresFreezing ?? false) || event.requiresFreezing,
    );
  }

  List<int> sortedWeeks = byTrip.keys.toList()..sort();
  List<ShoppingTrip> trips = [];
  for (int week in sortedWeeks) {
    Map<String, Map<Unit, _AggregatedAmount>> ingredientMap = byTrip[week]!;
    List<TripItem> items = [];
    for (MapEntry<String, Map<Unit, _AggregatedAmount>> ie in ingredientMap.entries) {
      for (MapEntry<Unit, _AggregatedAmount> ue in ie.value.entries) {
        items.add(TripItem(
          ingredientId: ie.key,
          amount: ue.value.amount,
          unit: ue.key,
          freezeOnArrival: ue.value.requiresFreezing,
        ));
      }
    }
    items.sort((TripItem a, TripItem b) {
      String aName = ingredientsById[a.ingredientId]?.name ?? a.ingredientId;
      String bName = ingredientsById[b.ingredientId]?.name ?? b.ingredientId;
      int byName = aName.toLowerCase().compareTo(bName.toLowerCase());
      if (byName != 0) return byName;
      return a.unit.index.compareTo(b.unit.index);
    });
    trips.add(ShoppingTrip(weekIndex: week, items: items));
  }
  return trips;
}

class _AggregatedAmount {
  const _AggregatedAmount({required this.amount, required this.requiresFreezing});
  final double amount;
  final bool requiresFreezing;
}

class _PlanEvent {
  _PlanEvent({
    required this.ingredientId,
    required this.unit,
    required this.dayIndex,
    required this.amount,
    required this.shelfLifeDaysClosed,
    required this.requiresFreezing,
  });

  final String ingredientId;
  final Unit unit;
  final int dayIndex;
  final double amount;
  final int? shelfLifeDaysClosed;
  final bool requiresFreezing;

  int earliestWeek = 0;
  int latestWeek = 0;
  int? assignedTrip;
}
