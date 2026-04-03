import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:multi_language_pdf/src/widgets/pdf_image.dart';

void main() {
  group('PdfImage.memory', () {
    test('toHtml uses data URI after resolve with memory bytes', () async {
      final bytes = Uint8List.fromList([0, 1, 2, 3]);
      final img = PdfImage.memory(bytes, width: 100, height: 50);
      await img.resolve(rootBundle, null as dynamic);
      final html = img.toHtml();
      expect(html, contains('<img'));
      expect(html, contains('data:image/png;base64,'));
      expect(html, contains('width: 100.0px'));
      expect(html, contains('height: 50.0px'));
    });

    test('toHtml throws StateError if resolve not called', () {
      final img = PdfImage.memory(Uint8List(0), width: 10, height: 10);
      expect(() => img.toHtml(), throwsStateError);
    });
  });

  group('PdfImage.network', () {
    test('is created with a URL', () {
      final img = PdfImage.network('https://example.com/img.png', width: 50, height: 50);
      expect(img, isA<PdfImage>());
    });
  });
}
