import "dart:convert";
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
import "package:menu_management/shopping/shopping_copy_text.dart";
import "package:menu_management/shopping/shopping_pdf.dart";
import "package:menu_management/shopping/shopping_pdf_document.dart";

import "helpers/pdf_bytes_reader.dart";

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
    test("numbers each trip in its banner and counts what it buys", () {
      expect(tripBannerText(tripNumber: 1, tripsCount: 3, title: "now"), "Trip 1 of 3: now");
      expect(tripBannerText(tripNumber: 2, tripsCount: 2, title: "Friday 12 Aug"), "Trip 2 of 2: Friday 12 Aug");
      expect(itemCountText(12), "12 items");
      expect(itemCountText(1), "1 item");
    });

    test("writes the packs of one product, and names the mark of the product that the app recommends", () {
      const ShoppingPdfProductOption option = ShoppingPdfProductOption(
        label: "Espaguetis (500 grams/pack)",
        link: _link,
        packs: 2,
        isRecommended: false,
      );

      expect(productPacksText(option), "2 packs");
      expect(productPacksText(option.copyWith(packs: 1)), "1 pack");
      expect(recommendedBadgeText, "Recommended");
    });

    test("names the freeze mark with the words of the copied text", () {
      expect(freezeOnArrivalBadgeText, "Freeze on arrival");
      expect(freezeOnArrivalSuffix, " (${freezeOnArrivalBadgeText.toLowerCase()})");
    });

    test("writes when a meal needs the ingredient, and which dish for how many people", () {
      const ShoppingPdfMealNeed need = ShoppingPdfMealNeed(
        weekLabel: "Week 1",
        dayLabel: "Wednesday 6 Aug",
        mealName: "Lunch",
        recipeName: "Pasta",
        people: 2,
        isCookEvent: true,
        amounts: "200 grams",
      );

      expect(mealNeedWhenText(need), "Week 1, Wednesday 6 Aug, Lunch");
      expect(mealNeedDishText(need), "Pasta for 2 people");
      expect(mealNeedDishText(need.copyWith(people: 1)), "Pasta for 1 person");
      expect(mealNeedDishText(need.copyWith(isCookEvent: false)), "Pasta for 2 people (leftovers)");
    });

    test("says so when an ingredient has no store product", () {
      expect(noProductText, "No store product saved. Buy the amount above.");
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
      expect(drawnPdfText(bytes).contains("1 pack Espaguetis (500 grams/pack) Recommended"), isTrue);
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
      String drawn = drawnPdfText(bytes);
      expect(drawn.contains(mealNeedsHeadingText), isTrue);
      expect(drawn.contains("Trip 0"), isTrue);
    });

    test("starts every trip on a new page with a banner that numbers it and counts its items", () async {
      ShoppingPdfTripSection trip(String title) => ShoppingPdfTripSection(
        title: title,
        ingredients: const [ShoppingPdfIngredientEntry(ingredientName: "Noodles", amounts: "500 grams")],
      );

      Uint8List bytes = await renderShoppingPdf(ShoppingPdfDocument(title: "Shopping list", trips: [trip("now"), trip("Friday 12 Aug")]));

      // Two trips of one line each fit one page together. Two pages prove the break.
      expect(pdfPageCount(bytes), 2);
      String drawn = drawnPdfText(bytes);
      expect(drawn.contains("Trip 1 of 2: now 1 item"), isTrue);
      expect(drawn.contains("Trip 2 of 2: Friday 12 Aug 1 item"), isTrue);
      expect(drawn.contains("Shopping list · Page 2 of 2"), isTrue);
    });

    test("draws the freeze mark of an ingredient, and the note of an ingredient with no product", () async {
      Uint8List bytes = await renderShoppingPdf(
        const ShoppingPdfDocument(
          title: "Shopping list",
          trips: [
            ShoppingPdfTripSection(
              title: "",
              ingredients: [ShoppingPdfIngredientEntry(ingredientName: "Noodles", amounts: "500 grams", freezeOnArrival: true)],
            ),
          ],
        ),
      );

      String drawn = drawnPdfText(bytes);
      expect(drawn.contains("Noodles $freezeOnArrivalBadgeText 500 grams"), isTrue);
      expect(drawn.contains(noProductText), isTrue);
    });

    test("writes a file for a section that holds nothing to buy", () async {
      Uint8List bytes = await renderShoppingPdf(
        const ShoppingPdfDocument(
          title: "Shopping list",
          trips: [ShoppingPdfTripSection(title: "")],
        ),
      );

      expect(latin1.decode(bytes.sublist(0, 5)), "%PDF-");
      expect(drawnPdfText(bytes).contains(nothingToBuyText), isTrue);
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

      expect(pdfPageCount(bytes), 2);
      String drawn = drawnPdfText(bytes);
      expect(drawn.contains("Noodles 500 grams"), isTrue);
      expect(drawn.contains("Week 4, Wednesday 6 Aug, Lunch Pasta number 79 for 2 people 200 grams"), isTrue);
    });
  });
}
