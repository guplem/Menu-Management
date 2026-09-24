import "dart:typed_data";

import "package:menu_management/ingredients/models/ingredient.dart";
import "package:menu_management/menu/models/multi_week_menu.dart";
import "package:menu_management/recipes/models/quantity.dart";
import "package:menu_management/recipes/models/recipe.dart";
import "package:menu_management/shopping/cooking_timeline.dart";
import "package:menu_management/shopping/multi_trip_planner.dart";
import "package:menu_management/shopping/shopping_copy_text.dart";
import "package:menu_management/shopping/shopping_pdf_document.dart";
import "package:menu_management/theme/pdf_theme.dart";
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
///
/// Each trip starts on a new page, so the reader takes only the pages of the trip of the day.
Future<Uint8List> renderShoppingPdf(ShoppingPdfDocument document) async {
  final pw.Document pdf = pw.Document(title: document.title);
  final int tripsCount = document.trips.length;

  pdf.addPage(
    pw.MultiPage(
      pageFormat: pdfPageFormat,
      margin: pdfPageMargin,
      footer: (pw.Context context) => pdfPageFooter(context: context, title: document.title),
      build: (pw.Context context) => <pw.Widget>[
        pdfDocumentTitle(title: document.title, subtitle: shoppingLegendText),
        pw.SizedBox(height: 12),
        for (int index = 0; index < document.trips.length; index++) ...<pw.Widget>[
          if (index > 0) pw.NewPage(),
          ..._tripWidgets(trip: document.trips[index], tripNumber: index + 1, tripsCount: tripsCount),
        ],
      ],
    ),
  );

  return pdf.save();
}

/// Draws one trip: its banner, then one block per ingredient.
///
/// A trip with an empty title writes no banner. The planner found no trip to plan, so the PDF
/// holds one plain list and a banner would name a trip that does not exist.
List<pw.Widget> _tripWidgets({required ShoppingPdfTripSection trip, required int tripNumber, required int tripsCount}) {
  return <pw.Widget>[
    if (trip.title.isNotEmpty) ...<pw.Widget>[
      pdfSectionBanner(
        text: tripBannerText(tripNumber: tripNumber, tripsCount: tripsCount, title: trip.title),
        trailing: itemCountText(trip.ingredients.length),
      ),
      pw.SizedBox(height: 8),
    ],
    if (trip.ingredients.isEmpty) pw.Text(nothingToBuyText, style: const pw.TextStyle(fontSize: 10, color: pdfMutedTextColor)),
    for (ShoppingPdfIngredientEntry entry in trip.ingredients) ..._ingredientWidgets(entry),
  ];
}

/// Draws one ingredient: a box to tick, the name and the amount to buy, then the products, then
/// the meals that need it.
///
/// The name and the products stay on one page, inside a [pw.Inseparable]. The reader stands in
/// the shop and compares the products of one ingredient, so a name cut from its products costs
/// more than a page that ends early.
///
/// The table of meals is a separate widget of the page, so it can continue on the next page, and
/// it does so for a staple of a long menu: a test measured 80 meal lines over two pages. The meals
/// justify the amount and the reader does not compare them, so a break there costs little. A
/// [pw.Inseparable] around the whole block would instead fail the export as soon as the block is
/// taller than one page.
List<pw.Widget> _ingredientWidgets(ShoppingPdfIngredientEntry entry) {
  return <pw.Widget>[
    pw.Inseparable(
      child: pw.Container(
        padding: const pw.EdgeInsets.only(top: 6),
        decoration: const pw.BoxDecoration(
          border: pw.Border(top: pw.BorderSide(color: pdfLineColor, width: 0.5)),
        ),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: <pw.Widget>[
            _ingredientHeading(entry),
            pw.SizedBox(height: 2),
            if (entry.products.isEmpty)
              pw.Padding(
                padding: const pw.EdgeInsets.only(left: _contentIndent),
                child: pw.Text(
                  noProductText,
                  style: pw.TextStyle(fontSize: 8, fontStyle: pw.FontStyle.italic, color: pdfMutedTextColor),
                ),
              ),
            for (ShoppingPdfProductOption product in entry.products) _productRow(product),
          ],
        ),
      ),
    ),
    if (entry.meals.isNotEmpty) ...<pw.Widget>[
      pw.Padding(
        padding: const pw.EdgeInsets.only(left: _contentIndent, top: 3, bottom: 1),
        child: pw.Text(
          mealNeedsHeadingText,
          style: pw.TextStyle(fontSize: 7, fontWeight: pw.FontWeight.bold, color: pdfMutedTextColor),
        ),
      ),
      pw.Padding(
        padding: const pw.EdgeInsets.only(left: _contentIndent),
        child: _mealNeedsTable(entry.meals),
      ),
    ],
    pw.SizedBox(height: 8),
  ];
}

