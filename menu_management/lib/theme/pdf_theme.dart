import "package:pdf/pdf.dart";
import "package:pdf/widgets.dart" as pw;

/// The shared look of the menu PDF and the shopping PDF: the colors, the page, the footer, and
/// the small colored marks.
///
/// The accent is the teal of the default seed color of the app (`ThemeCustom.defaultSeedColor`).
/// A PDF has no `ColorScheme`, so the colors are fixed values here.

/// The color of the titles, the banners and the notes that ask the reader to act.
const PdfColor pdfAccentColor = PdfColors.teal700;

/// The fill of a banner or a mark in the accent color.
const PdfColor pdfAccentFillColor = PdfColors.teal50;

/// The color of text that supports the main text, for example a note or a time.
const PdfColor pdfMutedTextColor = PdfColors.grey700;

/// The color of the thin lines between rows and around boxes.
const PdfColor pdfLineColor = PdfColors.grey400;

/// The fill of every second row of a table, so the eye stays on one row.
const PdfColor pdfStripeColor = PdfColors.grey100;

/// The color of a store link. Blue is the color that a reader expects of a link.
const PdfColor pdfLinkColor = PdfColors.blue800;

/// The page of both PDFs: A4 with a margin that a home printer does not cut.
const PdfPageFormat pdfPageFormat = PdfPageFormat.a4;
const pw.EdgeInsets pdfPageMargin = pw.EdgeInsets.fromLTRB(32, 32, 32, 24);

/// Writes the footer of one page, for example "Menu 6 Aug - 26 Aug · Page 2 of 9".
String pdfPageFooterText({required String title, required int pageNumber, required int pagesCount}) {
  return "$title · Page $pageNumber of $pagesCount";
}

/// Draws the footer of the current page of [context].
pw.Widget pdfPageFooter({required pw.Context context, required String title}) {
  return pw.Container(
    alignment: pw.Alignment.centerRight,
    margin: const pw.EdgeInsets.only(top: 8),
    child: pw.Text(
      pdfPageFooterText(title: title, pageNumber: context.pageNumber, pagesCount: context.pagesCount),
      style: const pw.TextStyle(fontSize: 7, color: pdfMutedTextColor),
    ),
  );
}

/// Draws the title of a document and the line under it.
pw.Widget pdfDocumentTitle({required String title, required String subtitle}) {
  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: <pw.Widget>[
      pw.Text(
        title,
        style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold, color: pdfAccentColor),
      ),
      if (subtitle.isNotEmpty) ...<pw.Widget>[
        pw.SizedBox(height: 2),
        pw.Text(subtitle, style: const pw.TextStyle(fontSize: 10, color: pdfMutedTextColor)),
      ],
    ],
  );
}

/// Draws a full-width band that opens a section, for example a week or a shop trip.
/// [trailing] is a short text at the right end of the band, for example a count. It is empty
/// when the band has nothing to count.
pw.Widget pdfSectionBanner({required String text, String trailing = ""}) {
  return pw.Container(
    padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 5),
    decoration: const pw.BoxDecoration(
      color: pdfAccentFillColor,
      border: pw.Border(left: pw.BorderSide(color: pdfAccentColor, width: 3)),
    ),
    child: pw.Row(
      children: <pw.Widget>[
        pw.Expanded(
          child: pw.Text(
            text,
            style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: pdfAccentColor),
          ),
        ),
        if (trailing.isNotEmpty) pw.Text(trailing, style: const pw.TextStyle(fontSize: 9, color: pdfAccentColor)),
      ],
    ),
  );
}

/// Draws a small rounded mark with [text], for example "Recommended".
pw.Widget pdfBadge({required String text, required PdfColor color, required PdfColor fillColor}) {
  return pw.Container(
    padding: const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 1),
    decoration: pw.BoxDecoration(
      color: fillColor,
      border: pw.Border.all(color: color, width: 0.5),
      borderRadius: const pw.BorderRadius.all(pw.Radius.circular(3)),
    ),
    child: pw.Text(
      text,
      style: pw.TextStyle(fontSize: 7, fontWeight: pw.FontWeight.bold, color: color),
    ),
  );
}
