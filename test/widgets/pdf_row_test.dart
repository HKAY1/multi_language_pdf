import 'package:flutter_test/flutter_test.dart';
import 'package:multi_language_pdf/src/widgets/pdf_row.dart';
import 'package:multi_language_pdf/src/widgets/pdf_text.dart';
import 'package:multi_language_pdf/src/types/pdf_alignment.dart';

void main() {
  group('PdfRow.toHtml', () {
    test('uses flex-direction row', () {
      final html = PdfRow(children: [PdfText('a')]).toHtml();
      expect(html, contains('flex-direction: row'));
    });

    test('applies mainAxisAlignment', () {
      final html = PdfRow(
        children: [PdfText('a')],
        mainAxisAlignment: PdfMainAxisAlignment.spaceBetween,
      ).toHtml();
      expect(html, contains('justify-content: space-between'));
    });

    test('applies crossAxisAlignment', () {
      final html = PdfRow(
        children: [PdfText('a')],
        crossAxisAlignment: PdfCrossAxisAlignment.center,
      ).toHtml();
      expect(html, contains('align-items: center'));
    });

    test('applies gap', () {
      final html = PdfRow(children: [PdfText('a')], gap: 12).toHtml();
      expect(html, contains('gap: 12px'));
    });

    test('renders all children', () {
      final html = PdfRow(children: [PdfText('A'), PdfText('B')]).toHtml();
      expect(html, contains('A'));
      expect(html, contains('B'));
    });
  });
}
