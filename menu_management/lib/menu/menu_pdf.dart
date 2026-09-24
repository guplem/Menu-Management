import "dart:typed_data";

import "package:menu_management/flutter_essentials/library.dart";
import "package:menu_management/ingredients/models/ingredient.dart";
import "package:menu_management/menu/enums/meal_type.dart";
import "package:menu_management/menu/menu_pdf_document.dart";
import "package:menu_management/menu/models/multi_week_menu.dart";
import "package:menu_management/recipes/models/recipe.dart";
import "package:menu_management/theme/pdf_theme.dart";
import "package:pdf/widgets.dart" as pw;

/// Builds the menu PDF as bytes.
///
/// Pure: it reads no provider and needs no widget, so a test calls it directly (ADR 0009).
/// [recipes] and [ingredients] carry every name and every amount that the document needs.
///
/// The work happens in two steps. `buildMenuPdfDocument` decides what the PDF says, and
/// [renderMenuPdf] decides how the page looks. The tests of the content read the first step, so
/// no test has to decode a PDF.
Future<Uint8List> buildMenuPdfBytes({
  required MultiWeekMenu multiWeekMenu,
  required List<Recipe> recipes,
  required List<Ingredient> ingredients,
}) async {
  return renderMenuPdf(buildMenuPdfDocument(multiWeekMenu: multiWeekMenu, recipes: recipes, ingredients: ingredients));
}

/// Draws [document] on A4 pages and returns the bytes of the PDF.
///
/// The reader of this file cooks without the app, so the pages hold the whole menu: one table per
/// week first, then one section per recipe.
///
/// Each week and the recipes start on a new page. A week table of a normal menu fits one page, so
/// the reader sees the whole week at one glance and can pin the page on the fridge.
Future<Uint8List> renderMenuPdf(MenuPdfDocument document) async {
  final pw.Document pdf = pw.Document(title: document.title);

  pdf.addPage(
    pw.MultiPage(
      pageFormat: pdfPageFormat,
      margin: pdfPageMargin,
      footer: (pw.Context context) => pdfPageFooter(context: context, title: document.title),
      build: (pw.Context context) => <pw.Widget>[
        pdfDocumentTitle(title: document.title, subtitle: menuSubtitleText(document)),
        pw.SizedBox(height: 8),
        _legend(),
        pw.SizedBox(height: 12),
        for (int index = 0; index < document.weeks.length; index++) ...<pw.Widget>[
          if (index > 0) pw.NewPage(),
          pdfSectionBanner(text: document.weeks[index].title),
          pw.SizedBox(height: 6),
          _weekTable(document.weeks[index]),
        ],
        if (document.recipes.isNotEmpty) ...<pw.Widget>[
          if (document.weeks.isNotEmpty) pw.NewPage(),
          pdfSectionBanner(text: "Recipes"),
          pw.SizedBox(height: 10),
          for (MenuPdfRecipeSection recipe in document.recipes) ..._recipeWidgets(recipe),
        ],
      ],
    ),
  );

  return pdf.save();
}

/// Explains the two notes that a dish of the week table can carry.
pw.Widget _legend() {
  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: <pw.Widget>[
      pw.Text(cookLegendText, style: _cookNoteStyle),
      pw.Text(leftoversLegendText, style: _leftoversNoteStyle),
    ],
  );
}

/// The style of the note of a dish that the reader cooks. It is bold and in the accent color,
/// because it is the note that asks for work.
final pw.TextStyle _cookNoteStyle = pw.TextStyle(fontSize: 7, fontWeight: pw.FontWeight.bold, color: pdfAccentColor);

/// The style of the note of a dish that eats leftovers, or of a dish with no recipe. It is gray
/// and italic, because it asks for no work.
final pw.TextStyle _leftoversNoteStyle = pw.TextStyle(fontSize: 7, fontStyle: pw.FontStyle.italic, color: pdfMutedTextColor);

