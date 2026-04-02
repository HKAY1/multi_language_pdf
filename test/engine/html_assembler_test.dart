import 'package:flutter_test/flutter_test.dart';
import 'package:multi_language_pdf/src/engine/html_assembler.dart';
import 'package:multi_language_pdf/src/document/pdf_document.dart';
import 'package:multi_language_pdf/src/document/pdf_page_config.dart';
import 'package:multi_language_pdf/src/widgets/pdf_text.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('HtmlAssembler.assemble', () {
    test('returns a complete HTML document string', () async {
      final doc = PdfDocument(children: [PdfText('Hello')]);
      final html = await HtmlAssembler.assemble(doc);
      expect(html, startsWith('<!DOCTYPE html>'));
      expect(html, contains('<html'));
      expect(html, contains('</html>'));
    });

    test('includes utf-8 charset meta tag', () async {
      final doc = PdfDocument(children: [PdfText('Hello')]);
      final html = await HtmlAssembler.assemble(doc);
      expect(html, contains('charset="utf-8"'));
    });

    test('wraps each child in a data-pdf-block div', () async {
      final doc = PdfDocument(
        children: [PdfText('A'), PdfText('B')],
      );
      final html = await HtmlAssembler.assemble(doc);
      expect('data-pdf-block'.allMatches(html).length, 2);
    });

    test('applies page width from PdfPageConfig', () async {
      final doc = PdfDocument(
        pageConfig: PdfPageConfig.a4Portrait(),
        children: [PdfText('x')],
      );
      final html = await HtmlAssembler.assemble(doc);
      expect(html, contains('794'));
    });

    test('includes Material Icons link for icon support', () async {
      final doc = PdfDocument(children: [PdfText('x')]);
      final html = await HtmlAssembler.assemble(doc);
      expect(html, contains('Material+Icons'));
    });
  });
}