/// The indent that sets the products and the meals under the name of their ingredient. It is the
/// width of the box to tick and the gap after it.
const double _contentIndent = 17;

/// The side of the box to tick.
const double _checkboxSize = 10;

/// Draws the first line of an ingredient: the box to tick, the name, the freeze mark, and the
/// amount to buy at the right end.
pw.Widget _ingredientHeading(ShoppingPdfIngredientEntry entry) {
  return pw.Row(
    children: <pw.Widget>[
      pw.Container(
        width: _checkboxSize,
        height: _checkboxSize,
        decoration: pw.BoxDecoration(
          border: pw.Border.all(color: pdfMutedTextColor, width: 0.8),
          borderRadius: const pw.BorderRadius.all(pw.Radius.circular(2)),
        ),
      ),
      pw.SizedBox(width: _contentIndent - _checkboxSize),
      pw.Expanded(
        child: pw.Row(
          children: <pw.Widget>[
            pw.Flexible(
              child: pw.Text(entry.ingredientName, style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
            ),
            if (entry.freezeOnArrival) ...<pw.Widget>[
              pw.SizedBox(width: 6),
              pdfBadge(text: freezeOnArrivalBadgeText, color: PdfColors.blue800, fillColor: PdfColors.blue50),
            ],
          ],
        ),
      ),
      pw.SizedBox(width: 8),
      pw.Text(
        entry.amounts,
        style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold, color: pdfAccentColor),
      ),
    ],
  );
}

/// Draws one product of an ingredient: the packs to buy, the name of the product, and the mark of
/// the product that the app recommends.
///
/// Every product that fits the ingredient gets a row, so the reader who finds an empty shelf
/// takes the next row and still buys enough. The mark says which products waste the least, and
/// two products that tie both carry it.
///
/// A product with a store link is a real PDF link: a tap opens the page of the product in the
/// browser of the reader. The app itself opens a link with a Windows-only call, so the PDF is the
/// one place where a link works on every device.
///
/// A link that is not an address reads as plain text. `Product.link` takes any text that the user
/// types, and a blue name that opens nothing is worse than no link: the reader taps it in the shop
/// and gets an error. `Product.nameFromLink` guards the same field the same way.
pw.Widget _productRow(ShoppingPdfProductOption product) {
  final bool isLink = Uri.tryParse(product.link)?.hasScheme == true;
  final pw.Widget label = pw.Text(
    product.label,
    style: pw.TextStyle(fontSize: 9, color: isLink ? pdfLinkColor : null, fontWeight: product.isRecommended ? pw.FontWeight.bold : null),
  );

  return pw.Padding(
    padding: const pw.EdgeInsets.only(left: _contentIndent, top: 1.5),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: <pw.Widget>[
        pw.SizedBox(
          width: 44,
          child: pw.Text(productPacksText(product), style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
        ),
        pw.Flexible(
          child: isLink ? pw.UrlLink(destination: product.link, child: label) : label,
        ),
        if (product.isRecommended) ...<pw.Widget>[
          pw.SizedBox(width: 6),
          pdfBadge(text: recommendedBadgeText, color: PdfColors.green800, fillColor: PdfColors.green50),
        ],
      ],
    ),
  );
}

