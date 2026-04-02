import 'package:flutter_test/flutter_test.dart';
import 'package:multi_language_pdf/src/widgets/pdf_rich_text.dart';
import 'package:multi_language_pdf/src/types/pdf_text_span.dart';
import 'package:multi_language_pdf/src/types/pdf_color.dart';

void main() {
  group('PdfRichText.toHtml', () {
    test('wraps spans inside a paragraph', () {
      final html = PdfRichText(spans: [PdfTextSpan('Hello')]).toHtml();
      expect(html, contains('<p'));
      expect(html, contains('<span'));
      expect(html, contains('Hello'));
      expect(html, contains('</p>'));
    });

    test('applies bold to a span', () {
      final html = PdfRichText(
        spans: [PdfTextSpan('Bold', bold: true)],
      ).toHtml();
      expect(html, contains('font-weight: bold'));
    });

    test('applies color to a span', () {
      final html = PdfRichText(
        spans: [PdfTextSpan('Red', color: PdfColor(255, 0, 0))],
      ).toHtml();
      expect(html, contains('rgba(255,0,0,1.0)'));
    });

    test('renders multiple spans in order', () {
      final html = PdfRichText(
        spans: [PdfTextSpan('A'), PdfTextSpan('B')],
      ).toHtml();
      expect(html.indexOf('A'), lessThan(html.indexOf('B')));
    });
  });
}
