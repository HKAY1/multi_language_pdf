import 'package:flutter_test/flutter_test.dart';
import 'package:multi_language_pdf/src/widgets/pdf_container.dart';
import 'package:multi_language_pdf/src/types/pdf_color.dart';
import 'package:multi_language_pdf/src/types/pdf_border.dart';

void main() {
  test('PdfContainer applies background color', () {
    final html = PdfContainer(color: PdfColor(255, 0, 0)).toHtml();
    expect(html, contains('rgba(255,0,0,1.0)'));
  });

  test('PdfContainer applies border and border-radius', () {
    final html = PdfContainer(
      border: PdfBorder(color: PdfColor(0, 0, 0), width: 2, radius: 10),
    ).toHtml();
    expect(html, contains('border:'));
    expect(html, contains('border-radius: 10.0px'));
  });

  test('PdfContainer applies width and height', () {
    final html = PdfContainer(width: 100, height: 50).toHtml();
    expect(html, contains('width: 100.0px'));
    expect(html, contains('height: 50.0px'));
  });
}
