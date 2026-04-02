import 'package:flutter_test/flutter_test.dart';
import 'package:multi_language_pdf/src/types/pdf_border.dart';
import 'package:multi_language_pdf/src/types/pdf_color.dart';

void main() {
  group('PdfBorder', () {
    test('toCss produces correct border shorthand', () {
      final b = PdfBorder(color: PdfColor(0, 0, 0), width: 1);
      expect(b.toCss(), '1.0px solid rgba(0,0,0,1.0)');
    });

    test('toRadiusCss produces border-radius value', () {
      final b = PdfBorder(color: PdfColor(0, 0, 0), width: 1, radius: 8);
      expect(b.toRadiusCss(), '8.0px');
    });

    test('toRadiusCss returns empty string when radius is zero', () {
      final b = PdfBorder(color: PdfColor(0, 0, 0), width: 1);
      expect(b.toRadiusCss(), '');
    });
  });
}
