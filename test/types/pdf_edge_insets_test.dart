import 'package:flutter_test/flutter_test.dart';
import 'package:multi_language_pdf/src/types/pdf_edge_insets.dart';

void main() {
  group('PdfEdgeInsets', () {
    test('all sets all sides', () {
      final e = PdfEdgeInsets.all(8);
      expect(e.toCss(), '8.0px 8.0px 8.0px 8.0px');
    });

    test('symmetric sets horizontal and vertical', () {
      final e = PdfEdgeInsets.symmetric(horizontal: 16, vertical: 4);
      expect(e.toCss(), '4.0px 16.0px 4.0px 16.0px');
    });

    test('only sets specified sides, others default to 0', () {
      final e = PdfEdgeInsets.only(left: 10, bottom: 5);
      expect(e.toCss(), '0.0px 0.0px 5.0px 10.0px');
    });

    test('zero produces all zeros', () {
      expect(PdfEdgeInsets.zero.toCss(), '0.0px 0.0px 0.0px 0.0px');
    });
  });
}
