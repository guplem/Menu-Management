import "dart:typed_data";

import "package:menu_management/flutter_essentials/library.dart";
import "package:menu_management/ingredients/models/ingredient.dart";
import "package:menu_management/menu/enums/meal_type.dart";
import "package:menu_management/menu/models/menu_pdf_document.dart";
import "package:menu_management/menu/models/multi_week_menu.dart";
import "package:menu_management/recipes/models/recipe.dart";
import "package:pdf/pdf.dart";
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
Future<Uint8List> renderMenuPdf(MenuPdfDocument document) async {
  final pw.Document pdf = pw.Document(title: document.title);

  pdf.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(28),
      build: (pw.Context context) => <pw.Widget>[
        pw.Text(document.title, style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 14),
        for (MenuPdfWeekSection week in document.weeks) ...<pw.Widget>[
          pw.Text(week.title, style: pw.TextStyle(fontSize: 15, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 6),
          _weekTable(week),
          pw.SizedBox(height: 18),
        ],
        if (document.recipes.isNotEmpty) ...<pw.Widget>[
          pw.Text("Recipes", style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 8),
          for (MenuPdfRecipeSection recipe in document.recipes) ..._recipeWidgets(recipe),
        ],
      ],
    ),
  );

  return pdf.save();
}

/// Draws one week as a table of seven rows, one per day, and four columns: the day and the three
/// meal slots.
///
/// The days are the rows because a day holds up to three meal slots and a page is taller than it
/// is wide. Seven narrow columns would cut the dish names, and the reader follows the menu day by
/// day, which is how the eye reads a page: from top to bottom.
pw.Widget _weekTable(MenuPdfWeekSection week) {
  return pw.Table(
    border: pw.TableBorder.all(color: PdfColors.grey400, width: 0.5),
    columnWidths: const <int, pw.TableColumnWidth>{
      0: pw.FlexColumnWidth(1.5),
      1: pw.FlexColumnWidth(2),
      2: pw.FlexColumnWidth(2),
      3: pw.FlexColumnWidth(2),
    },
    children: <pw.TableRow>[
      pw.TableRow(
        repeat: true,
        decoration: const pw.BoxDecoration(color: PdfColors.grey300),
        children: <pw.Widget>[
          _headerCell("Day"),
          for (MealType mealType in MealType.values) _headerCell(mealType.name.capitalizeFirstLetter() ?? mealType.name),
        ],
      ),
      for (MenuPdfDayRow day in week.days)
        pw.TableRow(
          children: <pw.Widget>[
            _cell(pw.Text(day.dayLabel, style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold))),
            for (MenuPdfSlot slot in day.slots) _slotCell(slot),
          ],
        ),
    ],
  );
}

/// Draws one cell of the header row of a week table.
pw.Widget _headerCell(String text) {
  return _cell(pw.Text(text, style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)));
}

/// Draws one meal slot: one block per sub-meal, with the dish first and the note under it.
///
/// The note says "cook 5 servings" or "leftovers", so the reader sees at one glance which meals
/// ask for work on that day. A slot with no meal writes a dash.
pw.Widget _slotCell(MenuPdfSlot slot) {
  if (slot.dishes.isEmpty) return _cell(pw.Text("-", style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey600)));

  return _cell(
    pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: <pw.Widget>[
        for (MenuPdfDish dish in slot.dishes) ...<pw.Widget>[
          pw.Text(dish.recipeName, style: const pw.TextStyle(fontSize: 9)),
          pw.Text(_dishNote(dish), style: const pw.TextStyle(fontSize: 7, color: PdfColors.grey700)),
        ],
      ],
    ),
  );
}

/// Writes the second line of a dish, for example "2p - cook 5 servings".
/// A dish with no recipe keeps its people count, because an empty slot for two people is a gap
/// that the reader has to see.
String _dishNote(MenuPdfDish dish) {
  final String people = "${dish.people}p";
  return dish.note.isEmpty ? people : "$people - ${dish.note}";
}

/// Pads the content of one table cell, so no text touches the border.
pw.Widget _cell(pw.Widget child) {
  return pw.Padding(padding: const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 3), child: child);
}

/// Draws one recipe: the name and the times, then the ingredients, then the numbered instructions.
List<pw.Widget> _recipeWidgets(MenuPdfRecipeSection recipe) {
  return <pw.Widget>[
    pw.Text(recipe.recipeName, style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold)),
    pw.Text(
      "${recipe.servings} ${recipe.servings == 1 ? "serving" : "servings"} - "
      "${recipe.totalTimeMinutes} min (${recipe.workingTimeMinutes} min of work, ${recipe.cookingTimeMinutes} min of cooking)",
      style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
    ),
    pw.SizedBox(height: 4),
    if (recipe.ingredients.isNotEmpty) ...<pw.Widget>[
      pw.Text("Ingredients", style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
      for (MenuPdfIngredientLine line in recipe.ingredients)
        pw.Bullet(text: "${line.ingredientName}: ${line.amounts}", style: const pw.TextStyle(fontSize: 9), bulletSize: 1.5),
      pw.SizedBox(height: 4),
    ],
    for (MenuPdfStep step in recipe.steps) ..._stepWidgets(step),
    pw.SizedBox(height: 14),
  ];
}

/// Draws one instruction: the number and the description, then the times and the ingredients of
/// that step.
List<pw.Widget> _stepWidgets(MenuPdfStep step) {
  return <pw.Widget>[
    pw.Text("${step.number}. ${step.description}", style: const pw.TextStyle(fontSize: 9)),
    pw.Text(
      "   ${step.workingTimeMinutes} min of work, ${step.cookingTimeMinutes} min of cooking"
      "${step.ingredients.isEmpty ? "" : " - ${step.ingredients.map((MenuPdfIngredientLine line) => "${line.ingredientName}: ${line.amounts}").join(", ")}"}",
      style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700),
    ),
    pw.SizedBox(height: 3),
  ];
}