/// Draws one week as a table of seven rows, one per day, and four columns: the day and the three
/// meal slots.
///
/// The days are the rows because a day holds up to three meal slots and a page is taller than it
/// is wide. Seven narrow columns would cut the dish names, and the reader follows the menu day by
/// day, which is how the eye reads a page: from top to bottom.
pw.Widget _weekTable(MenuPdfWeekSection week) {
  return pw.Table(
    border: const pw.TableBorder(
      horizontalInside: pw.BorderSide(color: pdfLineColor, width: 0.5),
      bottom: pw.BorderSide(color: pdfLineColor, width: 0.5),
    ),
    columnWidths: const <int, pw.TableColumnWidth>{
      0: pw.FlexColumnWidth(1.35),
      1: pw.FlexColumnWidth(2),
      2: pw.FlexColumnWidth(2),
      3: pw.FlexColumnWidth(2),
    },
    children: <pw.TableRow>[
      pw.TableRow(
        repeat: true,
        decoration: const pw.BoxDecoration(
          border: pw.Border(bottom: pw.BorderSide(color: pdfAccentColor, width: 1)),
        ),
        children: <pw.Widget>[
          _headerCell(dayColumnHeaderText),
          for (MealType mealType in weekTableMealTypes(week)) _headerCell(mealTypeHeaderText(mealType)),
        ],
      ),
      for (int index = 0; index < week.days.length; index++)
        pw.TableRow(
          decoration: index.isOdd ? const pw.BoxDecoration(color: pdfStripeColor) : null,
          children: <pw.Widget>[
            _cell(pw.Text(week.days[index].dayLabel, style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold))),
            for (MenuPdfSlot slot in week.days[index].slots) _slotCell(slot),
          ],
        ),
    ],
  );
}

/// Draws one cell of the header row of a week table.
pw.Widget _headerCell(String text) {
  return _cell(
    pw.Text(
      text,
      style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: pdfAccentColor),
    ),
  );
}

/// Draws one meal slot: one block per sub-meal, with the dish first and the note under it.
///
/// The note says "cook 5 servings" or "leftovers", so the reader sees at one glance which meals
/// ask for work on that day. The cook note has the accent color and the leftovers note is gray.
/// A slot with no meal writes a dash.
pw.Widget _slotCell(MenuPdfSlot slot) {
  if (slot.dishes.isEmpty) return _cell(pw.Text(emptySlotText, style: const pw.TextStyle(fontSize: 9, color: pdfMutedTextColor)));

  return _cell(
    pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: <pw.Widget>[
        for (int index = 0; index < slot.dishes.length; index++) ...<pw.Widget>[
          if (index > 0) pw.SizedBox(height: 3),
          // A recipe name is free text, and a long name wraps over many lines. A table row cannot
          // split over two pages, so the cell caps each name at two lines. The cap bounds the
          // height of the row, and a day of many long dishes still fits one page.
          pw.Text(slot.dishes[index].recipeName, style: const pw.TextStyle(fontSize: 9), maxLines: 2, overflow: pw.TextOverflow.clip),
          pw.Text(
            dishNoteText(slot.dishes[index]),
            style: slot.dishes[index].source == MenuPdfDishSource.cooked ? _cookNoteStyle : _leftoversNoteStyle,
          ),
        ],
      ],
    ),
  );
}

/// The text of a slot that holds no meal. It is the dash of a dish with no recipe, so an empty
/// slot and an empty dish read the same.
const String emptySlotText = emptyDishName;

/// The name of the first column of a week table, which holds the day.
const String dayColumnHeaderText = "Day";

/// Names one meal column of a week table, for example "Breakfast".
String mealTypeHeaderText(MealType mealType) => mealType.name.capitalizeFirstLetter() ?? mealType.name;

/// The meal columns of a week table, taken from the slots of its first day.
///
/// The header and the cells then come from one source. A week that holds no day writes the three
/// meals of the clock.
List<MealType> weekTableMealTypes(MenuPdfWeekSection week) {
  if (week.days.isEmpty) return MealType.values;
  return week.days.first.slots.map((MenuPdfSlot slot) => slot.mealType).toList();
}

