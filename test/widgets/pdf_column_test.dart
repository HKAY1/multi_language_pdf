import 'package:flutter_test/flutter_test.dart';
import 'package:multi_language_pdf/src/widgets/pdf_column.dart';
import 'package:multi_language_pdf/src/widgets/pdf_text.dart';

void main() {
  test('PdfColumn uses flex-direction column', () {
    final html = PdfColumn(children: [PdfText('a')]).toHtml();
    expect(html, contains('flex-direction: column'));
  });

  test('PdfColumn renders all children', () {
    final html = PdfColumn(children: [PdfText('X'), PdfText('Y')]).toHtml();
    expect(html, contains('X'));
    expect(html, contains('Y'));
  });
}
