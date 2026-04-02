import 'package:flutter_test/flutter_test.dart';
import 'package:multi_language_pdf/src/widgets/pdf_text.dart';
import 'package:multi_language_pdf/src/types/pdf_color.dart';
import 'package:multi_language_pdf/src/types/pdf_alignment.dart';

void main() {
  group('PdfText.toHtml', () {
    test('renders plain text in a paragraph', () {
      final html = PdfText('Hello').toHtml();
      expect(html, contains('<p'));
      expect(html, contains('Hello'));
      expect(html, contains('</p>'));
    });

    test('applies font-size', () {
      final html = PdfText('x', fontSize: 20).toHtml();
      expect(html, contains('font-size: 20'));
      expect(html, contains('px'));
    });

    test('applies bold', () {
      final html = PdfText('x', bold: true).toHtml();
      expect(html, contains('font-weight: bold'));
    });

    test('applies italic', () {
      final html = PdfText('x', italic: true).toHtml();
      expect(html, contains('font-style: italic'));
    });

    test('applies underline', () {
      final html = PdfText('x', underline: true).toHtml();
      expect(html, contains('text-decoration: underline'));
    });

    test('applies color', () {
      final html = PdfText('x', color: PdfColor(255, 0, 0)).toHtml();
      expect(html, contains('rgba(255,0,0,1.0)'));
    });

    test('applies text-align', () {
      final html = PdfText('x', textAlign: PdfTextAlign.center).toHtml();
      expect(html, contains('text-align: center'));
    });

    test('applies max-lines via webkit clamp', () {
      final html = PdfText('x', maxLines: 2).toHtml();
      expect(html, contains('-webkit-line-clamp: 2'));
    });

    test('escapes HTML special characters', () {
      final html = PdfText('<script>alert("xss")</script>').toHtml();
      expect(html, isNot(contains('<script>')));
      expect(html, contains('&lt;script&gt;'));
    });
  });
}
