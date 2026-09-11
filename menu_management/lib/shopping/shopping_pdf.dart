import "dart:typed_data";

import "package:menu_management/ingredients/models/ingredient.dart";
import "package:menu_management/menu/models/multi_week_menu.dart";
import "package:menu_management/recipes/models/quantity.dart";
import "package:menu_management/recipes/models/recipe.dart";
import "package:menu_management/shopping/cooking_timeline.dart";
import "package:menu_management/shopping/multi_trip_planner.dart";
import "package:menu_management/shopping/shopping_copy_text.dart";
import "package:menu_management/shopping/shopping_pdf_document.dart";
import "package:pdf/pdf.dart";
import "package:pdf/widgets.dart" as pw;

/// Builds the shopping list PDF as bytes.
///
/// Pure: it reads no provider and needs no widget, so a test calls it directly (ADR 0009). The
/// shopping page passes the same ingredients, amounts and trips that it gives to the copied text.
///
/// The work happens in two steps. `buildShoppingPdfDocument` decides what the PDF says, and
/// [renderShoppingPdf] decides how the page looks. The tests of the content read the first step,
/// so no test has to decode a PDF.
Future<Uint8List> buildShoppingPdfBytes({
  required List<Ingredient> ingredients,
  required Map<String, List<Quantity>> remainingByIngredientId,
  required List<ShoppingTrip> trips,
  required String Function(ShoppingTrip trip) tripLabel,
  required MultiWeekMenu multiWeekMenu,
  required List<Recipe> recipes,
  required Map<String, List<CookingEvent>> cookingTimeline,
}) async {
  return renderShoppingPdf(
    buildShoppingPdfDocument(
      ingredients: ingredients,
      remainingByIngredientId: remainingByIngredientId,
      trips: trips,
      tripLabel: tripLabel,
      multiWeekMenu: multiWeekMenu,
      recipes: recipes,
      cookingTimeline: cookingTimeline,
    ),
  );
}

/// Draws [document] on A4 pages and returns the bytes of the PDF.
///
/// The reader of this file shops without the app, so each ingredient carries everything that the
/// shop asks for: the amount, every product that fits it, and the meals that need it.
Future<Uint8List> renderShoppingPdf(ShoppingPdfDocument document) async {
  final pw.Document pdf = pw.Document(title: document.title);

  pdf.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(28),
      build: (pw.Context context) => <pw.Widget>[
        pw.Text(document.title, style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 14),
        for (ShoppingPdfTripSection trip in document.trips) ..._tripWidgets(trip),
      ],
    ),
  );

  return pdf.save();
}

/// Draws one trip: its title, then one block per ingredient.
///
/// A trip with an empty title writes no header. The planner found no trip to plan, so the PDF
/// holds one plain list and a header would name a trip that does not exist.
List<pw.Widget> _tripWidgets(ShoppingPdfTripSection trip) {
  return <pw.Widget>[
    if (trip.title.isNotEmpty) ...<pw.Widget>[
      pw.Text(trip.title, style: pw.TextStyle(fontSize: 15, fontWeight: pw.FontWeight.bold)),
      pw.Divider(color: PdfColors.grey400, thickness: 0.5),
    ],
    if (trip.ingredients.isEmpty) pw.Text(nothingToBuyText, style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600)),
    for (ShoppingPdfIngredientEntry entry in trip.ingredients) _ingredientWidget(entry),
    pw.SizedBox(height: 10),
  ];
}

/// Draws one ingredient: the amount to buy, then the products, then the meals that need it.
///
/// The block never splits over two pages. The reader stands in the shop and compares the products
/// of one ingredient, so a block cut in half costs more than a page that ends early.
pw.Widget _ingredientWidget(ShoppingPdfIngredientEntry entry) {
  return pw.Container(
    margin: const pw.EdgeInsets.only(bottom: 8),
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: <pw.Widget>[
        pw.Text(shoppingIngredientHeadingText(entry), style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
        for (ShoppingPdfProductOption product in entry.products) _productWidget(product),
        if (entry.meals.isNotEmpty) ...<pw.Widget>[
          pw.SizedBox(height: 2),
          pw.Text(mealNeedsHeadingText, style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700)),
          for (ShoppingPdfMealNeed meal in entry.meals)
            pw.Text("   ${mealNeedText(meal)}", style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700)),
        ],
      ],
    ),
  );
}

/// Draws one product of an ingredient.
///
/// A product with a store link is a real PDF link: a tap opens the page of the product in the
/// browser of the reader. The app itself opens a link with a Windows-only call, so the PDF is the
/// one place where a link works on every device.
pw.Widget _productWidget(ShoppingPdfProductOption product) {
  final String text = "   ${productOptionText(product)}";
  if (product.link.isEmpty) return pw.Text(text, style: const pw.TextStyle(fontSize: 9));
  return pw.UrlLink(
    destination: product.link,
    child: pw.Text(
      text,
      style: const pw.TextStyle(fontSize: 9, color: PdfColors.blue700, decoration: pw.TextDecoration.underline),
    ),
  );
}

/// Writes the first line of an ingredient, for example "Noodles: 500 grams (freeze on arrival)".
/// [freezeOnArrivalSuffix] is the suffix that the copied text writes, so both exports read alike.
String shoppingIngredientHeadingText(ShoppingPdfIngredientEntry entry) {
  final String suffix = entry.freezeOnArrival ? freezeOnArrivalSuffix : "";
  return "${entry.ingredientName}: ${entry.amounts}$suffix";
}

/// Writes one product line, for example "Espaguetis (500 grams/pack): 2 packs - recommended".
///
/// Every product that fits the ingredient gets a line, so the reader who finds an empty shelf
/// takes the next line and still buys enough. The mark says which one the app picks first.
String productOptionText(ShoppingPdfProductOption product) {
  final String packs = "${product.packs} ${product.packs == 1 ? "pack" : "packs"}";
  return "${product.label}: $packs${product.isRecommended ? " - recommended" : ""}";
}

/// Writes one justification line, for example
/// "Week 1, Wednesday 6 Aug, Lunch - Pasta for 2 people: 200 grams".
///
/// A meal that eats leftovers carries "(leftovers)" after the people. It needs the food too, and
/// the cook event of an earlier day buys it, so the reader sees why the amount is above one meal.
String mealNeedText(ShoppingPdfMealNeed meal) {
  final String people = "${meal.people} ${meal.people == 1 ? "person" : "people"}";
  final String leftovers = meal.isCookEvent ? "" : " (leftovers)";
  return "${meal.weekLabel}, ${meal.dayLabel}, ${meal.mealName} - ${meal.recipeName} for $people$leftovers: ${meal.amounts}";
}

/// Names the block of meals under an ingredient.
const String mealNeedsHeadingText = "Needed for:";

/// What a section with nothing to buy writes. An empty page would leave the reader guessing
/// whether the export failed.
const String nothingToBuyText = "Nothing to buy.";
