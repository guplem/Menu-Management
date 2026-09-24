import "dart:convert";
import "dart:io";
import "dart:typed_data";

/// Reads back the words that the PDF draws on its pages, joined by one space.
///
/// A PDF holds its drawn text in a compressed stream, and it writes one word at a time as
/// `[(word)]TJ`. This inflates every stream and puts the words back together, so a test can read
/// the page the way the reader reads it. It is the one way to prove that a string reaches a page.
///
/// The `[(word)]TJ` form is the form of the built-in PDF fonts. A PDF that embeds its own font
/// writes glyph numbers instead, and this reader then finds no word.
String drawnPdfText(Uint8List bytes) {
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
int pdfPageCount(Uint8List bytes) => RegExp(r"/Type/Page[^s]").allMatches(latin1.decode(bytes)).length;
