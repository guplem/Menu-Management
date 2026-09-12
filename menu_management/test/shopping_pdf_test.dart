import "dart:convert";
import "dart:io";
import "dart:typed_data";

import "package:flutter_test/flutter_test.dart";
import "package:menu_management/ingredients/models/ingredient.dart";
import "package:menu_management/ingredients/models/product.dart";
import "package:menu_management/menu/enums/meal_type.dart";
import "package:menu_management/menu/enums/week_day.dart";
import "package:menu_management/menu/models/cooking.dart";
import "package:menu_management/menu/models/meal.dart";
import "package:menu_management/menu/models/meal_time.dart";
import "package:menu_management/menu/models/menu.dart";
import "package:menu_management/menu/models/multi_week_menu.dart";
import "package:menu_management/menu/models/sub_meal.dart";
import "package:menu_management/recipes/enums/unit.dart";
import "package:menu_management/recipes/models/ingredient_usage.dart";
import "package:menu_management/recipes/models/instruction.dart";
import "package:menu_management/recipes/models/quantity.dart";
import "package:menu_management/recipes/models/recipe.dart";
import "package:menu_management/shopping/shopping_pdf.dart";
import "package:menu_management/shopping/shopping_pdf_document.dart";

const String _link = "https://tienda.mercadona.es/product/1/espaguetis";

Recipe _pasta() => const Recipe(
  id: "r1",
  name: "Pasta",
  instructions: [
    Instruction(
      id: "i1",
      description: "Boil the pasta.",
      ingredientsUsed: [
        IngredientUsage(
          ingredient: "n1",
          quantity: Quantity(amount: 100, unit: Unit.grams),
        ),
      ],
    ),
  ],
);

MultiWeekMenu _menu() => MultiWeekMenu(
  startDate: DateTime(2025, 8, 6),
  weeks: [
    Menu(
      meals: [
        Meal(
          mealTime: const MealTime(weekDay: WeekDay.saturday, mealType: MealType.lunch),
          subMeals: const [SubMeal(cooking: Cooking(recipeId: "r1", yield: 1), people: 2)],
        ),
      ],
    ),
  ],
);

/// Reads back the words that the PDF draws on its pages, joined by one space.
///
/// A PDF holds its drawn text in a compressed stream, and it writes one word at a time as
/// `[(word)]TJ`. This inflates every stream and puts the words back together, so a test can read
/// the page the way the reader reads it. It is the one way to prove that a string reaches a page.
String _drawnText(Uint8List bytes) {
  const String open = "stream\n";
  const String close = "\nendstream";
  final String raw = latin1.decode(bytes);
  final List<String> words = [];
  int at = 0;
  while (true) {
    final int start = raw.indexOf(open, at);
    if (start < 0) break;
    final int end = raw.indexOf(close, start);
    if (end < 0) break;
    at = end + close.length;
    final String inflated;
    try {
      inflated = latin1.decode(ZLibDecoder().convert(bytes.sublist(start + open.length, end)));
    } catch (_) {
      continue; // Not a compressed stream, for example an embedded font.
    }
    for (RegExpMatch match in RegExp(r"\[\((.*?)\)\]TJ").allMatches(inflated)) {
      words.add(match.group(1)!.replaceAll(r"\(", "(").replaceAll(r"\)", ")"));
    }
  }
  return words.join(" ");
}

/// Counts the pages of a PDF. Every page object carries `/Type/Page` and no `s` after it.
int _pageCount(Uint8List bytes) => RegExp(r"/Type/Page[^s]").allMatches(latin1.decode(bytes)).length;