/// Writes the second line of a dish, for example "2p · cook 5 servings".
/// A dish with no recipe keeps its people count, because an empty slot for two people is a gap
/// that the reader has to see.
String dishNoteText(MenuPdfDish dish) {
  final String people = "${dish.people}p";
  return dish.note.isEmpty ? people : "$people · ${dish.note}";
}

/// Explains the note of a dish that the reader cooks.
const String cookLegendText = "cook N servings: cook at this meal. N counts the leftovers for later meals too.";

/// Explains the note of a dish that eats leftovers.
const String leftoversLegendText = "leftovers: eat the food of an earlier cook.";

/// Writes the line under the title, for example "3 weeks · 21 recipes".
String menuSubtitleText(MenuPdfDocument document) {
  final int weeks = document.weeks.length;
  final int recipes = document.recipes.length;
  return "$weeks ${weeks == 1 ? "week" : "weeks"} · $recipes ${recipes == 1 ? "recipe" : "recipes"}";
}

/// Pads the content of one table cell, so no text touches the border.
pw.Widget _cell(pw.Widget child) {
  return pw.Padding(padding: const pw.EdgeInsets.symmetric(horizontal: 5, vertical: 4), child: child);
}

/// The most ingredients that the renderer keeps on one page with the name of their recipe.
///
/// A [pw.Inseparable] that is taller than a page fails the export. Two ingredients share one row
/// of the grid, so 60 ingredients take 30 rows, which is far below one page. A recipe with more
/// ingredients lets its grid break over two pages.
const int _maxIngredientsKeptWithRecipeName = 60;

/// Draws one recipe: the header with the name and the facts, then the ingredients, then the
/// numbered instructions.
///
/// The header and the ingredients stay on one page, so a page never ends on a recipe name alone.
List<pw.Widget> _recipeWidgets(MenuPdfRecipeSection recipe) {
  final pw.Widget top = pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: <pw.Widget>[
      _recipeHeader(recipe),
      if (recipe.ingredients.isNotEmpty) ...<pw.Widget>[pw.SizedBox(height: 6), _ingredientGrid(recipe.ingredients)],
      pw.SizedBox(height: 6),
    ],
  );

  return <pw.Widget>[
    if (recipe.ingredients.length <= _maxIngredientsKeptWithRecipeName) pw.Inseparable(child: top) else top,
    for (MenuPdfStep step in recipe.steps) ..._stepWidgets(step),
    pw.SizedBox(height: 16),
  ];
}

/// Draws the name of a recipe over a thin accent line, and one chip per fact under it.
pw.Widget _recipeHeader(MenuPdfRecipeSection recipe) {
  return pw.Container(
    width: double.infinity,
    padding: const pw.EdgeInsets.only(bottom: 4),
    decoration: const pw.BoxDecoration(
      border: pw.Border(bottom: pw.BorderSide(color: pdfAccentColor, width: 1)),
    ),
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: <pw.Widget>[
        pw.Text(recipe.recipeName, style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 3),
        pw.Wrap(
          spacing: 4,
          runSpacing: 2,
          children: <pw.Widget>[
            for (String fact in recipeFactTexts(recipe)) pdfBadge(text: fact, color: pdfAccentColor, fillColor: pdfAccentFillColor),
          ],
        ),
      ],
    ),
  );
}

