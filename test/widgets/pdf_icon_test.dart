import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:multi_language_pdf/src/widgets/pdf_icon.dart';
import 'package:multi_language_pdf/src/types/pdf_color.dart';

void main() {
  test('PdfIcon renders unicode codepoint as span', () {
    final html = PdfIcon(Icons.check_circle, size: 24).toHtml();
    expect(html, contains('<span'));
    expect(html, contains('font-family: Material Icons'));
    expect(html, contains('font-size: 24px'));
  });

  test('PdfIcon applies color', () {
    final html = PdfIcon(Icons.star, size: 16, color: PdfColor(255, 0, 0)).toHtml();
    expect(html, contains('rgba(255,0,0,1.0)'));
  });
}