void main() {
  group("buildShoppingPdfBytes", () {
    test("writes a file that every reader accepts: a PDF header and an end-of-file marker", () async {
      Uint8List bytes = await buildShoppingPdfBytes(
        ingredients: const [
          Ingredient(
            id: "n1",
            name: "Noodles",
            products: [Product(link: _link, quantityPerItem: 500, unit: Unit.grams)],
          ),
        ],
        remainingByIngredientId: const {
          "n1": [Quantity(amount: 500, unit: Unit.grams)],
        },
        trips: const [],
        tripLabel: (_) => "now",
        multiWeekMenu: _menu(),
        recipes: [_pasta()],
        cookingTimeline: const {},
      );

      expect(latin1.decode(bytes.sublist(0, 5)), "%PDF-");
      expect(latin1.decode(bytes.sublist(bytes.length - 6)).trim(), "%%EOF");
    });

    test("writes a file for a list with nothing to buy, so the export never fails on an empty list", () async {
      Uint8List bytes = await buildShoppingPdfBytes(
        ingredients: const [],
        remainingByIngredientId: const {},
        trips: const [],
        tripLabel: (_) => "now",
        multiWeekMenu: const MultiWeekMenu(weeks: [Menu()]),
        recipes: const [],
        cookingTimeline: const {},
      );

      expect(latin1.decode(bytes.sublist(0, 5)), "%PDF-");
      expect(latin1.decode(bytes.sublist(bytes.length - 6)).trim(), "%%EOF");
    });
  });

  group("the text that the renderer writes", () {
    test("writes the ingredient and the amount to buy, and the freeze note of a trip that needs it", () {
      const ShoppingPdfIngredientEntry entry = ShoppingPdfIngredientEntry(ingredientName: "Noodles", amounts: "500 grams + 2 pieces");

      expect(shoppingIngredientHeadingText(entry), "Noodles: 500 grams + 2 pieces");
      expect(shoppingIngredientHeadingText(entry.copyWith(freezeOnArrival: true)), "Noodles: 500 grams + 2 pieces (freeze on arrival)");
    });

    test("writes the packs of one product, and marks the product that the app recommends", () {
      const ShoppingPdfProductOption option = ShoppingPdfProductOption(
        label: "Espaguetis (500 grams/pack)",
        link: _link,
        packs: 2,
        isRecommended: false,
      );

      // The indent is part of the line: it sets the product under the ingredient that holds it.
      expect(productOptionText(option), "   Espaguetis (500 grams/pack): 2 packs");
      expect(productOptionText(option.copyWith(packs: 1)), "   Espaguetis (500 grams/pack): 1 pack");
      expect(productOptionText(option.copyWith(isRecommended: true)), "   Espaguetis (500 grams/pack): 2 packs - recommended");
    });

    test("writes the week, the day, the meal slot, the recipe and the amount of one meal that needs the ingredient", () {
      const ShoppingPdfMealNeed need = ShoppingPdfMealNeed(
        weekLabel: "Week 1",
        dayLabel: "Wednesday 6 Aug",
        mealName: "Lunch",
        recipeName: "Pasta",
        people: 2,
        isCookEvent: true,
        amounts: "200 grams",
      );

      // The indent is part of the line: it sets the meal under the ingredient that needs it.
      expect(mealNeedText(need), "   Week 1, Wednesday 6 Aug, Lunch - Pasta for 2 people: 200 grams");
      expect(mealNeedText(need.copyWith(people: 1)), "   Week 1, Wednesday 6 Aug, Lunch - Pasta for 1 person: 200 grams");
      expect(mealNeedText(need.copyWith(isCookEvent: false)), "   Week 1, Wednesday 6 Aug, Lunch - Pasta for 2 people (leftovers): 200 grams");
    });
  });

  group("renderShoppingPdf", () {
    test("writes the store link of a product as a link that the reader can click", () async {
      Uint8List bytes = await renderShoppingPdf(
        const ShoppingPdfDocument(
          title: "Shopping list",
          trips: [
            ShoppingPdfTripSection(
              title: "now",
              ingredients: [
                ShoppingPdfIngredientEntry(
                  ingredientName: "Noodles",
                  amounts: "500 grams",
                  products: [ShoppingPdfProductOption(label: "Espaguetis (500 grams/pack)", link: _link, packs: 1, isRecommended: true)],
                ),
              ],
            ),
          ],
        ),
      );

      // A PDF link annotation writes the address as an uncompressed `/S/URI/URI(...)` object, so
      // the address is in the bytes. This is the one check that the link is a real PDF link and
      // not text that only reads like one.
      expect(latin1.decode(bytes).contains("/S/URI/URI($_link)"), isTrue);
    });

    test("writes a link that is not an address as plain text, because a dead link helps nobody", () async {
      Uint8List bytes = await renderShoppingPdf(
        const ShoppingPdfDocument(
          title: "Shopping list",
          trips: [
            ShoppingPdfTripSection(
              title: "now",
              ingredients: [
                ShoppingPdfIngredientEntry(
                  ingredientName: "Noodles",
                  amounts: "500 grams",
                  products: [ShoppingPdfProductOption(label: "Espaguetis (500 grams/pack)", link: "espaguetis 500g", packs: 1, isRecommended: true)],
                ),
              ],
            ),
          ],
        ),
      );

      expect(latin1.decode(bytes).contains("/S/URI"), isFalse);
      expect(_drawnText(bytes).contains("Espaguetis (500 grams/pack): 1 pack - recommended"), isTrue);
    });

    test("writes a long list of ingredients with long names, which no single page can hold", () async {
      ShoppingPdfIngredientEntry entry(int index) => ShoppingPdfIngredientEntry(
        ingredientName: "Slow-roasted-aubergine-with-tahini-and-pomegranate number $index",
        amounts: "500 grams",
        freezeOnArrival: true,
        products: List<ShoppingPdfProductOption>.generate(
          4,
          (int product) => ShoppingPdfProductOption(
            label: "Espaguetis integrales de trigo duro number $product",
            link: _link,
            packs: 3,
            isRecommended: product == 0,
          ),
        ),
        meals: List<ShoppingPdfMealNeed>.generate(
          6,
          (int meal) => ShoppingPdfMealNeed(
            weekLabel: "Week ${meal + 1}",
            dayLabel: "Wednesday 6 Aug",
            mealName: "Lunch",
            recipeName: "Slow-roasted-aubergine-with-tahini-and-pomegranate",
            people: 2,
            isCookEvent: meal.isEven,
            amounts: "200 grams",
          ),
        ),
      );

      Uint8List bytes = await renderShoppingPdf(
        ShoppingPdfDocument(
          title: "Shopping list 6 Aug - 19 Aug",
          trips: List<ShoppingPdfTripSection>.generate(
            3,
            (int trip) => ShoppingPdfTripSection(title: "Trip $trip", ingredients: List<ShoppingPdfIngredientEntry>.generate(12, entry)),
          ),
        ),
      );

      expect(latin1.decode(bytes.sublist(0, 5)), "%PDF-");
      // The two headings below reach a page only through the renderer, so this is the one check
      // that the justification block and the trip title are drawn and not only composed.
      String drawn = _drawnText(bytes);
      expect(drawn.contains(mealNeedsHeadingText), isTrue);
      expect(drawn.contains("Trip 0"), isTrue);
    });

    test("writes a file for a section that holds nothing to buy", () async {
      Uint8List bytes = await renderShoppingPdf(
        const ShoppingPdfDocument(
          title: "Shopping list",
          trips: [ShoppingPdfTripSection(title: "")],
        ),
      );

      expect(latin1.decode(bytes.sublist(0, 5)), "%PDF-");
      expect(_drawnText(bytes).contains(nothingToBuyText), isTrue);
    });

    test("continues one ingredient on the next page when its meals do not fit on one page", () async {
      // A staple of a four-week menu reaches about 80 meal lines. The block is then taller than
      // one page. The renderer must write it over two pages and never fail.
      Uint8List bytes = await renderShoppingPdf(
        ShoppingPdfDocument(
          title: "Shopping list",
          trips: [
            ShoppingPdfTripSection(
              title: "now",
              ingredients: [
                ShoppingPdfIngredientEntry(
                  ingredientName: "Noodles",
                  amounts: "500 grams",
                  products: const [ShoppingPdfProductOption(label: "Espaguetis (500 grams/pack)", link: _link, packs: 1, isRecommended: true)],
                  meals: List<ShoppingPdfMealNeed>.generate(
                    80,
                    (int meal) => ShoppingPdfMealNeed(
                      weekLabel: "Week ${meal ~/ 21 + 1}",
                      dayLabel: "Wednesday 6 Aug",
                      mealName: "Lunch",
                      recipeName: "Pasta number $meal",
                      people: 2,
                      isCookEvent: true,
                      amounts: "200 grams",
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );

      expect(_pageCount(bytes), 2);
      String drawn = _drawnText(bytes);
      expect(drawn.contains("Noodles: 500 grams"), isTrue);
      expect(drawn.contains("Pasta number 79 for 2 people: 200 grams"), isTrue);
    });
  });
}
