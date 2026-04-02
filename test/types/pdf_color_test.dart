import 'package:flutter_test/flutter_test.dart';
import 'package:multi_language_pdf/src/types/pdf_color.dart';

void main() {
  group('PdfColor', () {
    test('toCss produces rgba string', () {
      expect(PdfColor(255, 0, 0).toCss(), 'rgba(255,0,0,1.0)');
    });

    test('toCss respects alpha', () {
      expect(PdfColor(0, 0, 0, a: 0.5).toCss(), 'rgba(0,0,0,0.5)');
    });

    test('fromHex parses 6-char hex', () {
      expect(PdfColor.fromHex('#2196F3').toCss(), 'rgba(33,150,243,1.0)');
    });

    test('fromHex works without hash prefix', () {
      expect(PdfColor.fromHex('FF0000').toCss(), 'rgba(255,0,0,1.0)');
    });

    test('transparent has alpha 0', () {
      expect(PdfColor.transparent.toCss(), 'rgba(0,0,0,0.0)');
    });
  });
}