/// Draws the ingredients of a recipe as a grid of two columns, each with the name on the left and
/// the amount on the right.
///
/// Two columns halve the height of the list. Every second row has a light fill, so the eye does
/// not jump from the name of one ingredient to the amount of the next one.
pw.Widget _ingredientGrid(List<MenuPdfIngredientLine> ingredients) {
  final int rowsCount = (ingredients.length + 1) ~/ 2;

  List<pw.Widget> pairCells(MenuPdfIngredientLine? line) {
    if (line == null) return <pw.Widget>[pw.SizedBox(), pw.SizedBox()];
    return <pw.Widget>[
      _gridCell(pw.Text(line.ingredientName, style: const pw.TextStyle(fontSize: 9))),
      _gridCell(
        pw.Text(
          line.amounts,
          style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold),
          textAlign: pw.TextAlign.right,
        ),
      ),
    ];
  }

  return pw.Table(
    columnWidths: const <int, pw.TableColumnWidth>{
      0: pw.FlexColumnWidth(3),
      1: pw.FlexColumnWidth(2),
      2: pw.FixedColumnWidth(12),
      3: pw.FlexColumnWidth(3),
      4: pw.FlexColumnWidth(2),
    },
    children: <pw.TableRow>[
      for (int row = 0; row < rowsCount; row++)
        pw.TableRow(
          decoration: row.isOdd ? const pw.BoxDecoration(color: pdfStripeColor) : null,
          children: <pw.Widget>[
            ...pairCells(ingredients[row * 2]),
            pw.SizedBox(),
            ...pairCells(row * 2 + 1 < ingredients.length ? ingredients[row * 2 + 1] : null),
          ],
        ),
    ],
  );
}

/// Pads one cell of the ingredient grid.
pw.Widget _gridCell(pw.Widget child) {
  return pw.Padding(padding: const pw.EdgeInsets.symmetric(horizontal: 3, vertical: 2), child: child);
}

/// Draws one instruction: the number and the description, then the times, then the ingredients
/// that the step uses.
///
/// Every line is a plain text and no row, because a text can continue on the next page and a row
/// cannot. A step with a very long description then never fails the export.
List<pw.Widget> _stepWidgets(MenuPdfStep step) {
  final String ingredients = stepIngredientsText(step);
  return <pw.Widget>[
    pw.RichText(
      text: pw.TextSpan(
        children: <pw.InlineSpan>[
          pw.TextSpan(
            text: "${step.number}",
            style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: pdfAccentColor),
          ),
          pw.TextSpan(text: "  ${step.description}", style: const pw.TextStyle(fontSize: 9.5)),
        ],
      ),
    ),
    pw.Padding(
      padding: const pw.EdgeInsets.only(left: 12, top: 1),
      child: pw.Text(stepTimesText(step), style: const pw.TextStyle(fontSize: 7.5, color: pdfMutedTextColor)),
    ),
    if (ingredients.isNotEmpty)
      pw.Padding(
        padding: const pw.EdgeInsets.only(left: 12),
        child: pw.Text(ingredients, style: const pw.TextStyle(fontSize: 7.5, color: pdfMutedTextColor)),
      ),
    pw.SizedBox(height: 5),
  ];
}

/// Writes the facts of a recipe, one text per chip, for example
/// `["5 servings", "19 min in total", "7 min of work", "12 min of cooking"]`.
List<String> recipeFactTexts(MenuPdfRecipeSection recipe) {
  return <String>[
    "${recipe.servings} ${recipe.servings == 1 ? "serving" : "servings"}",
    "${recipe.totalTimeMinutes} min in total",
    "${recipe.workingTimeMinutes} min of work",
    "${recipe.cookingTimeMinutes} min of cooking",
  ];
}

/// Writes the times of one step, for example "5 min of work · 12 min of cooking".
String stepTimesText(MenuPdfStep step) => "${step.workingTimeMinutes} min of work · ${step.cookingTimeMinutes} min of cooking";

/// Writes the ingredients that one step uses, for example "Uses: Noodles (500 grams), Egg (5 pieces)".
/// A step that uses no ingredient writes an empty text, and the renderer then draws no line.
String stepIngredientsText(MenuPdfStep step) {
  if (step.ingredients.isEmpty) return "";
  return "Uses: ${step.ingredients.map((MenuPdfIngredientLine line) => "${line.ingredientName} (${line.amounts})").join(", ")}";
}
