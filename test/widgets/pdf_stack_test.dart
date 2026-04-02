import 'package:flutter_test/flutter_test.dart';
import 'package:multi_language_pdf/src/widgets/pdf_stack.dart';
import 'package:multi_language_pdf/src/widgets/pdf_positioned.dart';
import 'package:multi_language_pdf/src/widgets/pdf_text.dart';

void main() {
  group('PdfStack', () {
    test('stack uses position relative', () {
      final html = PdfStack(children: [
        PdfPositioned(top: 0, left: 0, child: PdfText('A')),
      ]).toHtml();
      expect(html, contains('position: relative'));
    });

    test('positioned child uses position absolute', () {
      final html = PdfPositioned(top: 10, left: 20, child: PdfText('A')).toHtml();
      expect(html, contains('position: absolute'));
      expect(html, contains('top: 10.0px'));
      expect(html, contains('left: 20.0px'));
    });

    test('renders child content inside positioned', () {
      final html = PdfStack(children: [
        PdfPositioned(top: 0, left: 0, child: PdfText('Hello')),
      ]).toHtml();
      expect(html, contains('Hello'));
    });
  });
}