/// Draws the meals that need an ingredient as a small table: when, which dish for how many
/// people, and the amount.
///
/// A table row cannot split over two pages, but a table can, so a long list of meals continues
/// on the next page.
pw.Widget _mealNeedsTable(List<ShoppingPdfMealNeed> meals) {
  pw.Widget cell(String text, {pw.TextAlign align = pw.TextAlign.left}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 3, vertical: 1),
      child: pw.Text(
        text,
        style: const pw.TextStyle(fontSize: 7.5, color: pdfMutedTextColor),
        textAlign: align,
      ),
    );
  }

  return pw.Table(
    columnWidths: const <int, pw.TableColumnWidth>{0: pw.FlexColumnWidth(3), 1: pw.FlexColumnWidth(5), 2: pw.FlexColumnWidth(1.5)},
    children: <pw.TableRow>[
      for (int index = 0; index < meals.length; index++)
        pw.TableRow(
          decoration: index.isOdd ? const pw.BoxDecoration(color: pdfStripeColor) : null,
          children: <pw.Widget>[
            cell(mealNeedWhenText(meals[index])),
            cell(mealNeedDishText(meals[index])),
            cell(meals[index].amounts, align: pw.TextAlign.right),
          ],
        ),
    ],
  );
}

/// The line under the title. It tells the reader how to use the page in the shop.
const String shoppingLegendText =
    "Tick the box of an item when it is in the cart. Each product row buys enough on its own. "
    "The recommended one wastes the least. A blue product name opens its store page.";

/// Writes the banner of one trip, for example "Trip 1 of 3: now".
String tripBannerText({required int tripNumber, required int tripsCount, required String title}) => "Trip $tripNumber of $tripsCount: $title";

/// Counts the ingredients of one trip, for example "12 items".
String itemCountText(int count) => "$count ${count == 1 ? "item" : "items"}";

/// Writes the packs of one product, for example "2 packs".
String productPacksText(ShoppingPdfProductOption product) => "${product.packs} ${product.packs == 1 ? "pack" : "packs"}";

/// The mark of the product that wastes the least.
const String recommendedBadgeText = "Recommended";

/// The mark of an item that the reader must freeze on the day of the trip (ADR 0015).
/// [freezeOnArrivalSuffix] of the copied text holds the same words, so both exports read alike.
const String freezeOnArrivalBadgeText = "Freeze on arrival";

/// What an ingredient with no store product writes under its name. The reader then knows that
/// the missing product rows are no fault of the export.
const String noProductText = "No store product saved. Buy the amount above.";

/// Writes when one meal needs the ingredient, for example "Week 1, Wednesday 6 Aug, Lunch".
String mealNeedWhenText(ShoppingPdfMealNeed meal) => "${meal.weekLabel}, ${meal.dayLabel}, ${meal.mealName}";

/// Writes the dish of one meal and its people, for example "Pasta for 2 people".
///
/// A meal that eats leftovers carries "(leftovers)" after the people. It needs the food too, and
/// the cook event of an earlier day buys it, so the reader sees why the amount is above one meal.
String mealNeedDishText(ShoppingPdfMealNeed meal) {
  final String people = "${meal.people} ${meal.people == 1 ? "person" : "people"}";
  final String leftovers = meal.isCookEvent ? "" : " (leftovers)";
  return "${meal.recipeName} for $people$leftovers";
}

/// Names the block of meals under an ingredient.
const String mealNeedsHeadingText = "Needed for:";

/// What a section with nothing to buy writes. An empty page would leave the reader guessing
/// whether the export failed.
const String nothingToBuyText = "Nothing to buy.";
