import "package:flutter_test/flutter_test.dart";
import "package:menu_management/theme/pdf_theme.dart";

void main() {
  group("pdfPageFooterText", () {
    test("names the document and the page, so a loose printed page still says where it belongs", () {
      expect(pdfPageFooterText(title: "Menu 6 Aug - 26 Aug", pageNumber: 2, pagesCount: 9), "Menu 6 Aug - 26 Aug · Page 2 of 9");
      expect(pdfPageFooterText(title: "Shopping list", pageNumber: 1, pagesCount: 1), "Shopping list · Page 1 of 1");
    });
  });
}
